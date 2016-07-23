###:
    @plugindesc Generate Map randomly.
    @author IamI
###

Math.randomInt = (min, max)->
    Math.floor(Math.random() * (max - min + 1)) + min

Array.prototype.fill = (num)->
    for i in [0..@length - 1]
        this[i] = num

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

RandomMapManager.Prim.generateRandomStructure = (width, height)->
    actualWidth = width * 2 + 1
    actualHeight = height * 2 + 1
    map = RandomMapManager.generateArray actualWidth, actualHeight
    walls = []
    starterX = Math.randomInt 1, width - 1
    starterY = Math.randomInt 1, height - 1
    starter = new Point 2 * starterX - 1, 2 * starterY - 1
    map[starter.y][starter.x] = RandomMapManager.constantPass
    walls = walls.concat RandomMapManager.surroundingWalls starter.x, starter.y, actualWidth, actualHeight, map
    while walls.length > 0
        wallIndex = Math.randomInt 0, walls.length - 1
        wall = walls[wallIndex]
        for movement in RandomMapManager.constantSurroudings
            road = new Point wall.x + movement[0], wall.y + movement[1]
            continue if RandomMapManager.outTheBoard road.x, road.y, actualWidth, actualHeight
            continue if map[road.y][road.x] == RandomMapManager.constantWall
            mirror = new Point wall.x - movement[0], wall.y - movement[1]
            continue if RandomMapManager.outTheBoard mirror.x, mirror.y, actualWidth, actualHeight
            continue if map[mirror.y][mirror.x] == RandomMapManager.constantPass
            map[wall.y][wall.x] = RandomMapManager.constantPass
            map[mirror.y][mirror.x] = RandomMapManager.constantPass
            walls = walls.concat RandomMapManager.surroundingWalls mirror.x, mirror.y, actualWidth, actualHeight, map
        walls.splice wallIndex, 1
    map

RandomMapManager.generateArray = (width, height)->
    arr = []
    for i in [1..height]
        arr.push new Array(width).fill RandomMapManager.constantWall
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

RandomMapManager.constantAreaWall = 0
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
    area = RandomMapManager.generateArray actualWidth, actualHeight
    for i in [1..actualWidth]
        for j in [1..actualHeight]
            x = 2 * i - 1
            y = 2 * j - 1
            throw new error "A Wall" if map[y][x] == RandomMapManager.constantWall
            surroundings = []
            passCount = 0
            for surrounding in RandomMapManager.constantSurroudings
                surroundingX = x + surrounding[0]
                surroundingY = y + surrounding[1]
                passes = map[surroundingY][surroundingX]
                passCount += 1 if passes == RandomMapManager.constantPass
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
                    if (surroundings[0] == RandomMapManager.constantPass) and (surroundings[1] == RandomMapManager.constantPass)
                        areaId = RandomMapManager.constantAreaHorizontal
                    if (surroundings[0] == RandomMapManager.constantPass) and (surroundings[2] == RandomMapManager.constantPass)
                        areaId = RandomMapManager.constantAreaLeftToUp
                    if (surroundings[0] == RandomMapManager.constantPass) and (surroundings[3] == RandomMapManager.constantPass)
                        areaId = RandomMapManager.constantAreaLeftToDown
                    if (surroundings[1] == RandomMapManager.constantPass) and (surroundings[2] == RandomMapManager.constantPass)
                        areaId = RandomMapManager.constantAreaRightToUp
                    if (surroundings[1] == RandomMapManager.constantPass) and (surroundings[3] == RandomMapManager.constantPass)
                        areaId = RandomMapManager.constantAreaRightToDown
                    if (surroundings[2] == RandomMapManager.constantPass) and (surroundings[3] == RandomMapManager.constantPass)
                        areaId = RandomMapManager.constantAreaLongitudinal
                when 1
                    if surroundings[0] == RandomMapManager.constantPass
                        areaId = RandomMapManager.constantAreaToRightDead
                    else if surroundings[1] == RandomMapManager.constantPass
                        areaId = RandomMapManager.constantAreaToLeftDead
                    else if surroundings[2] == RandomMapManager.constantPass
                        areaId = RandomMapManager.constantAreaToDownDead
                    else if surroundings[3] == RandomMapManager.constantPass
                        areaId = RandomMapManager.constantAreaToUpDead
            area[j - 1][i - 1] = areaId
    area

class RandomMapManager.MapSource
    constructor: (dataMap) ->
        @width = dataMap.width
        @height = dataMap.height
        @blockWidth = 5#dataMap.meta.blockWidth || 3
        @blockHeight = 5#dataMap.meta.blockHeight || 3
        @mapElements = {}
        @data = dataMap.data
        @analyzeMap @data

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

    getMapData: (data, x, y, z) ->
        return data[@width * @height * z + y * @width + x]

    copyMapData: (sourceStartIndex, receiver, receiverStartX, receiverStartY, receiverMapWidth, receiverMapHeight, zRange) ->
        zRange = zRange || [0..4]
        offset = receiverStartY * receiverMapWidth + receiverStartX
        for z in zRange
            sourceBase = sourceStartIndex + 5 * @width * @height
            receiverBase = z * receiverMapWidth * receiverMapHeight + offset
            for j in [0..@blockHeight - 1]
                for i in [0..@blockWidth - 1]
                    receiver[receiverBase + j * receiverMapHeight + i] = @data[sourceBase + j * @width + i]
        0

    generateMap: (sourceData, mapData, mapWidth, mapHeight)->
        height = sourceData.length
        width = sourceData[0].length
        for j in [0..height - 1]
            for i in [0..width - 1]
                areaId = sourceData[j][i]
                choices = @mapElements[areaId]
                continue if !choices
                startIndex = choices[Math.randomInt(0, choices.length - 1)]
                @copyMapData startIndex, mapData, i * @blockWidth, j * @blockHeight, mapWidth, mapHeight
        0

RandomMapManager.MapSource.loadMap = (id)->
    id = id.padZero(3) if typeof id != 'string'
    fileName = "Map#{id}.json"
    DataManager.loadDataFile '$lastAnalyzedFile', fileName
    #RandomMapManager.MapSource.wait while $lastAnalyzedFile == null
    #$lastAnalyzedFile

RandomMapManager.MapSource.loadMapByFs = (id)->
    id = id.padZero(3) if typeof id != 'string'
    fileName = "../Data/Map#{id}.json"
    fs = require 'fs'
    fs.readFileSync(fileName).toString()

@RandomMapManager = RandomMapManager

file = RandomMapManager.MapSource.loadMapByFs "002"
data = JSON.parse file
c = new RandomMapManager.MapSource data
generate = RandomMapManager.convertStructureToAreaId RandomMapManager.Prim.generateRandomStructure(10, 10)
data = new Array 2500
c.generateMap generate, data, 50, 50
console.log data