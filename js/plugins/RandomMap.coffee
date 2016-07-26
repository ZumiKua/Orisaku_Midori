###:
    @plugindesc Generate Map randomly.
    @author IamI
###

Math.randomIntWithMinMax = (min, max)->
    Math.floor(Math.random() * (max - min + 1)) + min

Array.prototype.fill = (num)->
    for i in [0..@length - 1]
        this[i] = num
    this

class Point 
    constructor: (x, y) ->
        @x = x
        @y = y

RandomMapManager = ->
    throw new error "This is a static clss"

RandomMapManager.Prim = ->
    throw new error "This is a static class"

RandomMapManager.constantSurroudings = [[-1, 0], [1, 0], [0, -1], [0, 1]]
RandomMapManager.constantPass = 0
RandomMapManager.constantWall = 1
RandomMapManager.constantEntranceFlag = 2
RandomMapManager.constantExitFlag = 3

RandomMapManager.Prim.generateRandomStructure = (width, height)->
    actualWidth = width * 2 + 1
    actualHeight = height * 2 + 1
    map = RandomMapManager.generateArray actualWidth, actualHeight
    walls = []
    starterX = Math.randomIntWithMinMax 1, width - 1
    starterY = Math.randomIntWithMinMax 1, height - 1
    starter = new Point 2 * starterX - 1, 2 * starterY - 1
    map[starter.y][starter.x] = RandomMapManager.constantPass
    walls = walls.concat RandomMapManager.surroundingWalls starter.x, starter.y, actualWidth, actualHeight, map
    while walls.length > 0
        wallIndex = Math.randomIntWithMinMax 0, walls.length - 1
        wall = walls[wallIndex]
        for movement in RandomMapManager.constantSurroudings
            road = new Point wall.x + movement[0], wall.y + movement[1]
            continue if RandomMapManager.outTheBoard road.x, road.y, actualWidth, actualHeight
            continue if map[road.y][road.x] == RandomMapManager.constantWall
            mirror = new Point wall.x - movement[0], wall.y - movement[1]
            continue if RandomMapManager.outTheBoard mirror.x, mirror.y, actualWidth, actualHeight
            continue if map[mirror.y][mirror.x] != RandomMapManager.constantWall
            map[wall.y][wall.x] = RandomMapManager.constantPass
            map[mirror.y][mirror.x] = RandomMapManager.constantPass
            walls = walls.concat RandomMapManager.surroundingWalls mirror.x, mirror.y, actualWidth, actualHeight, map
        walls.splice wallIndex, 1
    map

RandomMapManager.generateArray = (width, height, value)->
    value = value || RandomMapManager.constantWall
    arr = []
    for i in [1..height]
        arr.push new Array(width).fill value
    arr

RandomMapManager.outTheBoard = (x, y, width, height)->
    # 边框化
    return true if x <= 0 or x >= width - 1
    return true if y <= 0 or y >= height - 1
    false

RandomMapManager.isLegalWall = (x, y, width, height, map) ->
    return false if RandomMapManager.outTheBoard x, y, width, height, map
    map[y][x] == RandomMapManager.constantWall

RandomMapManager.surroundingWalls = (x, y, width, height, map)->
    arr = []
    arr.push new Point(x - 1, y) if RandomMapManager.isLegalWall x - 1, y, width, height, map
    arr.push new Point(x + 1, y) if RandomMapManager.isLegalWall x + 1, y, width, height, map
    arr.push new Point(x, y - 1) if RandomMapManager.isLegalWall x, y - 1, width, height, map
    arr.push new Point(x, y + 1) if RandomMapManager.isLegalWall x, y + 1, width, height, map
    arr

RandomMapManager.constantAreaWall = 255
RandomMapManager.constantAreaHorizontal = 1
RandomMapManager.constantAreaLongitudinal = 2
RandomMapManager.constantAreaLeftToUp = 3
RandomMapManager.constantAreaLeftToDown = 4
RandomMapManager.constantAreaRightToUp = 5
RandomMapManager.constantAreaRightToDown = 6
RandomMapManager.constantAreaExceptLeft = 7
RandomMapManager.constantAreaExceptDown = 8
RandomMapManager.constantAreaExceptUp = 9
RandomMapManager.constantAreaExceptRight = 10
RandomMapManager.constantAreaCross = 11
RandomMapManager.constantAreaToLeftDead = 12
RandomMapManager.constantAreaToRightDead = 13
RandomMapManager.constantAreaToUpDead = 14
RandomMapManager.constantAreaToDownDead = 15
RandomMapManager.constantAreaExit = 16
RandomMapManager.constantAreaEntrance = 17

RandomMapManager.convertStructureToAreaId = (map) ->
    height = map.length
    width = map[0].length
    actualHeight = (height - 1) / 2
    actualWidth = (width - 1) / 2
    area = RandomMapManager.generateArray actualWidth + 2, actualHeight, RandomMapManager.constantAreaWall # + 2 for entrance and exit
    for i in [1..actualWidth]
        for j in [1..actualHeight]
            x = 2 * i - 1 
            y = 2 * j - 1
            throw new Error "A Wall" if map[y][x] == RandomMapManager.constantWall
            surroundings = []
            passCount = 0   
            for surrounding in RandomMapManager.constantSurroudings
                surroundingX = x + surrounding[0]
                surroundingY = y + surrounding[1]
                passes = map[surroundingY][surroundingX]
                passCount += 1 if passes != RandomMapManager.constantWall
                surroundings.push passes
            areaId = RandomMapManager.constantAreaWall
            switch passCount
                when 4
                    areaId = RandomMapManager.constantAreaCross
                when 3
                    if surroundings[0] == RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaExceptLeft
                    else if surroundings[1] == RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaExceptRight
                    else if surroundings[2] == RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaExceptUp
                    else if surroundings[3] == RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaExceptDown
                when 2
                    if (surroundings[0] != RandomMapManager.constantWall) and (surroundings[1] != RandomMapManager.constantWall)
                        areaId = RandomMapManager.constantAreaHorizontal
                    if (surroundings[0] != RandomMapManager.constantWall) and (surroundings[2] != RandomMapManager.constantWall)
                        areaId = RandomMapManager.constantAreaLeftToUp
                    if (surroundings[0] != RandomMapManager.constantWall) and (surroundings[3] != RandomMapManager.constantWall)
                        areaId = RandomMapManager.constantAreaLeftToDown
                    if (surroundings[1] != RandomMapManager.constantWall) and (surroundings[2] != RandomMapManager.constantWall)
                        areaId = RandomMapManager.constantAreaRightToUp
                    if (surroundings[1] != RandomMapManager.constantWall) and (surroundings[3] != RandomMapManager.constantWall)
                        areaId = RandomMapManager.constantAreaRightToDown
                    if (surroundings[2] != RandomMapManager.constantWall) and (surroundings[3] != RandomMapManager.constantWall)
                        areaId = RandomMapManager.constantAreaLongitudinal
                when 1
                    if surroundings[0] != RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaToRightDead
                    else if surroundings[1] != RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaToLeftDead
                    else if surroundings[2] != RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaToDownDead
                    else if surroundings[3] != RandomMapManager.constantWall
                        areaId = RandomMapManager.constantAreaToUpDead
            area[j - 1][i - 1 + 1] = areaId # + 1 for entrance
    for j in [1..actualHeight - 1]
        if map[2 * j - 1][0] == RandomMapManager.constantEntranceFlag      
            area[j - 1][0] = RandomMapManager.constantAreaEntrance
        if map[2 * j - 1][width - 1] == RandomMapManager.constantExitFlag
            area[j - 1][actualWidth + 1] = RandomMapManager.constantAreaExit
    console.log map, area
    area 

RandomMapManager.cloneEvent = (event) ->
    { id: event.id, name: event.name, note: event.note, pages: event.pages, x: event.x, y: event.y }


class RandomMapManager.MapSource
    constructor: (dataMap) ->
        @width = dataMap.width
        @height = dataMap.height
        #dataMap.meta = {}
        DataManager.extractMetadata dataMap if !dataMap.meta
        @blockWidth = parseInt(dataMap.meta.blockWidth) || 5
        @blockHeight = parseInt(dataMap.meta.blockHeight) || 5
        @entrancePosition = parseInt(dataMap.meta.entrancePosition) || (@blockHeight - 1) / 2
        @mapElements = {}
        @mapEvents = {}
        @data = dataMap.data
        @analyzeMap @data
        @analyzeEvents dataMap.events

    analyzeMap: (data)->
        offset = @width * @height * 5
        index = offset
        while index <= @width * @height * 6
            index = border + 1 if index % @width == 0 and border
            while data[index] == 0
                index += 1
            area = data[index]
            # we only check the leftUp and the rightDown corner.
            border = index + @blockWidth + (@blockHeight - 1) * @width - 1
            if data[border] != area
                index += 1
                continue
            @mapElements[area] = [] if !@mapElements[area]
            @mapElements[area].push index - offset
            index += @blockWidth
        0

    analyzeEvents: (events)->
        for event in events
            continue if !event
            area = @data[@width * @height * 5 + event.y * @width + event.x]
            next if !@mapElements[area]
            for startIndex in @mapElements[area]
                if @inArea event.x, event.y, startIndex
                    @mapEvents[startIndex] = [] if !@mapEvents[startIndex]
                    @mapEvents[startIndex].push event
                    break

    inArea: (x, y, areaStartIndex)->
        areaStartY = Math.floor areaStartIndex / @width
        areaStartX = areaStartIndex % @width
        (areaStartY < y < (areaStartY + @blockHeight)) and (areaStartX < x < (areaStartX + @blockWidth))

    getMapData: (data, x, y, z) ->
        return data[@width * @height * z + y * @width + x]

    copyMapData: (sourceStartIndex, receiver, receiverStartX, receiverStartY, receiverMapWidth, receiverMapHeight, zRange) ->
        zRange = zRange || [0..4]
        offset = receiverStartY * receiverMapWidth + receiverStartX
        for z in zRange
            sourceBase = sourceStartIndex + z * @width * @height
            receiverBase = z * receiverMapWidth * receiverMapHeight + offset
            for j in [0..@blockHeight - 1]
                for i in [0..@blockWidth - 1]
                    receiver[receiverBase + j * receiverMapWidth + i] = @data[sourceBase + j * @width + i]
        0

    copyEventData: (sourceStartIndex, receiver, receiverStartX, receiverStartY) ->
        events = @mapEvents[sourceStartIndex]
        return if !events
        for event in events
            sourceStartX = sourceStartIndex % @width
            sourceStartY = Math.floor sourceStartIndex / @width
            mirrorEvent = RandomMapManager.cloneEvent event
            mirrorEvent.x = event.x - sourceStartX + receiverStartX
            mirrorEvent.y = event.y - sourceStartY + receiverStartY
            mirrorEvent.id = receiver.length
            receiver.push mirrorEvent

    generateMap: (sourceData, mapData, eventData, mapWidth, mapHeight)->
        mapData = mapData || $dataMap.data
        eventData = eventData || $dataMap.events
        mapWidth = mapWidth || $dataMap.width
        mapHeight = mapHeight || $dataMap.height
        height = sourceData.length
        width = sourceData[0].length
        for j in [0..height - 1]
            for i in [0..width - 1]
                areaId = sourceData[j][i]
                choices = @mapElements[areaId]
                continue if !choices
                startIndex = choices[Math.randomIntWithMinMax(0, choices.length - 1)]
                entrance = j if areaId == RandomMapManager.constantAreaEntrance
                @copyMapData startIndex, mapData, i * @blockWidth, j * @blockHeight, mapWidth, mapHeight
                @copyEventData startIndex, eventData, i * @blockWidth, j * @blockHeight
        entrance = entrance || 0
        entrance * @blockHeight + @entrancePosition

RandomMapManager.MapSource.loadMap = (id)->
    id = id.padZero(3) if typeof id != 'string'
    fileName = "Map#{id}.json"
    $sourceMap = null
    DataManager.loadDataFile '$sourceMap', fileName

RandomMapManager.MapSource.loadMapByFs = (id)->
    id = id.padZero(3) if typeof id != 'string'
    fileName = "../Data/Map#{id}.json"
    fs = require 'fs'
    fs.readFileSync(fileName).toString()

RandomMapManager.makeEntranceAndExit = (map)->
    # Entrance Only on left
    entrance = Math.randomIntWithMinMax 0, (map.length - 3) / 2
    map[entrance * 2 + 1][0] = RandomMapManager.constantEntranceFlag
    #map[entrance * 2 + 1][2] = RandomMapManager.constantPass
    # Exit Only on right
    exit = Math.randomIntWithMinMax 0, (map.length - 3) / 2
    map[exit * 2 + 1][map[0].length - 1] = RandomMapManager.constantExitFlag
    #map[exit * 2 + 1][map[0].length - 3] = RandomMapManager.constantPass

@RandomMapManager = RandomMapManager

RandomMapManager.generateAreaArrayByPrim = (width, height) ->
    struct = RandomMapManager.Prim.generateRandomStructure width, height
    RandomMapManager.makeEntranceAndExit struct
    area = RandomMapManager.convertStructureToAreaId struct
    area

RandomMapManager.Test = ->
    throw new error "This is a static class"
    
RandomMapManager.Test.test1 = ->
    file = RandomMapManager.MapSource.loadMapByFs "002"
    data = JSON.parse file
    c = new RandomMapManager.MapSource data
    struct = RandomMapManager.Prim.generateRandomStructure(10, 10)
    RandomMapManager.makeEntranceAndExit struct
    console.log struct
    generate = RandomMapManager.convertStructureToAreaId struct
    console.log generate
    data = new Array 2500
    c.generateMap generate, data, 50, 50

#RandomMapManager.Test.test1()

_RandomMap_Alias_Game_Interpreter_pluginCommand = Game_Interpreter.prototype.pluginCommand
_RandomMap_Alias_Game_Interpreter_command201 = Game_Interpreter.prototype.command201
_RandomMap_Alias_Scene_Map_isReady = Scene_Map.prototype.isReady
_RandomMap_Alias_Scene_Map_onMapLoaded = Scene_Map.prototype.onMapLoaded

Game_Interpreter.prototype.pluginCommand = (command, args) ->
    _RandomMap_Alias_Game_Interpreter_pluginCommand command, args
    if command == 'Maze'
        mapID = args[0]
        mapInt = parseInt mapID
        mapID = mapInt if mapInt
        RandomMapManager.MapSource.loadMap mapID

Scene_Map.prototype.IsReady = ->
    if (!this._mapLoaded && DataManager.isMapLoaded())
        if $dataMap.meta.randomMaze
            if !DataManager.isSourceMapLoaded
                console.log 'No source maze map when ready check. Did you set the maze?'
                return false
        @onMapLoaded();
        this._mapLoaded = true;
    this._mapLoaded && Scene_Base.prototype.isReady.call(this);

Scene_Map.prototype.onMapLoaded = ->
    if $dataMap.meta.randomMaze
        size = eval $dataMap.meta.randomMaze
        area = RandomMapManager.generateAreaArrayByPrim size[0], size[1]
        $sourceMap.source = new RandomMapManager.MapSource $sourceMap if !$sourceMap.source
        $gamePlayer._newY = $sourceMap.source.generateMap area
    if (this._transfer)
        $gamePlayer.performTransfer();
    @createDisplayObjects();

DataManager.isSourceMapLoaded = ->
    @checkError()    
    !!$sourceMap 
    

