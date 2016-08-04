###:
    @plugindesc Help design a Dungeon
    @author IamI

    @param EnemyMap
    @default 7
    @desc Enemy map ID.
###

_DungeonDesigner_Alias_Scene_Map_create = Scene_Map.prototype.create
_DungeonDesigner_Alias_Scene_Map_update = Scene_Map.prototype.update
_DungeonDesigner_Alias_Game_Interpreter_command301 = Game_Interpreter.prototype.command301

DungeonDesignerParameters = PluginManager.parameters "DungeonDesigner"

Input.keyMapper[121] = 'dungeon' # F10

class Game_Dungeon
    constructor: ->
        this._isDesigningDungeon = false

    start: ->
        target = $gameParty.members()[0]
        this._hp = target.mhp
        this._maxhp = target.mhp
        this._mp = target.mmp
        this._maxmp = target.mmp
        this._isDesigningDungeon = true
        @loadMap()

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

    putEvent: (event)->

    battle: (troop) ->


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
    @addChild this._dungeonHintWindow

Scene_Map.prototype.callDungeonMenu = ->
    SceneManager.push Scene_Dungeon

Scene_Map.prototype.dungeonPressed = ->
    if $gameDungeon._isDesigningDungeon
        @callDungeonMenu()
    else
        @startDungeon()

Scene_Map.prototype.create = ->
    _DungeonDesigner_Alias_Scene_Map_create.call this
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
        height = @lineHeight() * 2 + @standardPadding() * 2
        x = Graphics.boxWidth - width
        y = 0
        @initialize.call this, x, y, width, height
        @refresh()
    
    refresh: ->
        @contents.drawText " 当前 HP #{$gameDungeon._hp} / #{$gameDungeon._maxhp}", 0, 0, @contents.width, @lineHeight()
        @contents.drawText " 当前 MP #{$gameDungeon._mp} / #{$gameDungeon._maxmp}", 0, @lineHeight(), @contents.width, @lineHeight()

class Scene_Dungeon extends Scene_MenuBase
    constructor: ->
        @initialize.call this
        $gameDungeon.preloadCharacters()
    
    create: ->
        Scene_MenuBase.prototype.create.call this
        @createWindows()

    createWindows: ->
        this._commandWindow = new Window_DungeonMenu()
        this._windowLayer.addChild this._commandWindow
        this._eventWindow = new Window_PutEnemyEvent()
        this._eventWindow.openness = 0
        this._windowLayer.addChild this._eventWindow
        this._itemWindow = new Window_ItemUseList($dataSkills)
        this._itemWindow.list = $dataItems
        this._windowLayer.addChild this._itemWindow
        this._itemWindow.active = true

    update: ->
        Scene_MenuBase.prototype.update.call this
        @updateKeys()

    updateKeys: ->
        SceneManager.pop() if Input.isTriggered 'cancel'


class Window_DungeonMenu extends Window_Command
    constructor: ->
        @initialize.call this
        this.x = (Graphics.boxWidth - this.width) / 2
        this.y = (Graphics.boxHeight - this.height) / 2

    makeCommandList: ->
        @addCommand "在面前放置事件", 'enemy'
        @addCommand "使用物品", 'item'
        @addCommand "使用技能", 'skill'
        @addCommand "生成敌机地图", "createMap", false
        @addCommand "退出设计模式", 'exit'

class Window_PutEnemyEvent extends Window_Selectable
    constructor: ->
        width = @windowWidth()
        height = @windowHeight()
        @initialize.call this, 0, 0, width, height
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
        @initialize.call this, 0, 0, 252, 300
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
        console.log "called"
        this._list = value
        @select 0
        @refresh()

    Object.defineProperty Window_ItemUseList.prototype, 'list', { get: Window_ItemUseList.prototype.getList, set: Window_ItemUseList.prototype.setList }