###:
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

###

Game_Party.prototype._MagicStone_Alias_initAllItems = Game_Party.prototype.initAllItems
Game_Interpreter.prototype._MagicStone_Alias_pluginCommand = Game_Interpreter.prototype.pluginCommand
MagicStoneParameters = PluginManager.parameters 'MagicStone'

class MagicStone
    constructor: (name, level, factor, skills, maxEnergy, proficiency, maxProficiency)->
        this._name = name
        this._level = level
        this._magicFactor = factor
        this._skills = skills
        this._maxEnergy = maxEnergy
        this._energy = 0
        this._proficiency = proficiency
        this._maxProficiency = maxProficiency
        @updateEnergy()
    
    mpCost: (skill) ->
        skill = $dataSkills[skill] if typeof skill == 'number'
        origin = skill.mpCost
        switch MagicStoneParameters.skillFactorInfluence
            when 'nothing' then origin
            when 'add'     then Math.ceil origin + this._magicFactor
            when 'times'   then Math.ceil origin * this._magicFactor
            when 'replace' then Math.ceil this._magicFactor
            else                Math.ceil origin * this._magicFactor

    energyCost: (skill) ->
        skill = $dataSkills[skill] if typeof skill == 'number'
        data = skill.meta.energyCost
        return skill.id if data == null || data == undefined
        parseInt data

    transferSkill: (skill) ->
        skill = skill.id if typeof skill != 'number'
        return false if !@canReceiveSkill
        cost = @energyCost skill
        if this._energy + cost > this._maxEnergy
            return false
        else 
            this._energy += cost
            this._skills.push skill
            return true

    canReceiveSkill: (skill) ->
        true
    
    removeSkill: (skill) ->
        skill = skill.id if typeof skill != 'number'
        index = this._skills.indexOf skill
        return -1 if index < 0
        this._skills.splice index, 1

    proficiencyRatio: ->
        Math.min 1, this._proficiency / this._maxProficiency
        
    energyRatio: ->
        Math.min 1, this._energy / this._maxEnergy

    predictedEnergyRatio: (skill) ->
        skill = $dataSkills[skill] if typeof skill == 'number'
        return (this._energy + @energyCost skill) / this._maxEnergy

    isEmpty: ->
        return this._skills.length == 0

    isFull: ->
        return this._skills.length >= 7 or this._energy >= this._maxEnergy

    updateEnergy: ->
        this._energy += this.energyCost(skill_id) for skill_id in this._skills

@MagicStoneManager = ->
    throw new error "This is a static class"

MagicStoneManager.generateMagicStoneFromItem = (itemIndex) ->
    item = $dataItems[itemIndex]
    name = item.name
    skillsString = item.meta.skills || "[]"
    skills = eval skillsString
    level = parseInt item.meta.level || "1"
    factor = parseInt item.meta.factor || "1"
    maxEnergy = parseInt item.meta.maxEnergy || "5"
    proficiency = parseInt item.meta.proficiency || "0"
    maxProficiency = parseInt item.meta.maxProficiency || "100"
    new MagicStone name, level, factor, skills, maxEnergy, proficiency, maxProficiency

MagicStoneManager.generateMagicStoneRandomly = (minLevel, maxLevel) ->
MagicStoneManager.magicStones = ->
    $gameParty.magicStones()

MagicStoneManager.gainMagicStone = (stone)->
    MagicStoneManager.magicStones().push stone
MagicStoneManager.transferSkill = (fromStone, toStone, skill)->
    result = toStone.transferSkill skill
    return 'fail' if !result
    return 'success' if MagicStoneParameters.transferType == 'copy'
    fromStone.removeSkill skill
    fromStone.updateEnergy()
    switch MagicStoneParameters.destroyStoneWhen
        when 'transferred' then return 'destroy transfer'
        when 'clear'
            if fromStone.isEmpty()
                return 'destroy clear'
            else 
                return 'success'
        when 'never' then return 'success'
        else return 'destroy transfer'
MagicStoneManager.canReceiveSkill = (toStone, skill)->
    skill = skill.id if typeof skill != 'number'
    return "refuse" if !toStone.canReceiveSkill skill
    index = toStone._skills.indexOf skill
    return "contains" if index >= 0
    if MagicStoneParameters.showContentWhenTransfer == 'energy' or MagicStoneParameters.showContentWhenTransfer == 'both'
        return "explosion" if toStone.predictedEnergyRatio(skill) > 1
    return "ok"

Game_Party.prototype.initAllItems = () ->
    this._MagicStone_Alias_initAllItems();
    this._magicStones = []

Game_Party.prototype.magicStones = ->
    this._magicStones

class @Spriteset_Progressbar extends @Sprite
    constructor: ()->
        @initialize.call this
        @bitmap = ImageManager.loadSystem "EnergybarBackground"
        @forebitmap = ImageManager.loadSystem "EnergybarForeground"
        @foreground = new Sprite()
        @foreground.bitmap = @forebitmap
        @addChild @foreground
        @value = 0.0

    setForebitmap: ()->
        @forebitmap = new Bitmap @bitmap.width, @bitmap.height
        @foreground.bitmap = @forebitmap

    refresh: ()->
        if !@bitmap.isReady()
            @bitmap.addLoadListener @refresh.bind this
            return
        width = Math.ceil @bitmap.width * @value
        height = @bitmap.height
        @foreground.scale.x = @value

    setValue: (value)->
        @value = value
        @refresh()

Window_Base.prototype.drawTextOnLine = (line, text, align, x_move) ->
    x = @textPadding()
    y = @lineHeight() * line
    width  = @contents.width - @textPadding() * 2
    height = @lineHeight();
    x += Math.floor width * x_move if x_move != undefined
    @contents.drawText text, x, y, width, height, align

Window_Base.prototype.drawSkill = (line, width, skill, cost)->
    skill = $dataSkills[skill] if typeof skill == 'number'
    y = @lineHeight() * line
    @drawItemName skill, 0, y, width
    cost = skill.mpCost if cost < 0 || cost == undefined
    @contents.drawText cost.toString(), 0, y, width, @lineHeight(), 'right'

class Window_StoneList extends @Window_Selectable
    constructor: (x, y)->
        @initialize.call this, x, y, @windowWidth(), @windowHeight()
        @owner = this
        @refresh()
    
    drawItem: (index) ->
        stone = @magicStoneAtIndex index
        return if stone == null || stone == undefined
        @changePaintOpacity @isEnabled.call @owner, stone
        rect = @itemRectForText index
        @contents.drawText stone._name, rect.x, rect.y, rect.width, rect.height, 'left'
        @changePaintOpacity 1

    magicStoneAtIndex: (index) ->
        $gameParty.magicStones()[index]

    magicStoneChosen: ->
        @magicStoneAtIndex this._index

    maxItems: (index) ->
        Math.max 1, $gameParty.magicStones().length

    updateHelp: ->
        @setHelpWindowItem @magicStoneChosen()

    windowWidth: ->
        Graphics.width / 2

    windowHeight: ->
        340

    createHelpWindow: ->
        this._helpWindow = new Window_StoneHelp 0
        @addChild this._helpWindow

    isEnabled: (stone)->
        true

class Window_StoneHelp extends @Window_Base
    constructor: (windowX)->
        windowHeight = @lineHeight() * 7 + 32
        windowY = Graphics.boxHeight - windowHeight
        @initialize.call this, windowX, windowY, Graphics.width / 2, windowHeight
        @stone = null
        if MagicStoneParameters.showProficiencyNumber != 'yes'
            @proficiencyProgressBar = @createPreogressBar 1
         if MagicStoneParameters.showEnergyNumber != 'yes'
            @energyProgressBar = @createPreogressBar 2

    createPreogressBar: (line) ->
        bar = new Spriteset_Progressbar()
        bar.y = @lineHeight() * line + 20
        bar.x = @width / 2
        bar.visible = false
        @addChild bar

    refresh: ()->
        @contents.clear()
        return if @stone == null || @stone == undefined
        @drawTextOnLine 0, @stone._name, 'left'
        @drawTextOnLine 0, @stone._level, 'right'
        @drawTextOnLine 1, "熟练度", 'left'
        if MagicStoneParameters.showProficiencyNumber == 'yes'
            @drawTextOnLine 1, "#{@stone._proficiency} / #{@stone._maxProficiency}", 'right'
        else
            @proficiencyProgressBar.visible = true
            @proficiencyProgressBar.setValue @stone.proficiencyRatio()
        if MagicStoneParameters.showEnergyNumber == 'yes'
            @drawTextOnLine 2, "#{@stone._energy} / #{@stone._maxEnergy}", 'right'
        else
            @energyProgressBar.visible = true
            @energyProgressBar.setValue @stone.energyRatio()
        @drawTextOnLine 2, "能量", "left"
        if @stone._skills.length == 0
            @drawTextOnLine 4, "没有技能", 'center'
        else 
            for i in [0..(@stone._skills.length - 1)]
                line = 3 + Math.floor i / 2
                skillID = @stone._skills[i]
                skill = $dataSkills[skillID]
                @drawTextOnLine line, skill.name, 'left', (i % 2) / 2
    
    setItem: (item)->
        @stone = item
        @refresh()

class Window_TransferSkillList extends Window_Selectable
    constructor: ()->
        width = @windowWidth()
        x = (Graphics.boxWidth - width) / 2
        @initialize.call this, x, 0, width, 100

    updateHelp: ()->
        @setHelpWindowItem @selectedSkill()
    
    setSkills: (skills)->
        @datas = skills
        this.height = @lineHeight() * skills.length + 2 * this.standardPadding()
        fullHeight = this.height + this._titleWindow.height + this._helpWindow.height
        this.y = (Graphics.boxHeight - fullHeight) / 2 + this._titleWindow.height
        this._helpWindow.y = this.height
        @createContents()
        @refresh()

    windowWidth: ->
        400

    maxItems: ->
        return 1 if @datas == null || @datas == undefined
        Math.max 1, @datas.length

    skillAtIndex: (index)->
        $dataSkills[@datas[index]]

    selectedSkill: ->
        @skillAtIndex this.index()

    drawItem: (index) ->
        return if @datas == null || @datas == undefined || @datas.length == 0
        skill = $dataSkills[@datas[index]]
        @changePaintOpacity @itemEnabled index
        @drawSkill index, @contents.width, skill, @fromStone.mpCost skill
        @changePaintOpacity 1

    itemEnabled: (index)->
        return true if !@toStone
        skill = @skillAtIndex index
        MagicStoneManager.canReceiveSkill(@toStone, skill) == 'ok'

    createHelpWindow: ->
        this._helpWindow = new Window_TransferSkillHelp 0, @height, @width
        this._helpWindow.openness = this.openness
        @addChild this._helpWindow

    createTitleWindow: ->
        height = this.lineHeight() + this.standardPadding() * 2
        this._titleWindow = new Window_Base 0, -height, this._width, height
        this._titleWindow.openness = this.openness
        this._titleWindow.contents.drawText "请选择技能", 0, 0, this._titleWindow.contents.width, @lineHeight(), 'center'
        @addChild this._titleWindow

    setOpenness: (value)->
        this.openness = value
        this._helpWindow.openness = value if this._helpWindow != undefined and this._helpWindow != null
        this._titleWindow.openness = value if this._titleWindow != undefined and this._titleWindow != null

    setStones: (fromStone, toStone)->
        @fromStone = fromStone
        @toStone = toStone
        this._helpWindow.toStone = toStone

    open: ->
        Window_Base.prototype.open.call this
        this._helpWindow.open()
        this._titleWindow.open()

    close: ->
        Window_Base.prototype.close.call this
        this._helpWindow.close()
        this._titleWindow.close()

class Window_TransferSkillHelp extends Window_Base
    constructor: (x, y, width)->
        line = 0
        content = MagicStoneParameters.showContentWhenTransfer
        switch content
            when 'energy' then line = 1
            when 'mp' then line = 1
            when 'both' then line = 2
            when 'none' then line = 0
        height = @lineHeight() * line + @standardPadding() * 2
        height = 0 if line == 0
        @initialize.call this, x, y, width, height
        @createProgressBar() if MagicStoneParameters.showEnergyNumber != 'yes'
    setItem: (item)->
        @skill = item
        @refresh()

    createProgressBar: ->
        @progressBar = new Spriteset_Progressbar
        @progressBar.visible = false
        @addChild @progressBar

    refresh: ->
        return if !@skill or !@toStone
        @contents.clear()
        @focusLine = 0
        result = MagicStoneManager.canReceiveSkill @toStone, @skill
        switch result
            when 'refuse'
                @setText "这块魔石不允许接收该技能。"
            when 'contains'
                @setText "这块魔石已经有这个技能了。"
            else
                switch MagicStoneParameters.showContentWhenTransfer
                    when 'mp' then @drawPredictedSkill()
                    when 'energy' then @drawPredictedEnergy()
                    when 'both'
                        @drawPredictedSkill()
                        @drawPredictedEnergy()
    setText: (text) ->
        @progressBar.visible = false if @progressBar
        @contents.drawText text, 0, (@contents.height - @lineHeight()) / 2, @contents.width, @lineHeight(), 'center'
    drawPredictedSkill: ->
        return if !@toStone
        @drawSkill @focusLine, @contents.width, @skill, @toStone.mpCost @skill
        @focusLine += 1

    drawPredictedEnergy: ->
        return if !@toStone
        @drawTextOnLine @focusLine, "转录后能量", "left"
        if MagicStoneParameters.showEnergyNumber == 'yes'
            text = "#{@toStone._energy + @toStone.energyCost @skill} / #{@toStone._maxEnergy}"
            @drawTextOnLine @focusLine, text, "right"
        else
            predicted = @toStone.predictedEnergyRatio @skill
            if predicted > 1
                @progressBar.visible = false
                @drawTextOnLine @focusLine, "能量不足", "left", 0.5
            else 
                @progressBar.visible = true
                @progressBar.x = @width / 2
                @progressBar.y = @focusLine * @lineHeight() + 6 + @standardPadding()
                @progressBar.setValue @toStone.predictedEnergyRatio @skill
        @focusLine += 1

    close: ->
        Window_Base.prototype.close.call this
        @progressBar.visible = false if @progressBar

class @Scene_Transfer extends @Scene_Base
    constructor: ()->
        @initialize.call this

    start: ()->
        Scene_Base.prototype.start.call this
       
    create: ()->
        @createWindowLayer()
        @createFromWindows()
        @createToWindows()
        @createSkillWinodw()
        @createMessageWindow()
        @switchState 'from'

    createFromWindows: ->
        @fromStoneListWindow = new Window_StoneList 0, 0
        @fromStoneListWindow.createHelpWindow()
        @fromStoneListWindow.setHandler 'ok', @onFromListOk.bind this
        @fromStoneListWindow.setHandler 'cancel', @onFromListCancel.bind this
        @fromStoneListWindow.isEnabled = (stone) ->
            !(stone.isEmpty())
        @fromStoneListWindow.refresh()
        @addChild @fromStoneListWindow

    createToWindows: ->
        @toStoneListWindow = new Window_StoneList Graphics.width / 2, 0
        @toStoneListWindow.createHelpWindow()
        @toStoneListWindow.setHandler 'ok', @onToListOK.bind this
        @toStoneListWindow.setHandler 'cancel', @onToListCancel.bind this
        @toStoneListWindow.isEnabled = (stone) ->
            !stone.isFull() && stone != @fromMagicStone
        @toStoneListWindow.owner = this
        @toStoneListWindow.refresh()
        @addChild @toStoneListWindow

    createSkillWinodw: ->
        @skillListWindow = new Window_TransferSkillList
        @skillListWindow.setOpenness 0
        @skillListWindow.createHelpWindow()
        @skillListWindow.createTitleWindow()
        @skillListWindow.setHandler 'ok', @onSkillListOK.bind this
        @skillListWindow.setHandler 'cancel', @onSkillListCancel.bind this
        @addChild @skillListWindow

    createMessageWindow: ->
        @messageWindow = new Window_Base
        @messageWindow.openness = 0
        @addChild @messageWindow

    update: ()->
        Scene_Base.prototype.update.call this
        if @state == 'message' or @state == 'progress'
            if Input.isRepeated('ok') or Input.isTriggered('cancel')
                @onMessageWindowOK();

    switchState: (state)->
        switch state
            when 'from'
                @fromStoneListWindow.activate()
                @fromStoneListWindow.select 0 if @fromStoneListWindow.index() < 0
                @toStoneListWindow.deactivate()
            when 'to'
                @fromStoneListWindow.deactivate()
                @toStoneListWindow.activate()
                @toStoneListWindow.select 0 if @toStoneListWindow.index() < 0
            when 'skill'
                @fromStoneListWindow.deactivate()
                @toStoneListWindow.deactivate()
                @skillListWindow.open()
                @skillListWindow.activate()
                @skillListWindow.select 0
            when 'message'
                @lastState = @state
                @fromStoneListWindow.deactivate()
                @toStoneListWindow.deactivate()
                @messageWindow.open()
            when 'progress'
                @lastState = 'from'
                @toStoneListWindow.select -1
                @skillListWindow.close()
                @messageWindow.open()
        @state = state

    onFromListOk: ()->
        @fromMagicStone = @fromStoneListWindow.magicStoneChosen()
        if @fromMagicStone.isEmpty()
            @setMessageWindow "这个魔石上没有刻录技能。"
            @switchState 'message'
        else
            @toStoneListWindow.redrawItem @fromStoneListWindow.index()
            @switchState 'to'

    onFromListCancel: ->
        SceneManager.goto(Scene_Map)

    onToListOK: ->
        @toMagicStone = @toStoneListWindow.magicStoneChosen()
        if @toMagicStone == @fromMagicStone
            @setMessageWindow "这两者是同一块魔石。"
            @switchState 'message'
        else if @toMagicStone.isFull()
            @setMessageWindow "这块魔石已经写满了。"
            @switchState 'message'
        else
            @skillListWindow.setStones @fromMagicStone, @toMagicStone
            @skillListWindow.setSkills @fromMagicStone._skills
            @switchState 'skill'

    onToListCancel: ()->
        @fromMagicStone = null
        @toStoneListWindow.redrawItem @fromStoneListWindow.index()
        @toStoneListWindow.select -1
        @switchState 'from'

    onSkillListOK: ()->
        skill = @skillListWindow.selectedSkill()
        switch MagicStoneManager.canReceiveSkill(@toMagicStone, skill)
            when 'explosion'
                @setMessageWindow "这块魔石的剩余能量不足。"
                @switchState 'message'
            when 'refuse'
                @setMessageWindow "这块魔石无法接收这个技能。"
                @switchState 'message'
            when 'contains'
                @setMessageWindow "这块魔石已经有这个技能了。"
                @switchState 'message'
            when 'ok'
                result = MagicStoneManager.transferSkill @fromMagicStone, @toMagicStone, skill
                switch result
                    when 'fail'
                        if MagicStoneParameters.overEnergy == 'hint'
                            @setMessageWindow "这块魔石的剩余能量不足。"
                            @switchState 'message'
                        else
                            @destroyToMagicStone()
                            @setMessageWindow "魔石的剩余能量不足，爆炸了……"
                            @switchState 'progress'
                    when 'success'
                        @setMessageWindow "技能已经转录了。"
                        @switchState 'progress'
                    when 'destroy transfer'
                        @destroySourceMagicStone()
                        @setMessageWindow "技能已经转录了。\n来源的魔石化成了粉末。"
                        @switchState 'progress'
                    when 'destroy clear'
                        @destroySourceMagicStone()
                        @setMessageWindow "技能已经转录了。\n 来源的魔石化成了粉末。"
                        @switchState 'progress'

    onSkillListCancel: ->
        @toMagicStone = null
        @skillListWindow.close()
        @switchState 'to'

    onMessageWindowOK: ->
        @messageWindow.close()
        @switchState @lastState

    destroySourceMagicStone: ->
    destroyToMagicStone: ->

    setMessageWindow: (message, line)->
        line = line || 1
        width = @messageWindow.textWidth message
        @messageWindow.width = width + @messageWindow.standardPadding() + 2 * @messageWindow.textPadding()
        @messageWindow.height = @messageWindow.lineHeight() * line + 2 * @messageWindow.standardPadding()
        @messageWindow.x = (Graphics.boxWidth - @messageWindow.width) / 2
        @messageWindow.y = (Graphics.boxHeight - @messageWindow.height) / 2
        @messageWindow.createContents()
        @messageWindow.drawTextEx message, @messageWindow.textPadding(), 0


Game_Interpreter.prototype.pluginCommand = (command, args) ->
    this._MagicStone_Alias_pluginCommand command, args
    if command == 'MagicStone'
        switch args[0]
            when 'test'
                $gameParty.magicStones().push new MagicStone "简单的石头", 1, 1.4, [6,7,8,9], 35, 60, 100
                $gameParty.magicStones().push new MagicStone "老旧的石头", 0, 2.5, [1,2,3,4,5], 5, 100, 100
            when 'fromItem'
                idString = args[1]
                throw new exception 'create magic stone from item with no id' if idString == undefined || idString == null
                id = parseInt idString
                MagicStoneManager.gainMagicStone MagicStoneManager.generateMagicStoneFromItem id
