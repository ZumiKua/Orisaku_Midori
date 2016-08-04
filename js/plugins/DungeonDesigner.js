// Generated by CoffeeScript 1.8.0

/*:
    @plugindesc Help design a Dungeon
    @author IamI

    @param EnemyMap
    @default 7
    @desc Enemy map ID.
 */

(function() {
  var DungeonDesignerParameters, Game_Dungeon, Scene_Dungeon, Window_DungeonHint, Window_DungeonMenu, Window_ItemUseList, Window_PutEnemyEvent, _DungeonDesigner_Alias_Game_Interpreter_command301, _DungeonDesigner_Alias_Scene_Map_create, _DungeonDesigner_Alias_Scene_Map_update,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _DungeonDesigner_Alias_Scene_Map_create = Scene_Map.prototype.create;

  _DungeonDesigner_Alias_Scene_Map_update = Scene_Map.prototype.update;

  _DungeonDesigner_Alias_Game_Interpreter_command301 = Game_Interpreter.prototype.command301;

  DungeonDesignerParameters = PluginManager.parameters("DungeonDesigner");

  Input.keyMapper[121] = 'dungeon';

  Game_Dungeon = (function() {
    function Game_Dungeon() {
      this._isDesigningDungeon = false;
    }

    Game_Dungeon.prototype.start = function() {
      var target;
      target = $gameParty.members()[0];
      this._hp = target.mhp;
      this._maxhp = target.mhp;
      this._mp = target.mmp;
      this._maxmp = target.mmp;
      this._isDesigningDungeon = true;
      return this.loadMap();
    };

    Game_Dungeon.prototype.loadMap = function() {
      var $enemyZoo, fileName, id;
      id = parseInt(DungeonDesignerParameters.EnemyMap).padZero(3);
      fileName = "Map" + id + ".json";
      $enemyZoo = null;
      return DataManager.loadDataFile('$enemyZoo', fileName);
    };

    Game_Dungeon.prototype.preloadCharacters = function() {
      var event, _i, _len, _ref, _results;
      if (!$enemyZoo) {
        return;
      }
      _ref = $enemyZoo.events;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        if (event === null) {
          continue;
        }
        _results.push(ImageManager.loadCharacter(event.pages[0].image.characterName));
      }
      return _results;
    };

    Game_Dungeon.prototype.putEvent = function(event) {};

    Game_Dungeon.prototype.battle = function(troop) {};

    return Game_Dungeon;

  })();

  this.$gameDungeon = new Game_Dungeon();

  Scene_Map.prototype.isDungeonCalled = function() {
    return Input.isTriggered('dungeon') && $gameTemp.isPlaytest();
  };

  Scene_Map.prototype.startDungeon = function() {
    $gameDungeon.start();
    return this.createDungeonHintWindow();
  };

  Scene_Map.prototype.finishDungeon = function() {
    $gameDungeon._isDesigningDungeon = false;
    return this.removeChild(this._dungeonHintWindow);
  };

  Scene_Map.prototype.createDungeonHintWindow = function() {
    this._dungeonHintWindow = new Window_DungeonHint();
    return this.addChild(this._dungeonHintWindow);
  };

  Scene_Map.prototype.callDungeonMenu = function() {
    return SceneManager.push(Scene_Dungeon);
  };

  Scene_Map.prototype.dungeonPressed = function() {
    if ($gameDungeon._isDesigningDungeon) {
      return this.callDungeonMenu();
    } else {
      return this.startDungeon();
    }
  };

  Scene_Map.prototype.create = function() {
    _DungeonDesigner_Alias_Scene_Map_create.call(this);
    if ($gameDungeon._isDesigningDungeon) {
      return this.createDungeonHintWindow();
    }
  };

  Scene_Map.prototype.update = function() {
    _DungeonDesigner_Alias_Scene_Map_update.call(this);
    if (this.isDungeonCalled()) {
      return this.dungeonPressed();
    }
  };

  Game_Interpreter.prototype.command301 = function() {
    var troopId;
    if ($gameDungeon._isDesigningDungeon) {
      if (this._params[0] === 0) {
        troopId = this._params[1];
      } else if (this._params[0] === 1) {
        troopId = $gameVariables.value(this._params[1]);
      } else {
        troopId = $gamePlayer.makeEncounterTroopId();
      }
      $gameDungeon.battle(troopId);
      return true;
    } else {
      return _DungeonDesigner_Alias_Game_Interpreter_command301.call(this);
    }
  };

  Window_Base.prototype.drawCharacter = function(characterName, characterIndex, x, y, px, py) {
    var big, bitmap, n, ph, pw, sx, sy;
    px = px || 1;
    py = py || 0;
    bitmap = ImageManager.loadCharacter(characterName);
    big = ImageManager.isBigCharacter(characterName);
    pw = bitmap.width / (big ? 3 : 12);
    ph = bitmap.height / (big ? 4 : 8);
    n = characterIndex;
    sx = (n % 4 * 3 + px) * pw;
    sy = (Math.floor(n / 4) * 4 + py) * ph;
    return this.contents.blt(bitmap, sx, sy, pw, ph, x - pw / 2, y - ph);
  };

  Window_DungeonHint = (function(_super) {
    __extends(Window_DungeonHint, _super);

    function Window_DungeonHint() {
      var height, width, x, y;
      width = 350;
      height = this.lineHeight() * 2 + this.standardPadding() * 2;
      x = Graphics.boxWidth - width;
      y = 0;
      this.initialize.call(this, x, y, width, height);
      this.refresh();
    }

    Window_DungeonHint.prototype.refresh = function() {
      this.contents.drawText(" 当前 HP " + $gameDungeon._hp + " / " + $gameDungeon._maxhp, 0, 0, this.contents.width, this.lineHeight());
      return this.contents.drawText(" 当前 MP " + $gameDungeon._mp + " / " + $gameDungeon._maxmp, 0, this.lineHeight(), this.contents.width, this.lineHeight());
    };

    return Window_DungeonHint;

  })(Window_Base);

  Scene_Dungeon = (function(_super) {
    __extends(Scene_Dungeon, _super);

    function Scene_Dungeon() {
      this.initialize.call(this);
      $gameDungeon.preloadCharacters();
    }

    Scene_Dungeon.prototype.create = function() {
      Scene_MenuBase.prototype.create.call(this);
      return this.createWindows();
    };

    Scene_Dungeon.prototype.createWindows = function() {
      this._commandWindow = new Window_DungeonMenu();
      this._windowLayer.addChild(this._commandWindow);
      this._eventWindow = new Window_PutEnemyEvent();
      this._eventWindow.openness = 0;
      this._windowLayer.addChild(this._eventWindow);
      this._itemWindow = new Window_ItemUseList($dataSkills);
      this._itemWindow.list = $dataItems;
      this._windowLayer.addChild(this._itemWindow);
      return this._itemWindow.active = true;
    };

    Scene_Dungeon.prototype.update = function() {
      Scene_MenuBase.prototype.update.call(this);
      return this.updateKeys();
    };

    Scene_Dungeon.prototype.updateKeys = function() {
      if (Input.isTriggered('cancel')) {
        return SceneManager.pop();
      }
    };

    return Scene_Dungeon;

  })(Scene_MenuBase);

  Window_DungeonMenu = (function(_super) {
    __extends(Window_DungeonMenu, _super);

    function Window_DungeonMenu() {
      this.initialize.call(this);
      this.x = (Graphics.boxWidth - this.width) / 2;
      this.y = (Graphics.boxHeight - this.height) / 2;
    }

    Window_DungeonMenu.prototype.makeCommandList = function() {
      this.addCommand("在面前放置事件", 'enemy');
      this.addCommand("使用物品", 'item');
      this.addCommand("使用技能", 'skill');
      this.addCommand("生成敌机地图", "createMap", false);
      return this.addCommand("退出设计模式", 'exit');
    };

    return Window_DungeonMenu;

  })(Window_Command);

  Window_PutEnemyEvent = (function(_super) {
    __extends(Window_PutEnemyEvent, _super);

    function Window_PutEnemyEvent() {
      var height, width;
      width = this.windowWidth();
      height = this.windowHeight();
      this.initialize.call(this, 0, 0, width, height);
      this.refresh();
      this._order = 0;
      this._count = 0;
    }

    Window_PutEnemyEvent.prototype.drawItem = function(index, order) {
      var event, image, rect;
      order = order || 0;
      event = $enemyZoo.events[index + 1];
      if (!event) {
        return;
      }
      image = event.pages[0].image;
      rect = this.itemRect(index);
      return this.drawCharacter(image.characterName, image.characterIndex, rect.x + this.itemWidth() / 2, rect.y + this.itemHeight(), 0, order);
    };

    Window_PutEnemyEvent.prototype.maxItems = function() {
      if (!$enemyZoo) {
        return 1;
      }
      return Math.max(1, $enemyZoo.events.length - 1);
    };

    Window_PutEnemyEvent.prototype.itemWidth = function() {
      return 40;
    };

    Window_PutEnemyEvent.prototype.itemHeight = function() {
      return 60;
    };

    Window_PutEnemyEvent.prototype.maxCols = function() {
      return 8;
    };

    Window_PutEnemyEvent.prototype.maxRowsDefining = function() {
      return 4;
    };

    Window_PutEnemyEvent.prototype.windowWidth = function() {
      return (this.itemWidth() + this.spacing()) * this.maxCols() + 2 * this.standardPadding();
    };

    Window_PutEnemyEvent.prototype.windowHeight = function() {
      return (this.itemHeight() + this.spacing()) * this.maxRowsDefining() + 2 * this.standardPadding();
    };

    Window_PutEnemyEvent.prototype.update = function() {
      Window_Selectable.prototype.update.call(this);
      if (this.active && this._index >= 0) {
        this._count += 1;
        if (this._count >= 5) {
          this._count -= 5;
          this._order = (this._order + 1) % 4;
          return this.redrawItem(this._index, this._order);
        }
      }
    };

    Window_PutEnemyEvent.prototype.redrawItem = function(index, order) {
      if (index < 0) {
        return;
      }
      this.clearItem(index);
      return this.drawItem(index, order || 0);
    };

    Window_PutEnemyEvent.prototype.select = function(index) {
      if (this._index >= 0) {
        this.redrawItem(this._index, 0);
      }
      return Window_Selectable.prototype.select.call(this, index);
    };

    return Window_PutEnemyEvent;

  })(Window_Selectable);

  Window_ItemUseList = (function(_super) {
    __extends(Window_ItemUseList, _super);

    function Window_ItemUseList(list) {
      this._list = list;
      this.initialize.call(this, 0, 0, 252, 300);
      this.refresh();
    }

    Window_ItemUseList.prototype.drawItem = function(index) {
      var item, rect;
      if (!this._list) {
        return;
      }
      item = this._list[index + 1];
      if (!item) {
        return;
      }
      rect = this.itemRect(index);
      return this.drawItemName(item, rect.x, rect.y, this.contents.width);
    };

    Window_ItemUseList.prototype.maxItems = function() {
      if (!this._list) {
        return 1;
      }
      return this._list.length - 1;
    };

    Window_ItemUseList.prototype.getList = function() {
      return this._list;
    };

    Window_ItemUseList.prototype.setList = function(value) {
      console.log("called");
      this._list = value;
      this.select(0);
      return this.refresh();
    };

    Object.defineProperty(Window_ItemUseList.prototype, 'list', {
      get: Window_ItemUseList.prototype.getList,
      set: Window_ItemUseList.prototype.setList
    });

    return Window_ItemUseList;

  })(Window_Selectable);

}).call(this);
