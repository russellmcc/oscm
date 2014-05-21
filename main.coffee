`#!/usr/bin/env node
`

midi = require 'midi'
dgram = require 'dgram'
osc = require 'osc-min'

# Set up a new input
output = new midi.output()

# Count the available output ports.
console.log output.getPortCount()
outputs = []
for n in [0...output.getPortCount()]
  console.log output.getPortName n
  t = new midi.output()
  t.openPort n
  outputs.push t

port = process.env.npm_package_config_port ? 41234

oscTranslationChart = [
  {
    regex: /^\/midi\/([^\/]+)\/(\d+)\/note\/(\d+)\/on$/
    f: (d, m) -> console.log d, m.args
  }
]

handleOSC = (message) ->
  for {regex, f} in oscTranslationChart
    console.log message.address
    r = regex.exec message.address
    f r, message

sock = dgram.createSocket "udp4", (msg, rinfo) ->
  try
    handleOSC osc.fromBuffer msg
  catch error
    console.log "invalid OSC packet", error
sock.bind port

console.log "OSC listener running at http://localhost:#{port}"
