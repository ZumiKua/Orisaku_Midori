###:
    @plugindesc Help design a Dungeon
    @author IamI

    @param EnemyMap
    @default 7
    @desc Enemy map ID.
###

_DungeonDesigner_Alias_Scene_Map_createAllWindows = Scene_Map.prototype.createAllWindows
_DungeonDesigner_Alias_Scene_Map_update = Scene_Map.prototype.update
_DungeonDesigner_Alias_Scene_Map_onMapLoaded = Scene_Map.prototype.onMapLoaded
_DungeonDesigner_Alias_Game_Interpreter_command301 = Game_Interpreter.prototype.command301

DungeonDesignerParameters = PluginManager.parameters "DungeonDesigner"

Input.keyMapper[121] = 'dungeon' # F10

class Game_Dungeon
    constructor: ->
        this._isDesigningDungeon = false

    start: ->
        target = $gameParty.members()[0]
        this._mapId = $gameMap._mapId
        this._hp = target.mhp
        this._maxhp = target.mhp
        this._mp = target.mmp
        this._maxmp = target.mmp
        this._isDesigningDungeon = true
        this._usedItems = {}
        this._usedSkills = {}
        this._states = []
        this._extraEvents = []
        @loadMap()

    terminate: ->
        this._isDesigningDungeon = false

    loadMap: ->
        id = parseInt(DungeonDesignerParameters.EnemyMap).padZero(3)
        fileName = "Map#{id}.json"
        $enemyZoo = null
        DataManager.loadDataFile '$enemyZoo', fileName

    preloadCharacters: ->
        return if !$enemyZoo
        for event in $enemyZoo.events
            continue if event == null
            ImageManager.loadCharacter(event.pages[0].image.characterName)

    putEvent: (eventIndex)->
        event = $enemyZoo.events[eventIndex]
        dir = [null, [-1, 1], [0, 1], [1, 1], [-1, 0], [0, 0], [0, 1], [1, -1], [1, 0], [1, 1]][$gamePlayer.direction()]
        x = $gamePlayer.x + dir[0]
        y = $gamePlayer.y + dir[1]
        console.log x, y
        targetvent = {
            id: $dataMap.events.length + this._extraEvents.length,
            meta: event.meta,
            name: event.name,
            note: event.note,
            pages: event.pages,
            x: x,
            y: y
        }
        this._extraEvents.push targetvent

    battle: (troop) ->
        # TODO: battle codes

    useItem: (itemIndex)->
        item = $dataItems[itemIndex]
        # TODO: effect item codes
        this._usedItems[itemIndex] = 0 if !this._usedItems[itemIndex]
        this._usedItems[itemIndex] += 1

    useSkill: (skillIndex)->
        skill = $dataSkills[skillIndex]
        # TODO: effect skill codes
        this._usedSkills[skillIndex] = 0 if !this._usedSkills[skillIndex]
        this._usedSkills[skillIndex] += 1

@$gameDungeon = new Game_Dungeon()

Scene_Map.prototype.isDungeonCalled = ->
    Input.isTriggered('dungeon') and $gameTemp.isPlaytest()

Scene_Map.prototype.startDungeon = ->
    $gameDungeon.start()
    @createDungeonHintWindow()

Scene_Map.prototype.finishDungeon = ->
    $gameDungeon._isDesigningDungeon = false
    @removeChild this._dungeonHintWindow

Scene_Map.prototype.createDungeonHintWindow = ->
    this._dungeonHintWindow = new Window_DungeonHint()
    @addWindow this._dungeonHintWindow

Scene_Map.prototype.callDungeonMenu = ->
    SceneManager.push Scene_Dungeon

Scene_Map.prototype.dungeonPressed = ->
    if $gameDungeon._isDesigningDungeon
        @callDungeonMenu()
    else
        @startDungeon()

Scene_Map.prototype.onMapLoaded = ->
    if $gameMap._mapId == $gameDungeon._mapId
        $dataMap.events = $dataMap.events.concat $gameDungeon._extraEvents
        $gameMap.setupEvents()
        console.log $dataMap.events, $gameDungeon._extraEvents
    _DungeonDesigner_Alias_Scene_Map_onMapLoaded.call this

Scene_Map.prototype.createAllWindows = ->
    _DungeonDesigner_Alias_Scene_Map_createAllWindows.call this
    @createDungeonHintWindow() if $gameDungeon._isDesigningDungeon

Scene_Map.prototype.update = ->
    _DungeonDesigner_Alias_Scene_Map_update.call this
    if @isDungeonCalled()
        @dungeonPressed()

Game_Interpreter.prototype.command301 = ->
    if $gameDungeon._isDesigningDungeon
        if this._params[0] == 0
            troopId = this._params[1]
        else if this._params[0] == 1
            troopId = $gameVariables.value(this._params[1])
        else
            troopId = $gamePlayer.makeEncounterTroopId()
        $gameDungeon.battle troopId
        return true
    else
        return _DungeonDesigner_Alias_Game_Interpreter_command301.call this

Window_Base.prototype.drawCharacter = (characterName, characterIndex, x, y, px, py) ->
    px = px || 1
    py = py || 0
    bitmap = ImageManager.loadCharacter(characterName);
    big = ImageManager.isBigCharacter(characterName);
    pw = bitmap.width / (if big then 3 else 12);
    ph = bitmap.height / (if big then 4 else 8);
    n = characterIndex;
    sx = (n % 4 * 3 + px) * pw;
    sy = (Math.floor(n / 4) * 4 + py) * ph;
    this.contents.blt(bitmap, sx, sy, pw, ph, x - pw / 2, y - ph);
    
class Window_DungeonHint extends Window_Base
    constructor: ->
        width = 350
        itemLength = Object.keys($gameDungeon._usedItems).length
        skillLength = Object.keys($gameDungeon._usedSkills).length
        height = @lineHeight() * (2 + itemLength + skillLength) + @standardPadding() * 2
        x = Graphics.boxWidth - width
        y = 0
        @initialize.call this, x, y, width, height
        @refresh()
    
    refresh: ->
        @contents.drawText " 当前 HP #{$gameDungeon._hp} / #{$gameDungeon._maxhp}", 0, 0, @contents.width, @lineHeight()
        @contents.drawText " 当前 MP #{$gameDungeon._mp} / #{$gameDungeon._maxmp}", 0, @lineHeight(), @contents.width, @lineHeight()
        index = 2
        for itemIndex in Object.keys $gameDungeon._usedItems
            item = $dataItems[itemIndex]
            y = index * @lineHeight()
            @drawItemName item, 0, y, @contents.width
            @contents.drawText $gameDungeon._usedItems[itemIndex].toString(), 0, y, @contents.width, @lineHeight(), 'right'
            index += 1
        for skillIndex in Object.keys $gameDungeon._usedSkills
            skill = $dataSkills[skillIndex]
            y = index * @lineHeight()
            @drawItemName skill, 0, y, @contents.width
            @contents.drawText $gameDungeon._usedSkills[skillIndex].toString(), 0, y, @contents.width, @lineHeight(), 'right'
            index += 1

class Scene_Dungeon extends Scene_MenuBase
    constructor: ->
        @initialize.call this
        $gameDungeon.preloadCharacters()
        @state = 'command'
    
    create: ->
        Scene_MenuBase.prototype.create.call this
        @createWindows()

    createWindows: ->
        @createCommandWindow()
        @createItemWindow()
        @createEventWindow()

    createCommandWindow: ->
        this._commandWindow = new Window_DungeonMenu()
        this._windowLayer.addChild this._commandWindow
        this._commandWindow.setHandler 'event', this.commandEvent.bind this
        this._commandWindow.setHandler 'item', this.commandItem.bind this
        this._commandWindow.setHandler 'skill', this.commandSkill.bind this
        this._commandWindow.setHandler 'exit',  this.commandExit.bind this
        this._commandWindow.setHandler 'saveMap', this.commandSaveMap.bind this
        this._commandWindow.setHandler 'cancel', this.cancelCommand.bind this

    createEventWindow: ->
        this._eventWindow = new Window_PutEnemyEvent()
        this._eventWindow.openness = 0
        this._eventWindow.setHandler 'ok', this.useEvent.bind this
        this._eventWindow.setHandler 'cancel', this.cancelEvent.bind this
        this._windowLayer.addChild this._eventWindow

    createItemWindow: ->
        this._itemWindow = new Window_ItemUseList($dataSkills)
        this._itemWindow.openness = 0
        this._itemWindow.setHandler 'ok', this.useObject.bind this
        this._itemWindow.setHandler 'cancel', this.cancelItem.bind this
        this._windowLayer.addChild this._itemWindow

    commandEvent: ->
        @switchState 'event'

    commandItem: ->
        @switchState 'item'

    commandSkill: ->
        @switchState 'skill'

    commandSaveMap: ->
        mapId = $gameMap.mapId()
        dirname = window.location.pathname.replace(/(\/www|)\/[^\/]*$/, '/');
        fileName = dirname + 'data/Map' + mapId.padZero(3) + '.json'
        console.log fileName
        backupFileName = fileName + '.bac'
        fs = require 'fs'
        fs.renameSync fileName, backupFileName
        mapData = JSON.stringify $dataMap
        fs.writeFileSync fileName, mapData
        SceneManager.pop()

    commandExit: ->
        $gameDungeon.terminate()
        SceneManager.pop()

    cancelEvent: ->
        @switchState 'command'

    cancelItem: ->
        @switchState 'command'

    cancelCommand: ->
        SceneManager.pop()

    useEvent: ->
        $gameDungeon.putEvent this._eventWindow.index() + 1
        SceneManager.pop()

    useObject: ->
        if @state == 'item'
            @useItem()
        else if @state == 'skill'
            @useSkill()    

    useItem: ->
        $gameDungeon.useItem this._itemWindow.index() + 1
        SceneManager.pop()

    useSkill: ->    
        $gameDungeon.useSkill this._itemWindow.index() + 1
        SceneManager.pop()

    switchState: (state) ->
        switch state
            when 'event'
                this._eventWindow.activate()
                this._eventWindow.open()
                this._eventWindow.select 0
                this._commandWindow.close()
            when 'item'
                this._itemWindow.list = $dataItems
                this._itemWindow.open()
                this._itemWindow.select 0
                this._itemWindow.activate()
                this._commandWindow.close()
            when 'skill'
                this._itemWindow.list = $dataSkills
                this._itemWindow.open()
                this._itemWindow.select 0
                this._itemWindow.activate()
                this._commandWindow.close()
            when 'command'
                this._itemWindow.close()
                this._eventWindow.close()
                this._commandWindow.open()
                this._commandWindow.activate()
        @state = state

    update: ->
        Scene_MenuBase.prototype.update.call this
        @updateKeys()

    updateKeys: ->
        if Input.isTriggered 'cancel'
            if @state == 'command'
                SceneManager.pop()
            else
                @switchState 'command'
        

class Window_DungeonMenu extends Window_Command
    constructor: ->
        @initialize.call this
        this.x = (Graphics.boxWidth - this.width) / 2
        this.y = (Graphics.boxHeight - this.height) / 2

    makeCommandList: ->
        @addCommand "在面前放置事件", 'event'
        @addCommand "使用物品", 'item'
        @addCommand "使用技能", 'skill'
        @addCommand "生成敌机地图", "createMap", false
        @addCommand "保存当前地图", "saveMap"
        @addCommand "退出设计模式", 'exit'

class Window_PutEnemyEvent extends Window_Selectable
    constructor: ->
        width = @windowWidth()
        height = @windowHeight()
        x = (Graphics.boxWidth - width) / 2
        y = (Graphics.boxHeight - height) / 2
        @initialize.call this, x, y, width, height
        @refresh()
        # 计数器
        this._order = 0
        this._count = 0

    drawItem: (index, order) ->
        order = order || 0
        event = $enemyZoo.events[index + 1]
        return if !event
        image = event.pages[0].image
        rect = @itemRect index
        @drawCharacter image.characterName, image.characterIndex, rect.x + @itemWidth() / 2, rect.y + @itemHeight(), 0, order

    maxItems: ->
        return 1 if !$enemyZoo
        Math.max 1, $enemyZoo.events.length - 1

    itemWidth: ->
        40

    itemHeight: ->
        60
    
    maxCols: ->
        8

    maxRowsDefining: ->
        4

    windowWidth: ->
        (@itemWidth() + @spacing()) * @maxCols() + 2 * @standardPadding()

    windowHeight: ->
        (@itemHeight() + @spacing()) * @maxRowsDefining() + 2 * @standardPadding()

    update: ->
        Window_Selectable.prototype.update.call this
        if @active and this._index >= 0
            this._count += 1
            if this._count >= 5
                this._count -= 5
                this._order = (this._order + 1) % 4
                @redrawItem this._index, this._order
    
    redrawItem: (index, order) ->
        return if index < 0
        @clearItem(index);
        @drawItem(index, order || 0);

    select: (index) ->
        @redrawItem this._index, 0 if this._index >= 0
        Window_Selectable.prototype.select.call this, index

class Window_ItemUseList extends Window_Selectable
    constructor: (list) ->
        this._list = list
        width = 282
        height = 392
        x = (Graphics.boxWidth - width) / 2
        y = (Graphics.boxHeight - height) / 2
        @initialize.call this, x, y, width, height
        @refresh()

    drawItem: (index)->
        return if !this._list
        item = this._list[index + 1]
        return if !item
        rect = @itemRect index
        @drawItemName item, rect.x, rect.y, @contents.width

    maxItems: ->
        return 1 if !this._list
        this._list.length - 1
    
    getList: ->
        this._list

    setList: (value) ->
        this._list = value
        @select 0
        @refresh()

    Object.defineProperty Window_ItemUseList.prototype, 'list', { get: Window_ItemUseList.prototype.getList, set: Window_ItemUseList.prototype.setList }