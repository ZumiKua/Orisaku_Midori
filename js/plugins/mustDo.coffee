###:
 * @plugindesc Make sure some code must be done whether the bitmap is loaded or not.
 * @author ZumiKua
 *
 * @help
 * if you can't understand the plugindesc then you can safely ignore this plugin.
###

Bitmap.prototype.mustDo = (func,binding)->
  f = func.bind(binding,this)
  if @isReady()
    f()
  else
    @addLoadListener(f)
