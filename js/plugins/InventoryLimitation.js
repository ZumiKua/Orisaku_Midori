var Window_TransferItemList, Window_TransferNumber, _infinityInventory_Alias_gainItem, _infinityInventory_Alias_initAllItems,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_infinityInventory_Alias_initAllItems = this.Game_Party.prototype.initAllItems;

this.Game_Party.prototype.initAllItems = function() {
  var i, len, method, ref;
  _infinityInventory_Alias_initAllItems.call(this);
  this.infinityInventory = {};
  ref = ["items", "weapons", "armors", "equipItems", "allItems", "hasItem", "hasMaxItems", "gainItem", "isAnyMemberEquipped", "discardMembersEquip", "loseItem", "itemContainer", "numItems"];
  for (i = 0, len = ref.length; i < len; i++) {
    method = ref[i];
    this.infinityInventory[method] = this[method];
  }
  this.infinityInventory._items = {};
  this.infinityInventory._weapons = {};
  this.infinityInventory._armors = {};
  this.infinityInventory.members = function() {
    return [];
  };
  return this.infinityInventory.maxItems = function() {
    return 99;
  };
};

this.Game_Party.prototype.maxItems = function(item) {
  return Number(item.meta.maxNum || 99);
};

this.Game_Party.prototype.transferItems = function(src, dest, item, count) {
  if (src.numItems(item) < count) {
    count = src.numItems(item);
  }
  src.loseItem(item, count);
  return dest.gainItem(item, count);
};

this.Game_Party.prototype.transferToInfinityInventory = function(item, count) {
  return this.transferItems(this, this.infinityInventory, item, count);
};

this.Game_Party.prototype.transferToPlayerInventory = function(item, count) {
  if (this.maxItems(item) < this.numItems(item) + count) {
    count = this.maxItems(item) - this.numItems(item);
  }
  return this.transferItems(this.infinityInventory, this, item, count);
};

_infinityInventory_Alias_gainItem = this.Game_Party.prototype.gainItem;

this.Game_Party.prototype.gainItem = function(item, count, includeEquip) {
  var boxCount;
  if (this instanceof Game_Party) {
    if (this.numItems(item) + count > this.maxItems(item)) {
      boxCount = count - (this.maxItems(item) - this.numItems(item));
      count -= boxCount;
      this.infinityInventory.gainItem(item, boxCount, includeEquip);
    }
    _infinityInventory_Alias_gainItem.call(this, item, count, includeEquip);
    return [count, boxCount];
  } else {
    return _infinityInventory_Alias_gainItem.call(this, item, count, includeEquip);
  }
};

Window_TransferItemList = (function(superClass) {
  extend(Window_TransferItemList, superClass);

  function Window_TransferItemList(itembox) {
    this.itembox = itembox;
    this.initialize(0, this.fittingHeight(2), Graphics.width / 2, Graphics.height - this.fittingHeight(2));
    this.refresh();
    this.resetScroll();
  }

  Window_TransferItemList.prototype.isEnabled = function(item) {
    if (this.itembox instanceof Game_Party) {
      return true;
    } else {
      return $gameParty.numItems(item) < $gameParty.maxItems(item);
    }
  };

  Window_TransferItemList.prototype.maxCols = function() {
    return 1;
  };

  Window_TransferItemList.prototype.selectLast = function() {
    return 0;
  };

  Window_TransferItemList.prototype.makeItemList = function() {
    this._data = this.itembox.allItems();
    if (this._data.length === 0) {
      return this._data = [null];
    }
  };

  Window_TransferItemList.prototype.cursorRight = function() {
    if (this.cursorRightHandler) {
      return this.cursorRightHandler();
    }
  };

  Window_TransferItemList.prototype.cursorLeft = function() {
    if (this.cursorLeftHandler) {
      return this.cursorLeftHandler();
    }
  };

  Window_TransferItemList.prototype.drawItemNumber = function(item, x, y, width) {
    if (this.needsNumber()) {
      this.drawText(':', x, y, width - this.textWidth('00'), 'right');
      return this.drawText(this.itembox.numItems(item), x, y, width, 'right');
    }
  };

  return Window_TransferItemList;

})(Window_ItemList);

Window_TransferNumber = (function(superClass) {
  extend(Window_TransferNumber, superClass);

  function Window_TransferNumber() {
    var height, width;
    width = 200;
    height = 100;
    this.initialize((Graphics.width - width) / 2, (Graphics.height - height) / 2, width, height);
    this.openness = 0;
    this._number = 0;
  }

  Window_TransferNumber.prototype.setup = function(_max) {
    this._max = _max;
    this._number = 1;
    return this.refresh();
  };

  Window_TransferNumber.prototype.addNumber = function(num) {
    this._number += num;
    this._number = this._number.clamp(1, this._max);
    return this.refresh();
  };

  Window_TransferNumber.prototype.number = function() {
    return this._number;
  };

  Window_TransferNumber.prototype.refresh = function() {
    this.contents.clear();
    this.drawMultiplicationSign();
    return this.drawNumber();
  };

  Window_TransferNumber.prototype.update = function() {
    Window_TransferNumber.__super__.update.call(this);
    if (Input.isRepeated("right")) {
      this.addNumber(1);
    }
    if (Input.isRepeated("left")) {
      this.addNumber(-1);
    }
    if (Input.isRepeated("up")) {
      this.addNumber(10);
    }
    if (Input.isRepeated("down")) {
      return this.addNumber(-10);
    }
  };

  Window_TransferNumber.prototype.drawNumber = function() {
    return this.drawText(this._number, 0, (this.contents.height - this.lineHeight()) / 2, this.contents.width, "right");
  };

  Window_TransferNumber.prototype.drawMultiplicationSign = function() {
    return this.drawText("×", 0, (this.contents.height - this.lineHeight()) / 2, this.contents.width - 72, "right");
  };

  Window_TransferNumber.prototype.updateCursor = function() {
    return this.setCursorRect(this.contents.width - 54, (this.contents.height - this.lineHeight()) / 2, 60, this.lineHeight());
  };

  return Window_TransferNumber;

})(Window_Selectable);

this.Scene_Transfer = (function(superClass) {
  extend(Scene_Transfer, superClass);

  function Scene_Transfer() {
    this.initialize();
  }

  Scene_Transfer.prototype.create = function() {
    Scene_Transfer.__super__.create.call(this);
    this.bg = new Sprite();
    this.bg.bitmap = SceneManager.backgroundBitmap();
    this.addChild(this.bg);
    this.createWindowLayer();
    this.playerInventoryWindow = new Window_TransferItemList($gameParty);
    this.playerInventoryWindow.cursorRightHandler = this.onRight.bind(this);
    this.boxInventoryWindow = new Window_TransferItemList($gameParty.infinityInventory);
    this.boxInventoryWindow.x = Graphics.width / 2;
    this.boxInventoryWindow.cursorLeftHandler = this.onLeft.bind(this);
    this.playerInventoryWindow.setHandler("ok", this.onPlayerOk.bind(this));
    this.boxInventoryWindow.setHandler("ok", this.onBoxOk.bind(this));
    this.playerInventoryWindow.setHandler("cancel", this.popScene.bind(this));
    this.boxInventoryWindow.setHandler("cancel", this.popScene.bind(this));
    this.numberWindow = new Window_TransferNumber();
    this.numberWindow.setHandler("ok", this.onNumberOk.bind(this));
    this.helpWindow = new Window_Help();
    this.playerInventoryWindow.setHelpWindow(this.helpWindow);
    this.boxInventoryWindow.setHelpWindow(this.helpWindow);
    this.addWindow(this.helpWindow);
    this.addWindow(this.playerInventoryWindow);
    this.addWindow(this.boxInventoryWindow);
    this.addWindow(this.numberWindow);
    this.playerInventoryWindow.activate();
    this.playerInventoryWindow.select(0);
    this.box_index = 0;
    return this.player_index = 0;
  };

  Scene_Transfer.prototype.onRight = function() {
    this.playerInventoryWindow.deactivate();
    this.player_index = this.playerInventoryWindow.index();
    this.playerInventoryWindow.deselect();
    this.boxInventoryWindow.activate();
    this.boxInventoryWindow.select(this.box_index);
    return SoundManager.playCursor();
  };

  Scene_Transfer.prototype.onLeft = function() {
    this.playerInventoryWindow.activate();
    this.playerInventoryWindow.select(this.player_index);
    this.boxInventoryWindow.deactivate();
    this.box_index = this.boxInventoryWindow.index();
    this.boxInventoryWindow.deselect();
    return SoundManager.playCursor();
  };

  Scene_Transfer.prototype.onPlayerOk = function() {
    this.numberWindow.open();
    this.numberWindow.activate();
    this.numberWindow.setup($gameParty.numItems(this.playerInventoryWindow.item()));
    this.type = 1;
    return SoundManager.playOk();
  };

  Scene_Transfer.prototype.onBoxOk = function() {
    var num, num2;
    this.numberWindow.open();
    this.numberWindow.activate();
    num = $gameParty.infinityInventory.numItems(this.boxInventoryWindow.item());
    num2 = $gameParty.maxItems(this.boxInventoryWindow.item()) - $gameParty.numItems(this.boxInventoryWindow.item());
    if (num > num2) {
      num = num2;
    }
    this.numberWindow.setup(num);
    this.type = 2;
    return SoundManager.playOk();
  };

  Scene_Transfer.prototype.onNumberOk = function() {
    var item, number;
    switch (this.type) {
      case 1:
        item = this.playerInventoryWindow.item();
        number = this.numberWindow.number();
        $gameParty.transferToInfinityInventory(item, number);
        this.playerInventoryWindow.activate();
        break;
      case 2:
        $gameParty.transferToPlayerInventory(this.boxInventoryWindow.item(), this.numberWindow.number());
        this.boxInventoryWindow.activate();
    }
    this.numberWindow.close();
    this.playerInventoryWindow.refresh();
    this.boxInventoryWindow.refresh();
    return SoundManager.playOk();
  };

  Scene_Transfer.prototype.onNumberCancel = function() {
    switch (this.type) {
      case 1:
        return this.playerInventoryWindow.activate();
      case 2:
        return this.boxInventoryWindow.activate();
    }
  };

  return Scene_Transfer;

})(this.Scene_Base);
