alphaJunoSysexMessage = (param) -> (d, m) ->
  return [
    0xf0 # begin exclusive
    0x41 # roland
    0x36 # tone parameter
    +d[1] - 1 # channel - 1
    0x23, 0x20, 0x01 # ??
    param
    ~~(+m.args[0].value)
    0xf7 # end of exclusive
    ]

alphaJunoSysexEntry = (paramName, paramNumber) ->
  return {
    regex: new RegExp "^\\/sysex\\/alphajuno\\/chan\\/(\\d+)\\/#{paramName}$"
    f: alphaJunoSysexMessage paramNumber
    }

module.exports = [
  alphaJunoSysexEntry "dco\\/env_mode", 0x00
  alphaJunoSysexEntry "vcf\\/env_mode", 0x01
  alphaJunoSysexEntry "vca\\/env_mode", 0x02
  alphaJunoSysexEntry "dco\\/pulse", 0x03
  alphaJunoSysexEntry "dco\\/saw", 0x04
  alphaJunoSysexEntry "dco\\/sub", 0x05
  alphaJunoSysexEntry "dco\\/range", 0x06
  alphaJunoSysexEntry "dco\\/sub_level", 0x07
  alphaJunoSysexEntry "dco\\/noise_level", 0x08
  alphaJunoSysexEntry "hpf", 0x09
  alphaJunoSysexEntry "chorus\\/on", 0x0a
  alphaJunoSysexEntry "dco\\/lfo_mod", 0x0b
  alphaJunoSysexEntry "dco\\/env_mod", 0x0c
  alphaJunoSysexEntry "dco\\/after_mod", 0x0d
  alphaJunoSysexEntry "dco\\/pwm_depth", 0x0e
  alphaJunoSysexEntry "dco\\/pwm_rate", 0x0f
  alphaJunoSysexEntry "vcf\\/cutoff", 0x10
  alphaJunoSysexEntry "vcf\\/resonance", 0x11
  alphaJunoSysexEntry "vcf\\/lfo_mod", 0x12
  alphaJunoSysexEntry "vcf\\/env_mod", 0x13
  alphaJunoSysexEntry "vcf\\/key_follow", 0x14
  alphaJunoSysexEntry "vcf\\/after_mod", 0x15
  alphaJunoSysexEntry "vca\\/level", 0x16
  alphaJunoSysexEntry "vca\\/after_mod", 0x17
  alphaJunoSysexEntry "lfo\\/rate", 0x18
  alphaJunoSysexEntry "lfo\\/delay", 0x19
  alphaJunoSysexEntry "env\\/t1", 0x1a
  alphaJunoSysexEntry "env\\/l1", 0x1b
  alphaJunoSysexEntry "env\\/t2", 0x1c
  alphaJunoSysexEntry "env\\/l2", 0x1d
  alphaJunoSysexEntry "env\\/t3", 0x1e
  alphaJunoSysexEntry "env\\/l3", 0x1f
  alphaJunoSysexEntry "env\\/t4", 0x20
  alphaJunoSysexEntry "env\\/key_follow", 0x21
  alphaJunoSysexEntry "chorus\\/rate", 0x22
  alphaJunoSysexEntry "bend_range", 0x23
  ]
