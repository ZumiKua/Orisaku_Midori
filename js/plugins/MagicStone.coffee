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
    @desc Decide show the number or progress bar of proficiency when magic stone is showm.
    'yes' or 'no'

    @param showContentWhenTransfer
    @default none
    @desc Decide show what content for target skill in new magic stone when transferring.
    'energy', 'mp', 'both' or 'none'

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

###

Game_Party.prototype._MagicStone_Alias_initAllItems = Game_Party.prototype.initAllItems
Game_Interpreter.prototype._MagicStone_Alias_pluginCommand = Game_Interpreter.prototype.pluginCommand

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
        this._energy += this.energyCost(skill_id) for skill_id in this._skills
    
    mpCost: (skill) ->
        origin = skill.mpCost
        switch PluginManager.paramteres 'skillFactorInfluence'
            when 'nothing' then origin
            when 'add'     then Math.ceil origin + this._magicFactor
            when 'times'   then Math.ceil origin * this._magicFactor
            when 'replace' then Math.ceil this._magicFactor
            else                Math.ceil origin * this._magicFactor

    energyCost: (skill_id) ->
        skill = $dataSkills[skill_id]
        data = skill.meta.energyCost
        return 0 if data == null || data == undefined
        parseInt data

    transfer: (skill) ->
        cost = energyCost skill
        if this._energy + cost > this._maxEnergy
            return false
        else 
            this._energy += cost
            this._skill.push skill
            return true

    proficiencyRatio: ()->
        this._proficiency / this._maxProficiency
    energyRatio: ()->
        return this._energy / this._maxEnergy

Game_Party.prototype.initAllItems = () ->
    this._MagicStone_Alias_initAllItems();
    this._magicStones = []

Game_Party.prototype.magicStones = ()->
    this._magicStones

Game_Party.prototype.generateMagicStoneRandomly = (minLevel, maxLevel) ->

Game_Party.prototype.generateMagicStoneFromItem = (itemIndex) ->
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
        console.log value
        @value = value
        @refresh()

Window_Base.prototype.drawTextOnLine = (line, text, align, x_move) ->
    x = this.textPadding()
    y = this.lineHeight() * line
    width  = @contents.width - this.textPadding() * 2
    height = this.lineHeight();
    x += Math.floor width * x_move if x_move != undefined
    @contents.drawText text, x, y, width, height, align

class Window_StoneList extends @Window_Selectable
    constructor: (x, y)->
        @initialize.call this, x, y, @windowWidth(), @windowHeight()
        @refresh()
    
    drawItem: (index) ->
        stone = @magicStoneAtIndex index
        return if stone == null || stone == undefined
        rect = @itemRectForText index
        @contents.drawText stone._name, rect.x, rect.y, rect.width, rect.height, 'left'

    magicStoneAtIndex: (index) ->
        $gameParty.magicStones()[index]

    maxItems: (index) ->
        Math.max 1, $gameParty.magicStones().length

    updateHelp: ()->
        @setHelpWindowItem @magicStoneAtIndex this._index

    windowWidth: () ->
        Graphics.width / 2

    windowHeight: () ->
        340

    createHelpWindow: ()->
        this._helpWindow = new Window_StoneHelp 0
        @addChild this._helpWindow

class Window_StoneHelp extends @Window_Base
    constructor: (windowX)->
        windowHeight = @lineHeight() * 7 + 32
        windowY = Graphics.boxHeight - windowHeight
        @initialize.call this, windowX, windowY, Graphics.width / 2, windowHeight
        @stone = null
        if PluginManager.parameters('showProficiencyNumber') != 'yes'
            @proficiencyProgressBar = @createPreogressBar 1
         if PluginManager.parameters('showEnergyNumber') != 'yes'
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
        if PluginManager.parameters('showProficiencyNumber') == 'yes'
            cosnole.log "#{@stone._proficiency} / #{@stone._maxProficiency}"
            @drawTextOnLine 1, "#{@stone._proficiency} / #{@stone._maxProficiency}"
        else
            @proficiencyProgressBar.visible = true
            @proficiencyProgressBar.setValue @stone.proficiencyRatio()
        if PluginManager.parameters('showEnergyNumber') == 'yes'
            @drawTextOnLine 1, "#{@stone._energy} / #{@stone._maxEnergy}"
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
        @initialize.call this

    updateHelp: ()->

class Window_TransferSkillHelp extends Window_Base
    constructor: ()->
        @initialize.call this
            

class @Scene_Transfer extends @Scene_Base
    constructor: ()->
        @initialize.call this

    start: ()->
        Scene_Base.prototype.start.call this
       
    create: ()->
        @createWindowLayer()
        @createWindows();
        @switchState 'from'

    createWindows:  ()->
        @fromStoneListWindow= new Window_StoneList 0, 0
        @toStoneListWindow = new Window_StoneList Graphics.width / 2, 0
        @fromStoneListWindow.createHelpWindow()
        @toStoneListWindow.createHelpWindow()
        @skillListWindow = new Window_TransferSkillList
        @skillHelpWindow.createHelpWindow()
        @addWindow @fromStoneListWindow
        @addWindow @toStoneListWindow

    update: ()->
        Scene_Base.prototype.update.call this

    switchState: (state)->
        switch state
            when 'from'
                @fromStoneListWindow.activate()
                @fromStoneListWindow.select 0
                @toStoneListWindow.deactivate()
            when 'to'
                @fromStoneListWindow.deactivate()
                @toStoneListWindow.activate()
                @toStoneListWindow.select 0
            when 'skill'
                @fromStoneListWindow.deactivate()
                @toStoneListWindow.deactivate()
                @skillListWindow.open
            when 'progress'
                @skillListWindow.close
                

Game_Interpreter.prototype.pluginCommand = (command, args) ->
    this._MagicStone_Alias_pluginCommand command, args
    if command == 'MagicStone'
        switch args[0]
            when 'test'
                $gameParty.magicStones().push new MagicStone "简单的石头", 1, 1, [1,2,3,4,5], 100, 60, 100
            when 'fromItem'
                idString = args[1]
                throw new exception 'create magic stone from item with no id' if idString == undefined || idString == null
                id = parseInt idString
                $gameParty.magicStones().push $gameParty.generateMagicStoneFromItem id