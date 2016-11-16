
/*:
* @plugindesc NW.js acts wired under high-DPI screen and scale enabled.(Size is not right). This plugin trys to fix this bug.
* @author ZumiKua
 */
var _highdpifix_Graphics_initialize;

_highdpifix_Graphics_initialize = Graphics.initialize;

Graphics.initialize = function() {
  var bh, bw;
  _highdpifix_Graphics_initialize.apply(this, arguments);
  bw = window.outerWidth - window.innerWidth;
  bh = window.outerHeight - window.innerHeight;
  return window.resizeTo(this._width + bw, this._height + bh);
};
