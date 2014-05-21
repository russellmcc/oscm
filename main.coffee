midi = require 'midi'
dgram = require 'dgram'

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

port = process.env.npm_package_config_port

sock = udp.createSocket "udp4", (msg, rinfo) ->
  try
    console.log osc.fromBuffer msg
  catch error
    console.log "invalid OSC packet"
sock.bind port

console.log "OSC listener running at http://localhost:#{port}"
