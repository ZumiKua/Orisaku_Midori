
/*:
    @plugindesc Display character pictures when talking.
    @author ZumiKua
 */
var _MessageEx_Alias_Window_Message_convertEscapeCharacters, _old_terminateMessage_;

_MessageEx_Alias_Window_Message_convertEscapeCharacters = this.Window_Message.prototype.convertEscapeCharacters;

this.Window_Message.prototype.convertEscapeCharacters = function(text) {
  text = _MessageEx_Alias_Window_Message_convertEscapeCharacters.apply(this, arguments);
  text = text.replace(/\x1bS/gi, function() {
    if (SceneManager._scene.nice_body) {
      SceneManager._scene.nice_body.slideIn();
    }
    return "";
  });
  text = text.replace(/\x1bH/gi, function() {
    if (SceneManager._scene.nice_body) {
      SceneManager._scene.nice_body.slideOut();
    }
    return "";
  });
  text = text.replace(/\x1bE\[(\w+)\]/gi, function(_, exp) {
    if (SceneManager._scene.nice_body) {
      SceneManager._scene.nice_body.express = exp;
    }
    return "";
  });
  return text;
};

_old_terminateMessage_ = this.Window_Message.prototype.terminateMessage;

this.Window_Message.prototype.terminateMessage = function() {
  var isNextMessage, nxtCode, ref, ref1;
  if (SceneManager._scene instanceof Scene_Map) {
    isNextMessage = false;
    nxtCode = (ref = $gameMap._interpreter.currentCommand()) != null ? ref.code : void 0;
    console.log(nxtCode);
    if (nxtCode >= 101 && nxtCode <= 104) {
      isNextMessage = true;
    }
    if (!isNextMessage) {
      if ((ref1 = SceneManager._scene.nice_body) != null) {
        ref1.slideOut();
      }
    }
  }
  return _old_terminateMessage_.apply(this);
};
