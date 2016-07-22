###:
    @plugindesc Generate Map randomly.
    @author IamI
###

Math.randomInt = (min, max)->
    Math.floor(Math.random() * (max - min + 1)) + min

class Point 
    constructor: (x, y) ->
        @x = x
        @y = y

RandomMapManager = ->
    throw new error "This is a static clss"

RandomMapManager.constant_surroudings = [[-1, 0], [1, 0], [0, -1], [0, 1]]
RandomMapManager.constant_pass = 0
RandomMapManager.constant_wall = 1

RandomMapManager.generateRandomStructureByPrim = (width, height)->
    actualWidth = width * 2 + 1
    actualHeight = height * 2 + 1
    map = @generateArray actualWidth, actualHeight
    walls = []
    starterX = Math.randomInt 1, width - 1
    starterY = Math.randomInt 1, height - 1
    starter = new Point 2 * starterX - 1, 2 * starterY - 1
    map[starter.y][starter.x] = RandomMapManager.constant_pass
    walls = walls.concat RandomMapManager.surroundingWalls starter.x, starter.y, actualWidth, actualHeight, map
    while walls.length > 0
        wallIndex = Math.randomInt 0, walls.length - 1
        wall = walls[wallIndex]
        for movement in RandomMapManager.constant_surroudings
            road = new Point wall.x + movement[0], wall.y + movement[1]
            continue if RandomMapManager.outTheBoard road.x, road.y, actualWidth, actualHeight
            continue if map[road.y][road.x] == RandomMapManager.constant_wall
            mirror = new Point wall.x - movement[0], wall.y - movement[1]
            continue if RandomMapManager.outTheBoard mirror.x, mirror.y, actualWidth, actualHeight
            continue if map[mirror.y][mirror.x] == RandomMapManager.constant_pass
            map[wall.y][wall.x] = RandomMapManager.constant_pass
            map[mirror.y][mirror.x] = RandomMapManager.constant_pass
            walls = walls.concat RandomMapManager.surroundingWalls mirror.x, mirror.y, actualWidth, actualHeight, map
        walls.splice wallIndex, 1
    map

RandomMapManager.generateArray = (width, height)->
    arr = []
    for i in [1..height]
        arr.push new Array(width).fill RandomMapManager.constant_wall
    arr

RandomMapManager.outTheBoard = (x, y, width, height)->
    # 边框化
    return true if x <= 0 or x >= width - 1
    return true if y <= 0 or y >= height - 1
    false

RandomMapManager.isLegalWall = (x, y, width, height, map) ->
    return false if RandomMapManager.outTheBoard x, y, width, height, map
    map[y][x] == RandomMapManager.constant_wall

RandomMapManager.surroundingWalls = (x, y, width, height, map)->
    arr = []
    arr.push new Point(x - 1, y) if RandomMapManager.isLegalWall x - 1, y, width, height, map
    arr.push new Point(x + 1, y) if RandomMapManager.isLegalWall x + 1, y, width, height, map
    arr.push new Point(x, y - 1) if RandomMapManager.isLegalWall x, y - 1, width, height, map
    arr.push new Point(x, y + 1) if RandomMapManager.isLegalWall x, y + 1, width, height, map
    arr

console.log RandomMapManager.generateRandomStructureByPrim 10, 10