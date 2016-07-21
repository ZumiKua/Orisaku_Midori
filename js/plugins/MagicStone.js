// Generated by CoffeeScript 1.8.0

/*:
    @plugindesc Add Magic Stone to the database.
    @author IamI

    @param skillFactorInfluence
    @default times
    @desc Decide how magic stone influence the cost of the skill.
    'nothing', 'add', 'times' or 'replace'

    @param overEnergy
    @default destroy
    @desc Decide what will the game do when too much skills is put in the stone.
    'destroy' or 'hint'

    @param showEnergyNumber
    @default no
    @desc Decide show the number or progress bar of energy when magic stone is shown.
    'yes' or 'no'

    @param showProficiencyNumber
    @default no
    @desc Decide show the number or progress bar of proficiency when magic stone is shown.
    'yes' or 'no'

    @param showContentWhenTransfer
    @default none
    @desc Decide show what content for target skill in new magic stone when transferring.
    'energy', 'mp', 'both' or 'none'

    @param transferType
    @default move
    @desc Decide the behave 'transfer' actually copy or move the skill between magic stones.
    'move' or 'copy'

    @param destroyStoneWhen
    @default transferred
    @desc After transferring, how to handle the origin magic stone.
    'transferred', 'clear' or 'never'

    @help
    skillFactorInfluence:
    + 'nothing' for no influence.
    + 'add' will add the magic stone 'magicFactor' on skill cost.
    + 'times' will time the magic stone 'magicFactor' on skill cost, then ceil the number.
    + 'replace' will use the magic stone 'magicFactor' number as the skill cost. 
    + the default is 'times'.

    overEnergy
    + 'destroy' will remove the magic stone.
    + 'hint' will bounce a hint to the player.
    + the default is 'destroy'.

    showContentWhenTransfer
    + 'none' for show nothing when transfer. Neither will the help window shows.
    + 'mp' will show the new mp cost in the new magic stone.
    + 'energy' will show then energy cost in the new magic stone.
      if showEnergyNumber is set no, it will show the predicted energy progress bar.
    + 'both' will show both the mp and energy.

    destroyStoneWhen
    + 'transferred' means any skill transferring would destroy the source.
    + 'clear' means after transferring, space magic stone would be destroyed. 
    + 'never' means do nothing.
 */

(function() {
  var MagicStone, MagicStoneManager, MagicStoneParameters, Window_StoneHelp, Window_StoneList, Window_TransferSkillHelp, Window_TransferSkillList,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Game_Party.prototype._MagicStone_Alias_initAllItems = Game_Party.prototype.initAllItems;

  Game_Interpreter.prototype._MagicStone_Alias_pluginCommand = Game_Interpreter.prototype.pluginCommand;

  MagicStoneParameters = PluginManager.parameters('MagicStone');

  MagicStone = (function() {
    function MagicStone(name, level, factor, skills, maxEnergy, proficiency, maxProficiency) {
      var skill_id, _i, _len, _ref;
      this._name = name;
      this._level = level;
      this._magicFactor = factor;
      this._skills = skills;
      this._maxEnergy = maxEnergy;
      this._energy = 0;
      this._proficiency = proficiency;
      this._maxProficiency = maxProficiency;
      _ref = this._skills;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        skill_id = _ref[_i];
        this._energy += this.energyCost(skill_id);
      }
    }

    MagicStone.prototype.mpCost = function(skill) {
      var origin;
      if (typeof skill === 'number') {
        skill = $dataSkills[skill];
      }
      origin = skill.mpCost;
      switch (MagicStoneParameters.skillFactorInfluence) {
        case 'nothing':
          return origin;
        case 'add':
          return Math.ceil(origin + this._magicFactor);
        case 'times':
          return Math.ceil(origin * this._magicFactor);
        case 'replace':
          return Math.ceil(this._magicFactor);
        default:
          return Math.ceil(origin * this._magicFactor);
      }
    };

    MagicStone.prototype.energyCost = function(skill) {
      var data;
      if (typeof skill === 'number') {
        skill = $dataSkills[skill];
      }
      data = skill.meta.energyCost;
      if (data === null || data === void 0) {
        return 1;
      }
      return parseInt(data);
    };

    MagicStone.prototype.transfer = function(skill) {
      var cost;
      cost = energyCost(skill);
      if (this._energy + cost > this._maxEnergy) {
        return false;
      } else {
        this._energy += cost;
        this._skill.push(skill);
        return true;
      }
    };

    MagicStone.prototype.proficiencyRatio = function() {
      return this._proficiency / this._maxProficiency;
    };

    MagicStone.prototype.energyRatio = function() {
      return this._energy / this._maxEnergy;
    };

    MagicStone.prototype.predictedEnergyRatio = function(skill) {
      if (typeof skill === 'number') {
        skill = $dataSkills[skill];
      }
      return (this._energy + this.energyCost(skill)) / this._maxEnergy;
    };

    MagicStone.prototype.isEmpty = function() {
      return this._skills.length === 0;
    };

    MagicStone.prototype.isFull = function() {
      return this._skills.length >= 7 || this._energy >= this._maxEnergy;
    };

    return MagicStone;

  })();

  MagicStoneManager = function() {
    throw new error("This is a static class");
  };

  MagicStoneManager.generateMagicStoneFromItem = function(itemIndex) {
    var factor, item, level, maxEnergy, maxProficiency, name, proficiency, skills, skillsString;
    item = $dataItems[itemIndex];
    name = item.name;
    skillsString = item.meta.skills || "[]";
    skills = eval(skillsString);
    level = parseInt(item.meta.level || "1");
    factor = parseInt(item.meta.factor || "1");
    maxEnergy = parseInt(item.meta.maxEnergy || "5");
    proficiency = parseInt(item.meta.proficiency || "0");
    maxProficiency = parseInt(item.meta.maxProficiency || "100");
    return new MagicStone(name, level, factor, skills, maxEnergy, proficiency, maxProficiency);
  };

  MagicStoneManager.generateMagicStoneRandomly = function(minLevel, maxLevel) {};

  MagicStoneManager.magicStones = function() {
    return $gameParty.magicStones();
  };

  MagicStoneManager.gainMagicStone = function(stone) {
    return MagicStoneManager.magicStones().push(stone);
  };

  Game_Party.prototype.initAllItems = function() {
    this._MagicStone_Alias_initAllItems();
    return this._magicStones = [];
  };

  Game_Party.prototype.magicStones = function() {
    return this._magicStones;
  };

  this.Spriteset_Progressbar = (function(_super) {
    __extends(Spriteset_Progressbar, _super);

    function Spriteset_Progressbar() {
      this.initialize.call(this);
      this.bitmap = ImageManager.loadSystem("EnergybarBackground");
      this.forebitmap = ImageManager.loadSystem("EnergybarForeground");
      this.foreground = new Sprite();
      this.foreground.bitmap = this.forebitmap;
      this.addChild(this.foreground);
      this.value = 0.0;
    }

    Spriteset_Progressbar.prototype.setForebitmap = function() {
      this.forebitmap = new Bitmap(this.bitmap.width, this.bitmap.height);
      return this.foreground.bitmap = this.forebitmap;
    };

    Spriteset_Progressbar.prototype.refresh = function() {
      var height, width;
      if (!this.bitmap.isReady()) {
        this.bitmap.addLoadListener(this.refresh.bind(this));
        return;
      }
      width = Math.ceil(this.bitmap.width * this.value);
      height = this.bitmap.height;
      return this.foreground.scale.x = this.value;
    };

    Spriteset_Progressbar.prototype.setValue = function(value) {
      this.value = value;
      return this.refresh();
    };

    return Spriteset_Progressbar;

  })(this.Sprite);

  Window_Base.prototype.drawTextOnLine = function(line, text, align, x_move) {
    var height, width, x, y;
    x = this.textPadding();
    y = this.lineHeight() * line;
    width = this.contents.width - this.textPadding() * 2;
    height = this.lineHeight();
    if (x_move !== void 0) {
      x += Math.floor(width * x_move);
    }
    return this.contents.drawText(text, x, y, width, height, align);
  };

  Window_Base.prototype.drawSkill = function(line, width, skill, cost) {
    var y;
    if (typeof skill === 'number') {
      skill = $dataSkills[skill];
    }
    y = this.lineHeight() * line;
    this.drawItemName(skill, 0, y, width);
    if (cost < 0 || cost === void 0) {
      cost = skill.mpCost;
    }
    return this.contents.drawText(cost.toString(), 0, y, width, this.lineHeight(), 'right');
  };

  Window_StoneList = (function(_super) {
    __extends(Window_StoneList, _super);

    function Window_StoneList(x, y) {
      this.initialize.call(this, x, y, this.windowWidth(), this.windowHeight());
      this.refresh();
    }

    Window_StoneList.prototype.drawItem = function(index) {
      var rect, stone;
      stone = this.magicStoneAtIndex(index);
      if (stone === null || stone === void 0) {
        return;
      }
      this.changePaintOpacity(this.isEnabled(stone));
      rect = this.itemRectForText(index);
      this.contents.drawText(stone._name, rect.x, rect.y, rect.width, rect.height, 'left');
      return this.changePaintOpacity(1);
    };

    Window_StoneList.prototype.magicStoneAtIndex = function(index) {
      return $gameParty.magicStones()[index];
    };

    Window_StoneList.prototype.magicStoneChosen = function() {
      return this.magicStoneAtIndex(this._index);
    };

    Window_StoneList.prototype.maxItems = function(index) {
      return Math.max(1, $gameParty.magicStones().length);
    };

    Window_StoneList.prototype.updateHelp = function() {
      return this.setHelpWindowItem(this.magicStoneChosen());
    };

    Window_StoneList.prototype.windowWidth = function() {
      return Graphics.width / 2;
    };

    Window_StoneList.prototype.windowHeight = function() {
      return 340;
    };

    Window_StoneList.prototype.createHelpWindow = function() {
      this._helpWindow = new Window_StoneHelp(0);
      return this.addChild(this._helpWindow);
    };

    Window_StoneList.prototype.isEnabled = function(stone) {
      return true;
    };

    return Window_StoneList;

  })(this.Window_Selectable);

  Window_StoneHelp = (function(_super) {
    __extends(Window_StoneHelp, _super);

    function Window_StoneHelp(windowX) {
      var windowHeight, windowY;
      windowHeight = this.lineHeight() * 7 + 32;
      windowY = Graphics.boxHeight - windowHeight;
      this.initialize.call(this, windowX, windowY, Graphics.width / 2, windowHeight);
      this.stone = null;
      if (MagicStoneParameters.showProficiencyNumber !== 'yes') {
        this.proficiencyProgressBar = this.createPreogressBar(1);
      }
      if (MagicStoneParameters.showEnergyNumber !== 'yes') {
        this.energyProgressBar = this.createPreogressBar(2);
      }
    }

    Window_StoneHelp.prototype.createPreogressBar = function(line) {
      var bar;
      bar = new Spriteset_Progressbar();
      bar.y = this.lineHeight() * line + 20;
      bar.x = this.width / 2;
      bar.visible = false;
      return this.addChild(bar);
    };

    Window_StoneHelp.prototype.refresh = function() {
      var i, line, skill, skillID, _i, _ref, _results;
      this.contents.clear();
      if (this.stone === null || this.stone === void 0) {
        return;
      }
      this.drawTextOnLine(0, this.stone._name, 'left');
      this.drawTextOnLine(0, this.stone._level, 'right');
      this.drawTextOnLine(1, "熟练度", 'left');
      if (MagicStoneParameters.showProficiencyNumber === 'yes') {
        this.drawTextOnLine(1, "" + this.stone._proficiency + " / " + this.stone._maxProficiency, 'right');
      } else {
        this.proficiencyProgressBar.visible = true;
        this.proficiencyProgressBar.setValue(this.stone.proficiencyRatio());
      }
      if (MagicStoneParameters.showEnergyNumber === 'yes') {
        this.drawTextOnLine(2, "" + this.stone._energy + " / " + this.stone._maxEnergy, 'right');
      } else {
        this.energyProgressBar.visible = true;
        this.energyProgressBar.setValue(this.stone.energyRatio());
      }
      this.drawTextOnLine(2, "能量", "left");
      if (this.stone._skills.length === 0) {
        return this.drawTextOnLine(4, "没有技能", 'center');
      } else {
        _results = [];
        for (i = _i = 0, _ref = this.stone._skills.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          line = 3 + Math.floor(i / 2);
          skillID = this.stone._skills[i];
          skill = $dataSkills[skillID];
          _results.push(this.drawTextOnLine(line, skill.name, 'left', (i % 2) / 2));
        }
        return _results;
      }
    };

    Window_StoneHelp.prototype.setItem = function(item) {
      this.stone = item;
      return this.refresh();
    };

    return Window_StoneHelp;

  })(this.Window_Base);

  Window_TransferSkillList = (function(_super) {
    __extends(Window_TransferSkillList, _super);

    function Window_TransferSkillList() {
      var width, x;
      width = this.windowWidth();
      x = (Graphics.boxWidth - width) / 2;
      this.initialize.call(this, x, 0, width, 100);
    }

    Window_TransferSkillList.prototype.updateHelp = function() {
      return this.setHelpWindowItem(this.selectedSkill());
    };

    Window_TransferSkillList.prototype.setSkills = function(skills) {
      var fullHeight;
      this.datas = skills;
      this.height = this.lineHeight() * skills.length + 2 * this.standardPadding();
      fullHeight = this.height + this._titleWindow.height + this._helpWindow.height;
      this.y = (Graphics.boxHeight - fullHeight) / 2 + this._titleWindow.height;
      this._helpWindow.y = this.height;
      this.createContents();
      return this.refresh();
    };

    Window_TransferSkillList.prototype.windowWidth = function() {
      return 400;
    };

    Window_TransferSkillList.prototype.maxItems = function() {
      if (this.datas === null || this.datas === void 0) {
        return 1;
      }
      return Math.max(1, this.datas.length);
    };

    Window_TransferSkillList.prototype.skillAtIndex = function(index) {
      return $dataSkills[this.datas[index]];
    };

    Window_TransferSkillList.prototype.selectedSkill = function() {
      return this.skillAtIndex(this.index());
    };

    Window_TransferSkillList.prototype.drawItem = function(index) {
      var skill;
      if (this.datas === null || this.datas === void 0 || this.datas.length === 0) {
        return;
      }
      skill = $dataSkills[this.datas[index]];
      return this.drawSkill(index, this.contents.width, skill, this.fromStone.mpCost(skill));
    };

    Window_TransferSkillList.prototype.createHelpWindow = function() {
      this._helpWindow = new Window_TransferSkillHelp(0, this.height, this.width);
      this._helpWindow.openness = this.openness;
      return this.addChild(this._helpWindow);
    };

    Window_TransferSkillList.prototype.createTitleWindow = function() {
      var height;
      height = this.lineHeight() + this.standardPadding() * 2;
      this._titleWindow = new Window_Base(0, -height, this._width, height);
      this._titleWindow.openness = this.openness;
      this._titleWindow.contents.drawText("请选择技能", 0, 0, this._titleWindow.contents.width, this.lineHeight(), 'center');
      return this.addChild(this._titleWindow);
    };

    Window_TransferSkillList.prototype.setOpenness = function(value) {
      this.openness = value;
      if (this._helpWindow !== void 0 && this._helpWindow !== null) {
        this._helpWindow.openness = value;
      }
      if (this._titleWindow !== void 0 && this._titleWindow !== null) {
        return this._titleWindow.openness = value;
      }
    };

    Window_TransferSkillList.prototype.setStones = function(fromStone, toStone) {
      this.fromStone = fromStone;
      return this._helpWindow.toStone = toStone;
    };

    Window_TransferSkillList.prototype.open = function() {
      Window_Base.prototype.open.call(this);
      this._helpWindow.open();
      return this._titleWindow.open();
    };

    Window_TransferSkillList.prototype.close = function() {
      Window_Base.prototype.close.call(this);
      this._helpWindow.close();
      return this._titleWindow.close();
    };

    return Window_TransferSkillList;

  })(Window_Selectable);

  Window_TransferSkillHelp = (function(_super) {
    __extends(Window_TransferSkillHelp, _super);

    function Window_TransferSkillHelp(x, y, width) {
      var content, height, line;
      line = 0;
      content = MagicStoneParameters.showContentWhenTransfer;
      switch (content) {
        case 'energy':
          line = 1;
          break;
        case 'mp':
          line = 1;
          break;
        case 'both':
          line = 2;
          break;
        case 'none':
          line = 0;
      }
      height = this.lineHeight() * line + this.standardPadding() * 2;
      if (line === 0) {
        height = 0;
      }
      this.initialize.call(this, x, y, width, height);
      if (MagicStoneParameters.showEnergyNumber !== 'yes') {
        this.createProgressBar();
      }
    }

    Window_TransferSkillHelp.prototype.setItem = function(item) {
      this.skill = item;
      return this.refresh();
    };

    Window_TransferSkillHelp.prototype.createProgressBar = function() {
      this.progressBar = new Spriteset_Progressbar;
      this.progressBar.visible = false;
      return this.addChild(this.progressBar);
    };

    Window_TransferSkillHelp.prototype.refresh = function() {
      if (!this.skill || !this.toStone) {
        return;
      }
      this.contents.clear();
      this.focusLine = 0;
      switch (MagicStoneParameters.showContentWhenTransfer) {
        case 'mp':
          return this.drawPredictedSkill();
        case 'energy':
          return this.drawPredictedEnergy();
        case 'both':
          this.drawPredictedSkill();
          return this.drawPredictedEnergy();
      }
    };

    Window_TransferSkillHelp.prototype.drawPredictedSkill = function() {
      if (!this.toStone) {
        return;
      }
      this.drawSkill(this.focusLine, this.contents.width, this.skill, this.toStone.mpCost(this.skill));
      return this.focusLine += 1;
    };

    Window_TransferSkillHelp.prototype.drawPredictedEnergy = function() {
      var predicted, text;
      if (!this.toStone) {
        return;
      }
      this.drawTextOnLine(this.focusLine, "转录后能量", "left");
      if (MagicStoneParameters.showEnergyNumber === 'yes') {
        text = "" + (this.toStone._energy + this.toStone.energyCost(this.skill)) + " / " + this.toStone._maxEnergy;
        this.drawTextOnLine(this.focusLine, text, "right");
      } else {
        predicted = this.toStone.predictedEnergyRatio(this.skill);
        if (predicted > 1) {
          this.progressBar.visible = false;
          this.drawTextOnLine(this.focusLine, "能量不足", "left", 0.5);
        } else {
          this.progressBar.visible = true;
          this.progressBar.x = this.width / 2;
          this.progressBar.y = this.focusLine * this.lineHeight() + 6 + this.standardPadding();
          this.progressBar.setValue(this.toStone.predictedEnergyRatio(this.skill));
        }
      }
      return this.focusLine += 1;
    };

    Window_TransferSkillHelp.prototype.close = function() {
      Window_Base.prototype.close.call(this);
      if (this.progressBar) {
        return this.progressBar.visible = false;
      }
    };

    return Window_TransferSkillHelp;

  })(Window_Base);

  this.Scene_Transfer = (function(_super) {
    __extends(Scene_Transfer, _super);

    function Scene_Transfer() {
      this.initialize.call(this);
    }

    Scene_Transfer.prototype.start = function() {
      return Scene_Base.prototype.start.call(this);
    };

    Scene_Transfer.prototype.create = function() {
      this.createWindowLayer();
      this.createFromWindows();
      this.createToWindows();
      this.createSkillWinodw();
      this.createMessageWindow();
      return this.switchState('from');
    };

    Scene_Transfer.prototype.createFromWindows = function() {
      this.fromStoneListWindow = new Window_StoneList(0, 0);
      this.fromStoneListWindow.createHelpWindow();
      this.fromStoneListWindow.setHandler('ok', this.onFromListOk.bind(this));
      this.fromStoneListWindow.setHandler('cancel', this.onFromListCancel.bind(this));
      this.fromStoneListWindow.isEnabled = function(stone) {
        return !(stone.isEmpty());
      };
      this.fromStoneListWindow.refresh();
      return this.addChild(this.fromStoneListWindow);
    };

    Scene_Transfer.prototype.createToWindows = function() {
      this.toStoneListWindow = new Window_StoneList(Graphics.width / 2, 0);
      this.toStoneListWindow.createHelpWindow();
      this.toStoneListWindow.setHandler('ok', this.onToListOK.bind(this));
      this.toStoneListWindow.setHandler('cancel', this.onToListCancel.bind(this));
      this.toStoneListWindow.isEnabled = function(stone) {
        return !(stone.isFull() && stone !== this.fromMagicStone);
      };
      this.toStoneListWindow.isEnabled.bind(this);
      this.toStoneListWindow.refresh();
      return this.addChild(this.toStoneListWindow);
    };

    Scene_Transfer.prototype.createSkillWinodw = function() {
      this.skillListWindow = new Window_TransferSkillList;
      this.skillListWindow.setOpenness(0);
      this.skillListWindow.createHelpWindow();
      this.skillListWindow.createTitleWindow();
      this.skillListWindow.setHandler('ok', this.onSkillListOK.bind(this));
      this.skillListWindow.setHandler('cancel', this.onSkillListCancel.bind(this));
      return this.addChild(this.skillListWindow);
    };

    Scene_Transfer.prototype.createMessageWindow = function() {
      this.messageWindow = new Window_Base;
      this.messageWindow.openness = 0;
      return this.addChild(this.messageWindow);
    };

    Scene_Transfer.prototype.update = function() {
      Scene_Base.prototype.update.call(this);
      if (this.state === 'message') {
        if (Input.isRepeated('ok') || Input.isTriggered('cancel')) {
          return this.onMessageWindowOK();
        }
      }
    };

    Scene_Transfer.prototype.switchState = function(state) {
      switch (state) {
        case 'from':
          this.fromStoneListWindow.activate();
          if (this.fromStoneListWindow.index() < 0) {
            this.fromStoneListWindow.select(0);
          }
          this.toStoneListWindow.deactivate();
          break;
        case 'to':
          this.fromStoneListWindow.deactivate();
          this.toStoneListWindow.activate();
          if (this.toStoneListWindow.index() < 0) {
            this.toStoneListWindow.select(0);
          }
          break;
        case 'skill':
          this.fromStoneListWindow.deactivate();
          this.toStoneListWindow.deactivate();
          this.skillListWindow.open();
          this.skillListWindow.activate();
          this.skillListWindow.select(0);
          break;
        case 'message':
          this.lastState = this.state;
          this.fromStoneListWindow.deactivate();
          this.toStoneListWindow.deactivate();
          this.messageWindow.open();
      }
      return this.state = state;
    };

    Scene_Transfer.prototype.onFromListOk = function() {
      this.fromMagicStone = this.fromStoneListWindow.magicStoneChosen();
      if (this.fromMagicStone.isEmpty()) {
        this.setMessageWindow("这个魔石上没有刻录技能。");
        return this.switchState('message');
      } else {
        return this.switchState('to');
      }
    };

    Scene_Transfer.prototype.onFromListCancel = function() {
      return SceneManager.goto(Scene_Map);
    };

    Scene_Transfer.prototype.onToListOK = function() {
      this.toMagicStone = this.toStoneListWindow.magicStoneChosen();
      if (this.toMagicStone === this.fromMagicStone) {
        this.setMessageWindow("这两者是同一块魔石。");
        return this.switchState('message');
      } else if (this.toMagicStone.isFull()) {
        this.setMessageWindow("这块魔石已经写满了。");
        return this.switchState('message');
      } else {
        this.skillListWindow.setStones(this.fromMagicStone, this.toMagicStone);
        this.skillListWindow.setSkills(this.fromMagicStone._skills);
        return this.switchState('skill');
      }
    };

    Scene_Transfer.prototype.onToListCancel = function() {
      this.fromMagicStone = null;
      this.toStoneListWindow.select(-1);
      return this.switchState('from');
    };

    Scene_Transfer.prototype.onSkillListOK = function() {};

    Scene_Transfer.prototype.onSkillListCancel = function() {
      this.toMagicStone = null;
      this.skillListWindow.close();
      return this.switchState('to');
    };

    Scene_Transfer.prototype.onMessageWindowOK = function() {
      this.messageWindow.close();
      return this.switchState(this.lastState);
    };

    Scene_Transfer.prototype.setMessageWindow = function(message) {
      var width;
      width = this.messageWindow.textWidth(message);
      this.messageWindow.width = width + this.messageWindow.standardPadding() + 2 * this.messageWindow.textPadding();
      this.messageWindow.height = this.messageWindow.lineHeight() + 2 * this.messageWindow.standardPadding();
      this.messageWindow.x = (Graphics.boxWidth - this.messageWindow.width) / 2;
      this.messageWindow.y = (Graphics.boxHeight - this.messageWindow.height) / 2;
      this.messageWindow.createContents();
      return this.messageWindow.drawTextEx(message, this.messageWindow.textPadding(), 0);
    };

    return Scene_Transfer;

  })(this.Scene_Base);

  Game_Interpreter.prototype.pluginCommand = function(command, args) {
    var id, idString;
    this._MagicStone_Alias_pluginCommand(command, args);
    if (command === 'MagicStone') {
      switch (args[0]) {
        case 'test':
          $gameParty.magicStones().push(new MagicStone("简单的石头", 1, 1.4, [6, 7, 8, 9], 100, 60, 100));
          return $gameParty.magicStones().push(new MagicStone("老旧的石头", 0, 2.5, [1, 2, 3, 4, 5], 5, 100, 100));
        case 'fromItem':
          idString = args[1];
          if (idString === void 0 || idString === null) {
            throw new exception('create magic stone from item with no id');
          }
          id = parseInt(idString);
          return MagicStoneManager.gainMagicStone(MagicStoneManager.generateMagicStoneFromItem(id));
      }
    }
  };

}).call(this);