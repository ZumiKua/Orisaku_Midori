
/*
_MessageEx_Alias_Window_Message_subWindows = @Window_Message.prototype.subWindows
@Window_Message.prototype.subWindows = ()->
  old = _MessageEx_Alias_Window_Message_subWindows.apply(this,arguments)
  old.unshift @nice_body
  old

_MessageEx_Alias_Window_Message_createSubWindows =  @Window_Message.prototype.createSubWindows
@Window_Message.prototype.createSubWindows = ()->
  _MessageEx_Alias_Window_Message_createSubWindows.apply(this,arguments)
  @nice_body = new NiceBody();

Scene_Map.prototype.createMessageWindow = ()->
    this._messageWindow = new Window_Message()
    this.addChild(this._messageWindow.nice_body)
    this.addWindow(this._messageWindow)
    this._messageWindow.subWindows().forEach(((window)->
        this.addWindow(window)
    ), this);
 */
var _MessageEx_Alias_Window_Message_convertEscapeCharacters;

_MessageEx_Alias_Window_Message_convertEscapeCharacters = this.Window_Message.prototype.convertEscapeCharacters;

this.Window_Message.prototype.convertEscapeCharacters = function(text) {
  text = _MessageEx_Alias_Window_Message_convertEscapeCharacters.apply(this, arguments);
  text = text.replace(/\x1bS/gi, function() {
    if (SceneManager._scene.nice_body) {
      SceneManager._scene.nice_body.show();
    }
    return "";
  });
  text = text.replace(/\x1bH/gi, function() {
    if (SceneManager._scene.nice_body) {
      SceneManager._scene.nice_body.hide();
    }
    return "";
  });
  text = text.replace(/\x1bE\[(\w+)\]/gi, function(_, exp) {
    if (SceneManager._scene.nice_body) {
      SceneManager._scene.nice_body.express = exp;
    }
    return "";
  });
  console.log(text);
  return text;
};
