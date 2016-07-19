
/*:
    @plugindesc Adjust the Battle UI positions.
                Caution!!! Help window of the Item would also change from SKill window.
                That is to be fixed when further discussion is done.
    @author IamI
 */
Scene_Battle.prototype._BattleUIAdjustment_Alias_createActorCommandWindow = Scene_Battle.prototype.createActorCommandWindow;

Scene_Battle.prototype._BattleUIAdjustment_Alias_createHelpWindow = Scene_Battle.prototype.createHelpWindow;

Scene_Battle.prototype._BattleUIAdjustment_Alias_createSkillWindow = Scene_Battle.prototype.createSkillWindow;

Scene_Battle.prototype._BattleUIAdjustment_Alias_createStatusWindow = Scene_Battle.prototype.createStatusWindow;

Window_ActorCommand.prototype._BattleUIAdjustment_Alias_makeCommandList = Window_ActorCommand.prototype.makeCommandList;

Scene_Battle.prototype.createActorCommandWindow = function() {
  this._actorCommandWindow = new Window_ActorCommand();
  this._actorCommandWindow.setHandler('skill', this.commandSkill.bind(this));
  this._actorCommandWindow.setHandler('guard', this.commandGuard.bind(this));
  this._actorCommandWindow.setHandler('item', this.commandItem.bind(this));
  this._actorCommandWindow.setHandler('escape', this.commandEscape.bind(this));
  return this.addWindow(this._actorCommandWindow);
};

Window_ActorCommand.prototype.addEscapeCommand = function() {
  return this.addCommand(TextManager.escape, 'escape', true);
};

Window_ActorCommand.prototype.makeCommandList = function() {
  if (this._actor) {
    this.addSkillCommands();
    this.addGuardCommand();
    this.addItemCommand();
    return this.addEscapeCommand();
  }
};

Scene_Battle.prototype.rightSpace = function() {
  return 192;
};

Scene_Battle.prototype.createSkillWindow = function() {
  var wh, wy;
  wh = 32 * 2 + 48;
  wy = this._helpWindow.y - wh;
  this._skillWindow = new Window_BattleSkill(0, wy, Graphics.boxWidth - this.rightSpace(), wh);
  this._skillWindow.setHelpWindow(this._helpWindow);
  this._skillWindow.setHandler('ok', this.onSkillOk.bind(this));
  this._skillWindow.setHandler('cancel', this.onSkillCancel.bind(this));
  return this.addWindow(this._skillWindow);
};

Scene_Battle.prototype.createHelpWindow = function() {
  this._BattleUIAdjustment_Alias_createHelpWindow();
  this._helpWindow.y = this._statusWindow.y;
  this._helpWindow.x = 192;
  this._helpWindow.windowWidth = Graphics.boxWidth - this.rightSpace() - 192;
  this._helpWindow.windowHeight = Graphics.boxHeight - this._helpWindow.y;
  this._helpWindow.width = this._helpWindow.windowWidth;
  return this._helpWindow.height = this._helpWindow.windowHeight;
};

Scene_Battle.prototype.createStatusWindow = function() {
  this._BattleUIAdjustment_Alias_createStatusWindow();
  return this._statusWindow.visible = false;
};

Window_BattleSkill.prototype.maxCols = function() {
  return 4;
};

Window_BattleSkill.prototype.spacing = function() {
  return 24;
};
