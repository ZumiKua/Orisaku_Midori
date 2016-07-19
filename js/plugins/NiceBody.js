
/*:
  @plugindesc	Show the nice body of our character and her beautiful clothes.
  @author	ZumiKua
  @param	ORDER
  @desc	The order of the layer.First one is at the bottom.If the elements match
        the equipment type, the layer specified by the note <pic:#{picname}> will
        be displayed. Otherwise the picture with this name will be displayed.
        "express" means express layer.
        Use "|" to split the layer array.
  @default	backhair|nakedbody|Head|Body|fronthair|Accessory
  @param	ACTOR_ID
  @desc	The ID of actor who is displayed.
  @default	1
  @param EXPRESS_PREFIX
  @desc the prefix of express picture.
  @default exp_
  @param WIDTH
  @desc the width of pictures.
  @default 431
  @param HEIGHT
  @desc the height of pictures.
  @default 624
 */
var _Nicebody_Alias_Game_Interpreter_pluginCommand, _Nicebody_Alias_Scene_Map_createDisplayObjects, _Nicebody_Alias_Scene_Map_update, parameters,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_Nicebody_Alias_Game_Interpreter_pluginCommand = Game_Interpreter.prototype.pluginCommand;

this.Game_Interpreter.prototype.pluginCommand = function(command, args) {
  _Nicebody_Alias_Game_Interpreter_pluginCommand.call(this, command, args);
  if (command === 'NiceBody') {
    switch (args[0]) {
      case "playExpress":
        if (SceneManager._scene.nice_body) {
          return SceneManager._scene.nice_body.express = args[1];
        }
        break;
      case "show":
        if (SceneManager._scene.nice_body) {
          return SceneManager._scene.nice_body.show();
        }
        break;
      case "hide":
        if (SceneManager._scene.nice_body) {
          return SceneManager._scene.nice_body.hide();
        }
    }
  }
};

_Nicebody_Alias_Scene_Map_createDisplayObjects = this.Scene_Map.prototype.createDisplayObjects;

this.Scene_Map.prototype.createDisplayObjects = function() {
  _Nicebody_Alias_Scene_Map_createDisplayObjects.apply(this, arguments);
  this.nice_body = new NiceBody();
  return this.addChildAt(this.nice_body, 1);
};

_Nicebody_Alias_Scene_Map_update = this.Scene_Map.prototype.update;

this.Scene_Map.prototype.update = function() {
  _Nicebody_Alias_Scene_Map_update.apply(this, arguments);
  return this.nice_body.update();
};

parameters = PluginManager.parameters('NiceBody');

this.NiceBody = (function(superClass) {
  extend(NiceBody, superClass);

  function NiceBody() {
    var actor_id;
    this.initialize.call(this);
    this.express_prefix = String(parameters['EXPRESS_PREFIX'] || "exp_");
    this.orders = String(parameters['ORDER'] || "backhair|nakedbody|Head|Body|fronthair|Accessory").split("|");
    actor_id = Number(parameters['ACTOR_ID'] || "1");
    this._actor = $gameActors.actor(actor_id);
    this.express = "normal";
    this.x = Graphics.width - 320 + 40;
    this.opacity = 0;
    this.express_sprite_ids = [];
    this.pic_width = Number(parameters['WIDTH'] || 431);
    this.pic_height = Number(parameters['HEIGHT'] || 624);
    this.refresh();
  }

  NiceBody.prototype.generateBitmap = function(full_elem) {
    var elem, etype, fn, i, j, len, match_result, part, ref, splited_elem, v;
    splited_elem = full_elem.split(",");
    elem = splited_elem[0];
    part = splited_elem[1];
    fn = elem;
    if (elem === "express") {
      fn = this.express_prefix + this.express;
    }
    ref = $dataSystem.equipTypes;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      etype = ref[i];
      if (etype === elem) {
        fn = this._actor.equips()[i - 1].meta.pic;
        break;
      }
    }
    if ((match_result = /v\[(\d+)\]/.exec(elem))) {
      v = Number(match_result[1]);
      if ($gameVariables[v]) {
        fn = "v_" + v + "_" + $gameVariables[v];
      } else {
        fn = "v_" + v + "_0";
      }
    }
    if (part) {
      fn += "_" + part;
    }
    return ImageManager.loadPicture(fn);
  };

  NiceBody.prototype.refresh = function() {
    var already_blted, elem, fflag, i, j, k, l, len, len1, len2, len3, m, ref, ref1, src, srcs;
    this.bitmap = new Bitmap(this.pic_width, this.pic_height);
    srcs = [];
    already_blted = false;
    ref = this.orders;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      elem = ref[i];
      srcs[i] = this.generateBitmap(elem);
    }
    ref1 = this.orders;
    for (i = k = 0, len1 = ref1.length; k < len1; i = ++k) {
      elem = ref1[i];
      srcs[i].addLoadListener((function(self) {
        var flag, l, len2, len3, m, src;
        if (already_blted) {
          return;
        }
        flag = true;
        for (l = 0, len2 = srcs.length; l < len2; l++) {
          src = srcs[l];
          if (!src.isReady()) {
            flag = false;
          }
        }
        if (flag) {
          already_blted = true;
          console.log(self);
          for (m = 0, len3 = srcs.length; m < len3; m++) {
            src = srcs[m];
            this.bitmap.blt(src, 0, 0, this.pic_width, this.pic_height, 0, 0);
          }
        }
        return 0;
      }).bind(this, srcs[i]));
    }
    fflag = true;
    for (l = 0, len2 = srcs.length; l < len2; l++) {
      src = srcs[l];
      if (!src.isReady()) {
        fflag = false;
      }
    }
    if (fflag) {
      already_blted = true;
      for (m = 0, len3 = srcs.length; m < len3; m++) {
        src = srcs[m];
        this.bitmap.blt(src, 0, 0, this.pic_width, this.pic_height, 0, 0);
      }
    }
    return this.old_express = this.express;
  };

  NiceBody.prototype.update = function() {
    if (this.express !== this.old_express) {
      this.refresh();
      this.old_express = this.express;
    }
    if (this.showing) {
      this.x -= 5;
      this.opacity += 13;
      if (this.x <= Graphics.width - 320) {
        this.x = Graphics.width - 320;
        this.showing = false;
        this.opacity = 255;
      }
    }
    if (this.hiding) {
      this.x += 5;
      this.opacity -= 13;
      if (this.x >= Graphics.width - 320 + 80) {
        this.x = Graphics.width - 320 + 80;
        this.hiding = false;
        return this.opacity = 0;
      }
    }
  };

  NiceBody.prototype.show = function() {
    this.hiding = false;
    this.showing = true;
    this.opacity = 0;
    return this.x = Graphics.width - 320 + 80;
  };

  NiceBody.prototype.hide = function() {
    this.showing = false;
    this.hiding = true;
    this.opacity = 255;
    return this.x = Graphics.width - 320;
  };

  return NiceBody;

})(this.Sprite);
