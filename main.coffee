`#!/usr/bin/env node
`

midi = require 'midi'
dgram = require 'dgram'
osc = require 'osc-min'

# Set up a new input
output = new midi.output()

# Count the available output ports.
outputs = []
if output.getPortCount() is 0
  console.log "No MIDI Ports found, exiting..."
  process.exit(1)
else
  console.log "#{output.getPortCount()} MIDI Ports found: "
for n in [0...output.getPortCount()]
  console.log "\tOutput #{n}: #{output.getPortName n}"
  t = new midi.output()
  t.openPort n
  outputs.push t
  outputs[output.getPortName n] = t

port = process.env.npm_package_config_port ? 41234

# helpers for common midi messages
midiChanMsg = (chan, prefix, byte2, byte3) ->
  return [(prefix + chan - 1), byte2] unless byte3?
  return [(prefix + chan - 1), byte2, byte3]

sendIfAvailable = (output, msg) ->
  output = +output if not outputs[output]?
  return unless outputs[output]?
  outputs[output].sendMessage msg

handleDefaultMidiChanMsg = (prefix) -> (d, m) ->
  val = ~~(+m.args[0].value)

  if d[3]?
    sendIfAvailable d[1], midiChanMsg +d[2], prefix, +d[3], val
  else
    sendIfAvailable d[1], midiChanMsg +d[2], prefix, val

# this is the osc to midi translation map
oscToMIDI = [
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/note\/(\d+)\/off$/
    f: handleDefaultMidiChanMsg 0x80
  }
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/note\/(\d+)\/on$/
    f: handleDefaultMidiChanMsg 0x90
  }
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/aftertouch\/(\d+)$/
    f: handleDefaultMidiChanMsg 0xA0
  }
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/cc\/(\d+)$/
    f: handleDefaultMidiChanMsg 0xB0
  }
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/program$/
    f: handleDefaultMidiChanMsg 0xC0
  }
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/aftertouch$/
    f: handleDefaultMidiChanMsg 0xD0
  }
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/pitchbend$/
    f: (d, m) ->
      val = +m.args[0].value + 0x2000
      sendIfAvailable d[1], [0xE0 + +d[2] - 1, (val & 0x7f), ~~(val / 0x80)]
  }
]

handleOSC = (message) ->
  for {regex, f} in oscToMIDI
    r = regex.exec message.address
    if r?
      f r, message
      return

sock = dgram.createSocket "udp4", (msg, rinfo) ->
  try
    handleOSC osc.fromBuffer msg
  catch error
    console.log "invalid OSC packet", error
sock.bind port

console.log "OSC listener running at http://localhost:#{port}"
