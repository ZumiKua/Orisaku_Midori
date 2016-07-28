###:
    @plugindesc Add a hint when you get item.
    @author IamI
###

class Window_GainItem extends Window_Base 
    constructor: ->
        @initialize.call this
        @datas = []
        @counts = {}
    
    addItem: (itemId, count)->
        item = $dataItems[itemId]
        @datas.push item
        @addToCount item, count

    addWeapon: (weaponId)->
        weapon = $dataWeapons[weaponId]
        @datas.push weapon
        @addToCount weapon, count

    addArmor: (armorId)->
        armor = $dataArmors[armorId]
        @datas.push armor
        @addToCount armor, count
    
    addToCount: (item, count)->
        @counts[item] = 0 if !@counts[item]
        @counts[item] += count

    refresh: ->
        width = 400
        height = @datas.length * @lineHeight() + @standardPadding() * 2
        x = (Graphics.boxWidth - width) / 2
        y = (Graphics.boxHeight - height) / 2
        @move x, y, width, height
        @createContents()
        order = 0
        for data in @datas
            @drawItemName data, @textPadding(), order * @lineHeight(), width - @contents.width
            order += 1

_GainItemHint_Alias_Game_Interpreter_Command125 = Game_Interpreter.prototype.command125
_GainItemHint_Alias_Game_Interpreter_Command126 = Game_Interpreter.prototype.command126
_GainItemHint_Alias_Game_Interpreter_Command127 = Game_Interpreter.prototype.command127
_GainItemHint_Alias_Game_Interpreter_Command128 = Game_Interpreter.prototype.command128


Game_Interpreter.prototype.command126 = ->
    result = _GainItemHint_Alias_Game_Interpreter_Command126.call this
    @checkGainHintWindow()
    value = @operateValue this._params[1], this._params[2], this._params[3]
    @gainItemHintWindow.addItem this._params[0], value
    @showGainHintWindow() if !@nextCommandIsItem()
    result

Game_Interpreter.prototype.command127 = ->
    result = _GainItemHint_Alias_Game_Interpreter_Command127.call this
    @checkGainHintWindow()
    value = @operateValue this._params[1], this._params[2], this._params[3]
    @gainItemHintWindow.addWeapon this._params[0], value
    @showGainHintWindow() if !@nextCommandIsItem()
    result

Game_Interpreter.prototype.command128 = ->
    result = _GainItemHint_Alias_Game_Interpreter_Command128.call this
    @checkGainHintWindow()
    value = @operateValue this._params[1], this._params[2], this._params[3]
    @gainItemHintWindow.addArmor this._params[0], value
    @showGainHintWindow() if !@nextCommandIsItem()
    result

Game_Interpreter.prototype.nextCommandIsItem = ->
    code = @nextEventCode()
    return true if code == 126 or code == 127 or code == 128
    false

Game_Interpreter.prototype.checkGainHintWindow = ->
    @gainItemHintWindow = new Window_GainItem if !@gainItemHintWindow

Game_Interpreter.prototype.showGainHintWindow = ->
    @checkGainHintWindow()
    @gainItemHintWindow.refresh()
    @gainItemHintWindow.openness = 0
    SceneManager._scene.addChild @gainItemHintWindow
    @gainItemHintWindow.open()

Game_Interpreter.prototype.terminateGainHintWindow = ->
    @gainItemHintWindow = null
    SceneManager._scene.removeChild @gainItemHintWindow