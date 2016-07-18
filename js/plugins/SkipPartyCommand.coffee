###:
@plugindesc skip the command choose fight or escape on battle.
@author IamI
###

Scene_Battle._SkipPartyCommand_Alias_changeInputWindow = Scene_Battle.prototype.changeInputWindow


Scene_Battle.prototype.changeInputWindow = ()->
    if (BattleManager.isInputting())
        if (BattleManager.actor())
            this.startActorCommandSelection();
        else
            this.commandFight();
    else
        this.endCommandSelection();