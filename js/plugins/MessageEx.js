
/*:
    @plugindesc Display character pictures when talking.
    @author ZumiKua
 */
var _MessageEx_Alias_Window_Message_convertEscapeCharacters, _MessageEx_Alias_Window_Message_initialize, _old_terminateMessage_;

_MessageEx_Alias_Window_Message_initialize = this.Window_Message.prototype.initialize;

this.Window_Message.prototype.initialize = function() {
  _MessageEx_Alias_Window_Message_initialize.apply(this, arguments);
  this.leftCharacter = new Sprite();
  this.leftShowing = "";
  this.rightCharacter = new Sprite();
  this.rightShowing = "";
  this.leftCharacter.y = -Graphics.height + this.height;
  this.rightCharacter.y = -Graphics.height + this.height;
  this.addChildAt(this.leftCharacter, 0);
  return this.addChildAt(this.rightCharacter, 0);
};

_MessageEx_Alias_Window_Message_convertEscapeCharacters = this.Window_Message.prototype.convertEscapeCharacters;

this.Window_Message.prototype.convertEscapeCharacters = function(text) {
  text = _MessageEx_Alias_Window_Message_convertEscapeCharacters.apply(this, arguments);
  text = text.replace(/\x1bS/gi, (function() {
    var ref;
    if (this.rightShowing !== "") {
      AnimateItDefaultCurve(this.rightCharacter, "x", Graphics.width, 30, "easeIn");
      AnimateItDefaultCurvePromiseVersion(this.rightCharacter, "opacity", 0, 30, "easeIn").then(function() {
        var ref;
        return (ref = SceneManager._scene.nice_body) != null ? ref.slideIn() : void 0;
      });
    } else {
      if ((ref = SceneManager._scene.nice_body) != null) {
        ref.slideIn();
      }
    }
    return "";
  }).bind(this));
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
  text = text.replace(/\x1bL\[(\w*)\]/gi, (function(_, exp) {
    var showFunc;
    showFunc = function() {
      this.leftCharacter.bitmap = ImageManager.loadPicture(exp);
      this.leftShowing = exp;
      return this.leftCharacter.bitmap.mustDo(function(bit) {
        this.leftCharacter.x = -bit.width;
        this.leftCharacter.opacity = 0;
        AnimateItDefaultCurve(this.leftCharacter, "x", 0, 30, "easeOut");
        AnimateItDefaultCurve(this.leftCharacter, "opacity", 255, 30, "easeOut");
        return console.log(this.leftCharacter.update);
      }, this);
    };
    if (this.leftShowing !== exp && this.leftShowing !== "") {
      AnimateItDefaultCurve(this.leftCharacter, "x", -this.leftCharacter.bitmap.width, 30, "easeIn");
      AnimateItDefaultCurve(this.leftCharacter, "opacity", 0, 30, "easeIn", showFunc.bind(this));
    } else {
      showFunc.call(this);
    }
    return "";
  }).bind(this));
  text = text.replace(/\x1bR\[(\w*)\]/gi, (function(_, exp) {
    var ref, showFunc;
    showFunc = function() {
      this.rightCharacter.bitmap = ImageManager.loadPicture(exp);
      this.rightShowing = exp;
      return this.rightCharacter.bitmap.mustDo(function(bit) {
        this.rightCharacter.x = Graphics.width;
        this.rightCharacter.opacity = 0;
        AnimateItDefaultCurve(this.rightCharacter, "x", Graphics.width - this.rightCharacter.bitmap.width, 30, "easeOut");
        return AnimateItDefaultCurve(this.rightCharacter, "opacity", 255, 30, "easeOut");
      }, this);
    };
    if (((ref = SceneManager._scene.nice_body) != null ? ref.alreadySlidedIn : void 0)) {
      console.log("xx");
      SceneManager._scene.nice_body.slideOut(showFunc.bind(this));
    } else if (this.rightShowing !== exp && this.rightShowing !== "") {
      AnimateItDefaultCurve(this.rightCharacter, "x", Graphics.width, 30, "easeIn");
      AnimateItDefaultCurve(this.rightCharacter, "opacity", 0, 30, "easeIn", showFunc.bind(this));
    } else {
      showFunc.call(this);
    }
    return "";
  }).bind(this));
  return text;
};

_old_terminateMessage_ = this.Window_Message.prototype.terminateMessage;

this.Window_Message.prototype.terminateMessage = function() {
  var isNextMessage, nxtCode, ref, ref1, ref2;
  if (SceneManager._scene instanceof Scene_Map) {
    isNextMessage = false;
    nxtCode = (ref = $gameMap._interpreter.currentCommand()) != null ? ref.code : void 0;
    if (nxtCode >= 101 && nxtCode <= 104) {
      isNextMessage = true;
    }
    if (!isNextMessage) {
      if ((ref1 = SceneManager._scene.nice_body) != null ? ref1.alreadySlidedIn : void 0) {
        if ((ref2 = SceneManager._scene.nice_body) != null) {
          ref2.slideOut();
        }
      }
      if (this.rightShowing !== "") {
        AnimateItDefaultCurve(this.rightCharacter, "x", Graphics.width, 30, "easeIn");
        AnimateItDefaultCurve(this.rightCharacter, "opacity", 0, 30, "easeIn");
      }
      if (this.leftShowing !== "") {
        AnimateItDefaultCurve(this.leftCharacter, "x", -this.leftCharacter.bitmap.width, 30, "easeIn");
        AnimateItDefaultCurve(this.leftCharacter, "opacity", 0, 30, "easeIn");
      }
    }
  }
  return _old_terminateMessage_.apply(this);
};
