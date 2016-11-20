
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

  @param HITTED_EXPRESS
  @desc EXPRESS WILL BE PLAYED WHEN HITTED BY ENEMIES
  @default hitted

  @param ATTACK_EXPRESS
  @desc Express will be played when actor attacks.
  @default 624
 */
var _NiceBody_Alias_BattleManager_startAction, _NiceBody_Alias_Spriteset_Battle_createLowerLayer, _NiceBody_Alias_Spriteset_Battle_update, _Nicebody_Alias_Game_Interpreter_pluginCommand, _Nicebody_Alias_Scene_Map_createDisplayObjects, parameters,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_NiceBody_Alias_BattleManager_startAction = this.BattleManager.startAction;

this.BattleManager.startAction = function() {
  _NiceBody_Alias_BattleManager_startAction.call(this);
  if (SceneManager._scene._spriteset.nice_body) {
    return SceneManager._scene._spriteset.nice_body.playBattleExpress(this._subject, this._targets);
  }
};

_NiceBody_Alias_Spriteset_Battle_createLowerLayer = this.Spriteset_Battle.prototype.createLowerLayer;

this.Spriteset_Battle.prototype.createLowerLayer = function() {
  _NiceBody_Alias_Spriteset_Battle_createLowerLayer.call(this);
  this.nice_body = new NiceBody;
  this._baseSprite.addChild(this.nice_body);
  return this.nice_body.slideIn();
};

_NiceBody_Alias_Spriteset_Battle_update = this.Spriteset_Battle.prototype.update;

this.Spriteset_Battle.prototype.update = function() {
  this.nice_body.update4Battle();
  return _NiceBody_Alias_Spriteset_Battle_update.call(this);
};

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
          return SceneManager._scene.nice_body.slideIn();
        }
        break;
      case "hide":
        if (SceneManager._scene.nice_body) {
          return SceneManager._scene.nice_body.slideOut();
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


/*
_Nicebody_Alias_Scene_Map_update = @Scene_Map.prototype.update
@Scene_Map.prototype.update = ()->
  _Nicebody_Alias_Scene_Map_update.apply(this,arguments)
  @nice_body.update()
 */

parameters = PluginManager.parameters('NiceBody');

this.NiceBody = (function(superClass) {
  extend(NiceBody, superClass);

  function NiceBody() {
    var actor_id;
    this.initialize.call(this);
    this.express_prefix = String(parameters['EXPRESS_PREFIX'] || "exp_");
    this.hitted_express = String(parameters['HITTED_EXPRESS'] || "hitted");
    this.attack_express = String(parameters['ATTACK_EXPRESS'] || "laugh");
    this.orders = String(parameters['ORDER'] || "backhair|nakedbody|Head|Body|fronthair|Accessory").split("|");
    actor_id = Number(parameters['ACTOR_ID'] || "1");
    this._actor = $gameActors.actor(actor_id);
    this.express = "normal";
    this.anchor = new Point(0.5, 1);
    this.opacity = 0;
    this.express_sprite_ids = [];
    this.pic_width = Number(parameters['WIDTH'] || 431);
    this.pic_height = Number(parameters['HEIGHT'] || 624);
    this.x = Graphics.width - 120 + 80;
    this.y = this.pic_height;
    this.bitmap = new Bitmap(this.pic_width, this.pic_height);
    this.alreadySlidedIn = false;
    this.refresh();
  }

  NiceBody.prototype.playExpressHitted = function() {
    return this.express = this.hitted_express;
  };

  NiceBody.prototype.playExpressAttack = function() {
    return this.express = this.attack_express;
  };

  NiceBody.prototype.playBattleExpress = function(sub, targets) {
    if (sub === this._actor) {
      if (targets && targets.indexOf(this._actor) < 0) {
        this.playExpressAttack();
        return this.back_to_normal_express = 60;
      }
    } else if (targets && targets.indexOf(this._actor) >= 0) {
      this.playExpressHitted();
      return this.back_to_normal_express = 60;
    }
  };

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
    var already_blted, elem, i, j, k, len, len1, ref, ref1, srcs, startBlt;
    srcs = [];
    already_blted = false;
    startBlt = function() {
      var j, k, len, len1, results, src;
      if (already_blted) {
        return;
      }
      for (j = 0, len = srcs.length; j < len; j++) {
        src = srcs[j];
        if (!src.isReady()) {
          return;
        }
      }
      already_blted = true;
      this.bitmap.clear();
      results = [];
      for (k = 0, len1 = srcs.length; k < len1; k++) {
        src = srcs[k];
        results.push(this.bitmap.blt(src, 0, 0, this.pic_width, this.pic_height, 0, 0));
      }
      return results;
    };
    ref = this.orders;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      elem = ref[i];
      srcs[i] = this.generateBitmap(elem);
    }
    ref1 = this.orders;
    for (i = k = 0, len1 = ref1.length; k < len1; i = ++k) {
      elem = ref1[i];
      srcs[i].addLoadListener(startBlt.bind(this));
    }
    startBlt();
    return this.old_express = this.express;
  };

  NiceBody.prototype.update4Battle = function() {
    var animation, data, delay, mirror, results;
    results = [];
    while (this._actor.isAnimationRequested()) {
      data = this._actor.shiftAnimation(true);
      animation = $dataAnimations[data.animationId];
      mirror = data.mirror;
      delay = 0;
      if (animation.position !== 3) {
        delay = data.delay;
      }
      results.push(this.startAnimation(animation, mirror, delay));
    }
    return results;
  };

  NiceBody.prototype.update = function() {
    NiceBody.__super__.update.apply(this, arguments);
    if (this.express !== this.old_express) {
      this.refresh();
      this.old_express = this.express;
    }
    if (this.back_to_normal_express) {
      this.back_to_normal_express -= 1;
      if (this.back_to_normal_express === 0) {
        this.express = "normal";
        return this.back_to_normal_express = false;
      }
    }
  };

  NiceBody.prototype.slideIn = function(func) {
    this.opacity = 0;
    this.x = Graphics.width - 120 + 80;
    AnimateItDefaultCurve(this, "x", Graphics.width - 120, 30, "easeOut");
    AnimateItDefaultCurve(this, "opacity", 255, 30, "easeOut", func);
    return this.alreadySlidedIn = true;
  };

  NiceBody.prototype.slideOut = function(func) {
    this.opacity = 255;
    this.x = Graphics.width - 120;
    AnimateItDefaultCurve(this, "x", Graphics.width, 30, "easeIn");
    AnimateItDefaultCurve(this, "opacity", 0, 30, "easeIn", func);
    return this.alreadySlidedIn = false;
  };

  return NiceBody;

})(this.Sprite_Base);
