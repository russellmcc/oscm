# oscm, a minimalist osc-to-midi bridge

## Usage

1.  Install
2.  Plug-in midi interface
3.  navigate to oscm directory, `npm start`
4.  Connect via bonjour
5.  Send midi messages via OSC!  Stuff like /chan/1/cc/7 or /chan/8/note/84/on are valid addresses.  Right now I still have to document exactly what's available, but you can check out main.coffee for more.