
/*:
    @plugindesc Add a hint when you get item.
    @author IamI

    @param gainItemHint
    @default 获得了

    @param loseItemHint
    @default 失去了

    @param boxHint
    @default 道具箱：%NUM%

    @param hintWindowDurations
    @desc How much durations the Hint Window will appear, not including close time
    @default 120
 */
var GainItemHintHelper, Window_GainItem, _GainItemHint_Alias_Game_Interpreter_Command125, _GainItemHint_Alias_Game_Interpreter_Command126, _GainItemHint_Alias_Game_Interpreter_Command127, _GainItemHint_Alias_Game_Interpreter_Command128, gainItemParameters,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

gainItemParameters = PluginManager.parameters("GainItemHint");

Window_GainItem = (function(superClass) {
  extend(Window_GainItem, superClass);

  function Window_GainItem() {
    this.initialize.call(this);
    this.datas = [];
  }

  Window_GainItem.prototype.addGold = function(count) {
    var item;
    item = TextManager.currencyUnit;
    return this.datas.push([item, count, null]);
  };

  Window_GainItem.prototype.addItem = function(itemId, count1, count2) {
    var item;
    item = $dataItems[itemId];
    return this.datas.push([item, count1, count2]);
  };

  Window_GainItem.prototype.addWeapon = function(weaponId, count1, count2) {
    var weapon;
    weapon = $dataWeapons[weaponId];
    return this.datas.push([weapon, count1, count2]);
  };

  Window_GainItem.prototype.addArmor = function(armorId, count1, count2) {
    var armor;
    armor = $dataArmors[armorId];
    return this.datas.push([armor, count1, count2]);
  };

  Window_GainItem.prototype.clear = function() {
    return this.datas = [];
  };

  Window_GainItem.prototype.refresh = function() {
    var array, box_str, count, count2, data, hintText, i, len, order, ref, results, x, y;
    this.resize();
    order = 0;
    ref = this.datas;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      array = ref[i];
      data = array[0];
      count = array[1];
      count2 = array[2];
      hintText = count >= 0 ? gainItemParameters.gainItemHint : gainItemParameters.loseItemHint;
      y = order * this.lineHeight();
      x = this.textPadding() * 2 + this.contents.measureTextWidth(hintText);
      this.changeTextColor(this.systemColor());
      this.contents.drawText(hintText, this.textPadding(), y, this.contents.width, this.lineHeight());
      this.resetTextColor();
      if (data !== TextManager.currencyUnit) {
        this.drawItemName(data, x, y, this.contents.width);
        this.contents.drawText("X " + Math.abs(count), 0, y, this.contents.width, this.lineHeight(), 'right');
        if (count2 > 0) {
          box_str = gainItemParameters.boxHint.replace("%NUM%", Math.abs(count2));
          console.log(box_str);
          this.contents.drawText(box_str, 0, y + this.lineHeight(), this.contents.width, this.lineHeight(), 'right');
          order += 1;
        }
      } else {
        this.drawCurrencyValue(count, data, 0, y, this.contents.width);
      }
      results.push(order += 1);
    }
    return results;
  };

  Window_GainItem.prototype.resize = function() {
    var height, width, x, y;
    width = 400;
    height = this.datas.length * this.lineHeight() + this.standardPadding() * 2;
    x = (Graphics.boxWidth - width) / 2;
    y = (Graphics.boxHeight - height) / 2;
    this.move(x, y, width, height);
    this.createContents();
    return this.contents.fontSize = 24;
  };

  Window_GainItem.prototype.update = function() {
    Window_Base.prototype.update.call(this);
    if (Input.isTriggered('ok') || Input.isTriggered('cancel')) {
      return this.close();
    }
  };

  return Window_GainItem;

})(Window_Base);

_GainItemHint_Alias_Game_Interpreter_Command125 = Game_Interpreter.prototype.command125;

_GainItemHint_Alias_Game_Interpreter_Command126 = Game_Interpreter.prototype.command126;

_GainItemHint_Alias_Game_Interpreter_Command127 = Game_Interpreter.prototype.command127;

_GainItemHint_Alias_Game_Interpreter_Command128 = Game_Interpreter.prototype.command128;

Game_Interpreter.prototype.command125 = function() {
  var result, value;
  console.log("I run!");
  result = _GainItemHint_Alias_Game_Interpreter_Command125.call(this);
  GainItemHintHelper.checkGainHintWindow();
  value = this.operateValue(this._params[0], this._params[1], this._params[2]);
  GainItemHintHelper.gainItemHintWindow.addGold(value);
  if (!this.nextCommandIsItem()) {
    GainItemHintHelper.showGainHintWindow();
  }
  return result;
};

Game_Interpreter.prototype.command126 = function() {
  var arr, bv, v, value;
  value = this.operateValue(this._params[1], this._params[2], this._params[3]);
  arr = $gameParty.gainItem($dataItems[this._params[0]], value);
  v = arr[0];
  bv = arr[1];
  GainItemHintHelper.checkGainHintWindow();
  GainItemHintHelper.gainItemHintWindow.addItem(this._params[0], v, bv);
  if (!this.nextCommandIsItem()) {
    GainItemHintHelper.showGainHintWindow();
  }
  return true;
};

Game_Interpreter.prototype.command127 = function() {
  var arr, bv, v, value;
  value = this.operateValue(this._params[1], this._params[2], this._params[3]);
  arr = $gameParty.gainItem($dataWeapons[this._params[0]], value, this._params[4]);
  v = arr[0];
  bv = arr[1];
  GainItemHintHelper.checkGainHintWindow();
  GainItemHintHelper.gainItemHintWindow.addWeapon(this._params[0], v, bv);
  if (!this.nextCommandIsItem()) {
    GainItemHintHelper.showGainHintWindow();
  }
  return true;
};

Game_Interpreter.prototype.command128 = function() {
  var arr, bv, v, value;
  value = this.operateValue(this._params[1], this._params[2], this._params[3]);
  arr = $gameParty.gainItem($dataArmors[this._params[0]], value, this._params[4]);
  v = arr[0];
  bv = arr[1];
  GainItemHintHelper.checkGainHintWindow();
  GainItemHintHelper.gainItemHintWindow.addArmor(this._params[0], v, bv);
  if (!this.nextCommandIsItem()) {
    GainItemHintHelper.showGainHintWindow();
  }
  return true;
};

Game_Interpreter.prototype.nextCommandIsItem = function() {
  var code;
  code = this.nextEventCode();
  if (code === 125 || code === 126 || code === 127 || code === 128) {
    return true;
  }
  return false;
};

GainItemHintHelper = function() {
  throw new Error('This is a static class!');
};

GainItemHintHelper.checkGainHintWindow = function() {
  if (!GainItemHintHelper.gainItemHintWindow) {
    return GainItemHintHelper.gainItemHintWindow = new Window_GainItem;
  }
};

GainItemHintHelper.showGainHintWindow = function() {
  GainItemHintHelper.checkGainHintWindow();
  GainItemHintHelper.gainItemHintWindow.refresh();
  GainItemHintHelper.gainItemHintWindow.clear();
  GainItemHintHelper.gainItemHintWindow.openness = 0;
  GainItemHintHelper.stickInScene();
  SceneManager._scene.stickedWaitingCount = parseInt(gainItemParameters.hintWindowDurations) || 120;
  SceneManager._scene.stickedWindow = GainItemHintHelper.gainItemHintWindow;
  SceneManager._scene.addChild(GainItemHintHelper.gainItemHintWindow);
  GainItemHintHelper.gainItemHintWindow.open();
  return SoundManager.playShop();
};

GainItemHintHelper.stickInScene = function() {
  var scene;
  scene = SceneManager._scene;
  if (scene._normalUpdate) {
    return;
  }
  scene._normalUpdate = scene.update;
  return scene.update = function() {
    if (this.stickedWindow) {
      if (!this.stickedWaitingCount) {
        this.stickedWaitingCount = 1;
      }
      this.stickedWaitingCount -= 1;
      if (this.stickedWaitingCount <= 0) {
        this.stickedWindow.close();
      }
      if (this.stickedWindow.isClosed()) {
        this.removeChild(this.stickedWindow);
        return this.stickedWindow = null;
      } else {
        return Scene_Base.prototype.update.call(this);
      }
    } else {
      return this._normalUpdate();
    }
  };
};
