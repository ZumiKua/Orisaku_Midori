###:
* @plugindesc NW.js acts wired under high-DPI screen and scale enabled.(Size is not right). This plugin trys to fix this bug.
* @author ZumiKua
###
_highdpifix_Graphics_initialize = Graphics.initialize
Graphics.initialize = ()->
  _highdpifix_Graphics_initialize.apply(this,arguments)
  bw = window.outerWidth - window.innerWidth
  bh = window.outerHeight - window.innerHeight
  window.resizeTo(@_width + bw, @_height + bh)
