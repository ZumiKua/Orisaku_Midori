
/*:
 * @plugindesc Make sure some code must be done whether the bitmap is loaded or not.
 * @author ZumiKua
 *
 * @help
 * if you can't understand the plugindesc then you can safely ignore this plugin.
 */
Bitmap.prototype.mustDo = function(func, binding) {
  var f;
  f = func.bind(binding, this);
  if (this.isReady()) {
    return f();
  } else {
    return this.addLoadListener(f);
  }
};
