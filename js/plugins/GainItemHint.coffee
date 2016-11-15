###:
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
###

gainItemParameters = PluginManager.parameters "GainItemHint"

class Window_GainItem extends Window_Base
    constructor: ->
        @initialize.call this
        @datas = []

    addGold: (count)->
        item = TextManager.currencyUnit
        @datas.push [item, count,null]

    addItem: (itemId, count1,count2)->
        item = $dataItems[itemId]
        @datas.push [item, count1,count2]

    addWeapon: (weaponId, count1,count2)->
        weapon = $dataWeapons[weaponId]
        @datas.push [weapon, count1,count2]

    addArmor: (armorId, count1,count2)->
        armor = $dataArmors[armorId]
        @datas.push [armor, count1,count2]

    clear: ->
        @datas = []

    refresh: ->
        @resize()
        order = 0
        for array in @datas
            data = array[0]
            count = array[1]
            count2 = array[2]
            hintText = if count >= 0 then gainItemParameters.gainItemHint else gainItemParameters.loseItemHint
            y = order * @lineHeight()
            x = @textPadding() * 2 + @contents.measureTextWidth hintText
            @changeTextColor @systemColor()
            @contents.drawText hintText, @textPadding(), y, @contents.width, @lineHeight()
            @resetTextColor()
            if data != TextManager.currencyUnit
                @drawItemName data, x, y, @contents.width
                @contents.drawText "X " + Math.abs(count) , 0, y, @contents.width, @lineHeight(), 'right'
                if count2 > 0
                  box_str = gainItemParameters.boxHint.replace("%NUM%",Math.abs(count2))
                  console.log(box_str)
                  @contents.drawText box_str , 0, y + @lineHeight(), @contents.width, @lineHeight(), 'right'
                  order += 1
            else
                @drawCurrencyValue count, data, 0, y, @contents.width
            order += 1

    resize: ->
        width = 400
        height = @datas.length * @lineHeight() + @standardPadding() * 2
        x = (Graphics.boxWidth - width) / 2
        y = (Graphics.boxHeight - height) / 2
        @move x, y, width, height
        @createContents()
        @contents.fontSize = 24

    update: ->
        Window_Base.prototype.update.call this
        if Input.isTriggered('ok') or Input.isTriggered('cancel')
            @close()

_GainItemHint_Alias_Game_Interpreter_Command125 = Game_Interpreter.prototype.command125
_GainItemHint_Alias_Game_Interpreter_Command126 = Game_Interpreter.prototype.command126
_GainItemHint_Alias_Game_Interpreter_Command127 = Game_Interpreter.prototype.command127
_GainItemHint_Alias_Game_Interpreter_Command128 = Game_Interpreter.prototype.command128


Game_Interpreter.prototype.command125 = ->
    console.log "I run!"
    result = _GainItemHint_Alias_Game_Interpreter_Command125.call this
    GainItemHintHelper.checkGainHintWindow()
    value = @operateValue this._params[0], this._params[1], this._params[2]
    GainItemHintHelper.gainItemHintWindow.addGold value
    GainItemHintHelper.showGainHintWindow() if !@nextCommandIsItem()
    result

Game_Interpreter.prototype.command126 = ->
    value = this.operateValue(this._params[1], this._params[2], this._params[3]);
    arr = $gameParty.gainItem($dataItems[this._params[0]], value);
    v = arr[0]
    bv = arr[1]
    GainItemHintHelper.checkGainHintWindow()
    GainItemHintHelper.gainItemHintWindow.addItem this._params[0], v,bv
    GainItemHintHelper.showGainHintWindow() if !@nextCommandIsItem()
    true

Game_Interpreter.prototype.command127 = ->
    value = this.operateValue(this._params[1], this._params[2], this._params[3]);
    arr = $gameParty.gainItem($dataWeapons[this._params[0]], value, this._params[4]);
    v = arr[0]
    bv = arr[1]
    GainItemHintHelper.checkGainHintWindow()
    GainItemHintHelper.gainItemHintWindow.addWeapon this._params[0], v,bv
    GainItemHintHelper.showGainHintWindow() if !@nextCommandIsItem()
    true

Game_Interpreter.prototype.command128 = ->
    value = this.operateValue(this._params[1], this._params[2], this._params[3]);
    arr = $gameParty.gainItem($dataArmors[this._params[0]], value, this._params[4]);
    v = arr[0]
    bv = arr[1]
    GainItemHintHelper.checkGainHintWindow()
    GainItemHintHelper.gainItemHintWindow.addArmor this._params[0], v,bv
    GainItemHintHelper.showGainHintWindow() if !@nextCommandIsItem()
    true

Game_Interpreter.prototype.nextCommandIsItem = ->
    code = @nextEventCode()
    return true if code == 125 or code == 126 or code == 127 or code == 128
    false

GainItemHintHelper = ->
    throw new Error 'This is a static class!'

GainItemHintHelper.checkGainHintWindow = ->
    GainItemHintHelper.gainItemHintWindow = new Window_GainItem if !GainItemHintHelper.gainItemHintWindow

GainItemHintHelper.showGainHintWindow = ->
    GainItemHintHelper.checkGainHintWindow()
    GainItemHintHelper.gainItemHintWindow.refresh()
    GainItemHintHelper.gainItemHintWindow.clear()
    GainItemHintHelper.gainItemHintWindow.openness = 0
    GainItemHintHelper.stickInScene()
    SceneManager._scene.stickedWaitingCount = parseInt(gainItemParameters.hintWindowDurations) || 120
    SceneManager._scene.stickedWindow = GainItemHintHelper.gainItemHintWindow
    SceneManager._scene.addChild GainItemHintHelper.gainItemHintWindow
    GainItemHintHelper.gainItemHintWindow.open()
    SoundManager.playShop()

GainItemHintHelper.stickInScene = ->
    scene = SceneManager._scene
    return if scene._normalUpdate
    scene._normalUpdate = scene.update
    scene.update = ->
        if @stickedWindow
            @stickedWaitingCount = 1 if !@stickedWaitingCount
            @stickedWaitingCount -= 1
            if @stickedWaitingCount <= 0
                @stickedWindow.close()
            if @stickedWindow.isClosed()
                @removeChild @stickedWindow
                @stickedWindow = null
            else
                Scene_Base.prototype.update.call this
                #@stickedWindow.update()
        else
            this._normalUpdate()
