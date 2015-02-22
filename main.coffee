`#!/usr/bin/env node
`

midi = require 'midi'
dgram = require 'dgram'
osc = require 'osc-min'
mdns = require 'mdns'
fs = require 'fs'
path = require 'path'

# Set up a new input
output = new midi.output()

# helpers for common midi messages
midiChanMsg = (chan, prefix, byte2, byte3) ->
  return [(prefix + chan - 1), byte2] unless byte3?
  return [(prefix + chan - 1), byte2, byte3]

defaultMidiChanMsg = (prefix, d, m) ->
  val = ~~(+m.args[0].value)

  if d[2]?
    return midiChanMsg +d[1], prefix, +d[2], val
  else
    return midiChanMsg +d[1], prefix, val

oscToMIDIMap = [
  {
    regex: /^\/chan\/(\d+)\/note\/(\d+)\/off$/
    f: (d, m) -> defaultMidiChanMsg 0x80, d, m
  }
  {
    regex: /^\/chan\/(\d+)\/note\/(\d+)\/on$/
    f: (d, m) -> defaultMidiChanMsg 0x90, d, m
  }
  {
    regex: /^\/chan\/(\d+)\/aftertouch\/(\d+)$/
    f: (d, m) -> defaultMidiChanMsg 0xA0, d, m
  }
  {
    regex: /^\/chan\/(\d+)\/cc\/(\d+)$/
    f: (d, m) -> defaultMidiChanMsg 0xB0, d, m
  }
  {
    regex: /^\/chan\/(\d+)\/program$/
    f: (d, m) -> defaultMidiChanMsg 0xC0, d, m
  }
  {
    regex: /^\/chan\/(\d+)\/aftertouch$/
    f: (d, m) -> defaultMidiChanMsg 0xD0, d, m
  }
  {
    regex: /^\/chan\/(\d+)\/pitchbend$/
    f: (d, m) ->
      val = +m.args[0].value + 0x2000
      return [0xE0 + +d[1] - 1, (val & 0x7f), ~~(val / 0x80)]
  }
]

# load all our sysex paths
sysexPath = path.join __dirname, 'sysex'
for p in fs.readdirSync path.join __dirname, 'sysex'
  continue unless p.substring(p.length - 3) is ".js"
  moreMap = require(path.join sysexPath, p)
  oscToMIDIMap = oscToMIDIMap.concat moreMap


oscToMIDI = (message) ->
  for {regex, f} in oscToMIDIMap
    r = regex.exec message.address
    if r?
      return f r, message
  console.log "Nothing matched message #{message.address}"

class OSCMidiPort
  constructor: (@midiPortNumber) ->
    @midiPort = new midi.output()
    @midiName = @midiPort.getPortName @midiPortNumber

    @midiPort.openPort @midiPortNumber

    @sock = dgram.createSocket "udp4", (msg, rinfo) =>
      try
        @handleOSC osc.fromBuffer msg
      catch error
        console.log "invalid OSC packet" , error
    @sock.bind 0, (err) =>
      unless err
        @advert = new mdns.Advertisement (mdns.udp 'osc'), @sock.address().port, {name: "OSC MIDI Bridge: #{@midiName}"}
        @advert.start()
        console.log "OSC listener for #{@midiName} running at udp localhost:#{@sock.address().port}"
      else
        console.error "error occured while opening socket: #{err}"

  handleOSC: (message) ->
    m = oscToMIDI message
    console.log m
    @midiPort.sendMessage m if m?

# Count the available output ports.
outputs = []
if output.getPortCount() is 0
  console.log "No MIDI Ports found, exiting..."
  process.exit(1)

for n in [0...output.getPortCount()]
  outputs.push new OSCMidiPort(n)
