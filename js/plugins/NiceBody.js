
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
        console.log(SceneManager._scene.nice_body);
        if (SceneManager._scene.nice_body) {
          return SceneManager._scene.nice_body.express = args[1];
        }
    }
  }
};

parameters = PluginManager.parameters('NiceBody');

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

this.NiceBody = (function(superClass) {
  extend(NiceBody, superClass);

  function NiceBody() {
    var actor_id, elem, j, len, ref, sprite;
    this.initialize.call(this);
    this.express_prefix = String(parameters['EXPRESS_PREFIX'] || "exp_");
    this.orders = String(parameters['ORDER'] || "backhair|nakedbody|Head|Body|fronthair|Accessory").split("|");
    actor_id = Number(parameters['ACTOR_ID'] || "1");
    this._actor = $gameActors.actor(actor_id);
    this.express = "normal";
    this.x = Graphics.width - 320;
    this.express_sprite_ids = [];
    this.sprites = (function() {
      var j, len, ref, results;
      ref = this.orders;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        elem = ref[j];
        results.push(new Sprite());
      }
      return results;
    }).call(this);
    ref = this.sprites;
    for (j = 0, len = ref.length; j < len; j++) {
      sprite = ref[j];
      sprite.blendMode = PIXI.blendModes.NORMAL;
      this.addChild(sprite);
    }
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
    console.log(fn);
    return ImageManager.loadPicture(fn);
  };

  NiceBody.prototype.refresh = function() {
    var elem, i, j, len, ref;
    ref = this.orders;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      elem = ref[i];
      if (elem.split(",")[0] === "express") {
        this.express_sprite_ids.push(i);
      }
      this.sprites[i].bitmap = this.generateBitmap(elem);
    }
    return this.old_express = this.express;
  };

  NiceBody.prototype.update = function() {
    var id, j, len, ref;
    if (this.express !== this.old_express) {
      ref = this.express_sprite_ids;
      for (j = 0, len = ref.length; j < len; j++) {
        id = ref[j];
        this.sprites[id].bitmap = this.generateBitmap(this.orders[id]);
      }
      return this.old_express = this.express;
    }
  };

  return NiceBody;

})(this.Sprite);
