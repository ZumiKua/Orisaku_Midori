// Generated by CoffeeScript 1.8.0

/*:
    @plugindesc Generate Map randomly.
    @author IamI
 */

(function() {
  var Point, RandomMapManager, _RandomMap_Alias_Game_Interpreter_command201, _RandomMap_Alias_Game_Interpreter_pluginCommand, _RandomMap_Alias_Scene_Map_isReady, _RandomMap_Alias_Scene_Map_onMapLoaded;

  Math.randomIntWithMinMax = function(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  };

  Array.prototype.fill = function(num) {
    var i, _i, _ref;
    for (i = _i = 0, _ref = this.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      this[i] = num;
    }
    return this;
  };

  Point = (function() {
    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    return Point;

  })();

  RandomMapManager = function() {
    throw new error("This is a static clss");
  };

  RandomMapManager.Prim = function() {
    throw new error("This is a static class");
  };

  RandomMapManager.constantSurroudings = [[-1, 0], [1, 0], [0, -1], [0, 1]];

  RandomMapManager.constantPass = 0;

  RandomMapManager.constantWall = 1;

  RandomMapManager.constantEntranceFlag = 2;

  RandomMapManager.constantExitFlag = 3;

  RandomMapManager.Prim.generateRandomStructure = function(width, height) {
    var actualHeight, actualWidth, map, mirror, movement, road, starter, starterX, starterY, wall, wallIndex, walls, _i, _len, _ref;
    actualWidth = width * 2 + 1;
    actualHeight = height * 2 + 1;
    map = RandomMapManager.generateArray(actualWidth, actualHeight);
    walls = [];
    starterX = Math.randomIntWithMinMax(1, width - 1);
    starterY = Math.randomIntWithMinMax(1, height - 1);
    starter = new Point(2 * starterX - 1, 2 * starterY - 1);
    map[starter.y][starter.x] = RandomMapManager.constantPass;
    walls = walls.concat(RandomMapManager.surroundingWalls(starter.x, starter.y, actualWidth, actualHeight, map));
    while (walls.length > 0) {
      wallIndex = Math.randomIntWithMinMax(0, walls.length - 1);
      wall = walls[wallIndex];
      _ref = RandomMapManager.constantSurroudings;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        movement = _ref[_i];
        road = new Point(wall.x + movement[0], wall.y + movement[1]);
        if (RandomMapManager.outTheBoard(road.x, road.y, actualWidth, actualHeight)) {
          continue;
        }
        if (map[road.y][road.x] === RandomMapManager.constantWall) {
          continue;
        }
        mirror = new Point(wall.x - movement[0], wall.y - movement[1]);
        if (RandomMapManager.outTheBoard(mirror.x, mirror.y, actualWidth, actualHeight)) {
          continue;
        }
        if (map[mirror.y][mirror.x] !== RandomMapManager.constantWall) {
          continue;
        }
        map[wall.y][wall.x] = RandomMapManager.constantPass;
        map[mirror.y][mirror.x] = RandomMapManager.constantPass;
        walls = walls.concat(RandomMapManager.surroundingWalls(mirror.x, mirror.y, actualWidth, actualHeight, map));
      }
      walls.splice(wallIndex, 1);
    }
    return map;
  };

  RandomMapManager.generateArray = function(width, height, value) {
    var arr, i, _i;
    value = value || RandomMapManager.constantWall;
    arr = [];
    for (i = _i = 1; 1 <= height ? _i <= height : _i >= height; i = 1 <= height ? ++_i : --_i) {
      arr.push(new Array(width).fill(value));
    }
    return arr;
  };

  RandomMapManager.outTheBoard = function(x, y, width, height) {
    if (x <= 0 || x >= width - 1) {
      return true;
    }
    if (y <= 0 || y >= height - 1) {
      return true;
    }
    return false;
  };

  RandomMapManager.isLegalWall = function(x, y, width, height, map) {
    if (RandomMapManager.outTheBoard(x, y, width, height, map)) {
      return false;
    }
    return map[y][x] === RandomMapManager.constantWall;
  };

  RandomMapManager.surroundingWalls = function(x, y, width, height, map) {
    var arr;
    arr = [];
    if (RandomMapManager.isLegalWall(x - 1, y, width, height, map)) {
      arr.push(new Point(x - 1, y));
    }
    if (RandomMapManager.isLegalWall(x + 1, y, width, height, map)) {
      arr.push(new Point(x + 1, y));
    }
    if (RandomMapManager.isLegalWall(x, y - 1, width, height, map)) {
      arr.push(new Point(x, y - 1));
    }
    if (RandomMapManager.isLegalWall(x, y + 1, width, height, map)) {
      arr.push(new Point(x, y + 1));
    }
    return arr;
  };

  RandomMapManager.constantAreaWall = 255;

  RandomMapManager.constantAreaHorizontal = 1;

  RandomMapManager.constantAreaLongitudinal = 2;

  RandomMapManager.constantAreaLeftToUp = 3;

  RandomMapManager.constantAreaLeftToDown = 4;

  RandomMapManager.constantAreaRightToUp = 5;

  RandomMapManager.constantAreaRightToDown = 6;

  RandomMapManager.constantAreaExceptLeft = 7;

  RandomMapManager.constantAreaExceptDown = 8;

  RandomMapManager.constantAreaExceptUp = 9;

  RandomMapManager.constantAreaExceptRight = 10;

  RandomMapManager.constantAreaCross = 11;

  RandomMapManager.constantAreaToLeftDead = 12;

  RandomMapManager.constantAreaToRightDead = 13;

  RandomMapManager.constantAreaToUpDead = 14;

  RandomMapManager.constantAreaToDownDead = 15;

  RandomMapManager.constantAreaExit = 16;

  RandomMapManager.constantAreaEntrance = 17;

  RandomMapManager.convertStructureToAreaId = function(map) {
    var actualHeight, actualWidth, area, areaId, height, i, j, passCount, passes, surrounding, surroundingX, surroundingY, surroundings, width, x, y, _i, _j, _k, _l, _len, _ref, _ref1;
    height = map.length;
    width = map[0].length;
    actualHeight = (height - 1) / 2;
    actualWidth = (width - 1) / 2;
    area = RandomMapManager.generateArray(actualWidth + 2, actualHeight, RandomMapManager.constantAreaWall);
    for (i = _i = 1; 1 <= actualWidth ? _i <= actualWidth : _i >= actualWidth; i = 1 <= actualWidth ? ++_i : --_i) {
      for (j = _j = 1; 1 <= actualHeight ? _j <= actualHeight : _j >= actualHeight; j = 1 <= actualHeight ? ++_j : --_j) {
        x = 2 * i - 1;
        y = 2 * j - 1;
        if (map[y][x] === RandomMapManager.constantWall) {
          throw new Error("A Wall");
        }
        surroundings = [];
        passCount = 0;
        _ref = RandomMapManager.constantSurroudings;
        for (_k = 0, _len = _ref.length; _k < _len; _k++) {
          surrounding = _ref[_k];
          surroundingX = x + surrounding[0];
          surroundingY = y + surrounding[1];
          passes = map[surroundingY][surroundingX];
          if (passes !== RandomMapManager.constantWall) {
            passCount += 1;
          }
          surroundings.push(passes);
        }
        areaId = RandomMapManager.constantAreaWall;
        switch (passCount) {
          case 4:
            areaId = RandomMapManager.constantAreaCross;
            break;
          case 3:
            if (surroundings[0] === RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaExceptLeft;
            } else if (surroundings[1] === RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaExceptRight;
            } else if (surroundings[2] === RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaExceptUp;
            } else if (surroundings[3] === RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaExceptDown;
            }
            break;
          case 2:
            if ((surroundings[0] !== RandomMapManager.constantWall) && (surroundings[1] !== RandomMapManager.constantWall)) {
              areaId = RandomMapManager.constantAreaHorizontal;
            }
            if ((surroundings[0] !== RandomMapManager.constantWall) && (surroundings[2] !== RandomMapManager.constantWall)) {
              areaId = RandomMapManager.constantAreaLeftToUp;
            }
            if ((surroundings[0] !== RandomMapManager.constantWall) && (surroundings[3] !== RandomMapManager.constantWall)) {
              areaId = RandomMapManager.constantAreaLeftToDown;
            }
            if ((surroundings[1] !== RandomMapManager.constantWall) && (surroundings[2] !== RandomMapManager.constantWall)) {
              areaId = RandomMapManager.constantAreaRightToUp;
            }
            if ((surroundings[1] !== RandomMapManager.constantWall) && (surroundings[3] !== RandomMapManager.constantWall)) {
              areaId = RandomMapManager.constantAreaRightToDown;
            }
            if ((surroundings[2] !== RandomMapManager.constantWall) && (surroundings[3] !== RandomMapManager.constantWall)) {
              areaId = RandomMapManager.constantAreaLongitudinal;
            }
            break;
          case 1:
            if (surroundings[0] !== RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaToRightDead;
            } else if (surroundings[1] !== RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaToLeftDead;
            } else if (surroundings[2] !== RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaToDownDead;
            } else if (surroundings[3] !== RandomMapManager.constantWall) {
              areaId = RandomMapManager.constantAreaToUpDead;
            }
        }
        area[j - 1][i - 1 + 1] = areaId;
      }
    }
    for (j = _l = 1, _ref1 = actualHeight - 1; 1 <= _ref1 ? _l <= _ref1 : _l >= _ref1; j = 1 <= _ref1 ? ++_l : --_l) {
      if (map[2 * j - 1][0] === RandomMapManager.constantEntranceFlag) {
        area[j - 1][0] = RandomMapManager.constantAreaEntrance;
      }
      if (map[2 * j - 1][width - 1] === RandomMapManager.constantExitFlag) {
        area[j - 1][actualWidth + 1] = RandomMapManager.constantAreaExit;
      }
    }
    console.log(map, area);
    return area;
  };

  RandomMapManager.cloneEvent = function(event) {
    return {
      id: event.id,
      name: event.name,
      note: event.note,
      pages: event.pages,
      x: event.x,
      y: event.y
    };
  };

  RandomMapManager.MapSource = (function() {
    function MapSource(dataMap) {
      this.width = dataMap.width;
      this.height = dataMap.height;
      if (!dataMap.meta) {
        DataManager.extractMetadata(dataMap);
      }
      this.blockWidth = parseInt(dataMap.meta.blockWidth) || 5;
      this.blockHeight = parseInt(dataMap.meta.blockHeight) || 5;
      this.entrancePosition = parseInt(dataMap.meta.entrancePosition) || (this.blockHeight - 1) / 2;
      this.mapElements = {};
      this.mapEvents = {};
      this.data = dataMap.data;
      this.analyzeMap(this.data);
      this.analyzeEvents(dataMap.events);
    }

    MapSource.prototype.analyzeMap = function(data) {
      var area, border, index, offset;
      offset = this.width * this.height * 5;
      index = offset;
      while (index <= this.width * this.height * 6) {
        if (index % this.width === 0 && border) {
          index = border + 1;
        }
        while (data[index] === 0) {
          index += 1;
        }
        area = data[index];
        border = index + this.blockWidth + (this.blockHeight - 1) * this.width - 1;
        if (data[border] !== area) {
          index += 1;
          continue;
        }
        if (!this.mapElements[area]) {
          this.mapElements[area] = [];
        }
        this.mapElements[area].push(index - offset);
        index += this.blockWidth;
      }
      return 0;
    };

    MapSource.prototype.analyzeEvents = function(events) {
      var area, event, startIndex, _i, _j, _len, _len1, _ref;
      for (_i = 0, _len = events.length; _i < _len; _i++) {
        event = events[_i];
        if (!event) {
          continue;
        }
        area = this.data[this.width * this.height * 5 + event.y * this.width + event.x];
        if (!this.mapElements[area]) {
          next;
        }
        _ref = this.mapElements[area];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          startIndex = _ref[_j];
          if (this.inArea(event.x, event.y, startIndex)) {
            if (!this.mapEvents[startIndex]) {
              this.mapEvents[startIndex] = [];
            }
            this.mapEvents[startIndex].push(event);
            break;
          }
        }
      }
      return 0;
    };

    MapSource.prototype.inArea = function(x, y, areaStartIndex) {
      var areaStartX, areaStartY;
      areaStartY = Math.floor(areaStartIndex / this.width);
      areaStartX = areaStartIndex % this.width;
      return ((areaStartY < y && y < (areaStartY + this.blockHeight))) && ((areaStartX < x && x < (areaStartX + this.blockWidth)));
    };

    MapSource.prototype.getMapData = function(data, x, y, z) {
      return data[this.width * this.height * z + y * this.width + x];
    };

    MapSource.prototype.copyMapData = function(sourceStartIndex, receiver, receiverStartX, receiverStartY, receiverMapWidth, receiverMapHeight, zRange) {
      var i, j, offset, receiverBase, sourceBase, z, _i, _j, _k, _len, _ref, _ref1;
      zRange = zRange || [0, 1, 2, 3, 4];
      offset = receiverStartY * receiverMapWidth + receiverStartX;
      for (_i = 0, _len = zRange.length; _i < _len; _i++) {
        z = zRange[_i];
        sourceBase = sourceStartIndex + z * this.width * this.height;
        receiverBase = z * receiverMapWidth * receiverMapHeight + offset;
        for (j = _j = 0, _ref = this.blockHeight - 1; 0 <= _ref ? _j <= _ref : _j >= _ref; j = 0 <= _ref ? ++_j : --_j) {
          for (i = _k = 0, _ref1 = this.blockWidth - 1; 0 <= _ref1 ? _k <= _ref1 : _k >= _ref1; i = 0 <= _ref1 ? ++_k : --_k) {
            receiver[receiverBase + j * receiverMapWidth + i] = this.data[sourceBase + j * this.width + i];
          }
        }
      }
      return 0;
    };

    MapSource.prototype.copyEventData = function(sourceStartIndex, receiver, receiverStartX, receiverStartY) {
      var event, events, mirrorEvent, sourceStartX, sourceStartY, _i, _len, _results;
      events = this.mapEvents[sourceStartIndex];
      if (!events) {
        return;
      }
      _results = [];
      for (_i = 0, _len = events.length; _i < _len; _i++) {
        event = events[_i];
        sourceStartX = sourceStartIndex % this.width;
        sourceStartY = Math.floor(sourceStartIndex / this.width);
        mirrorEvent = RandomMapManager.cloneEvent(event);
        mirrorEvent.x = event.x - sourceStartX + receiverStartX;
        mirrorEvent.y = event.y - sourceStartY + receiverStartY;
        mirrorEvent.id = receiver.length;
        _results.push(receiver.push(mirrorEvent));
      }
      return _results;
    };

    MapSource.prototype.generateMap = function(sourceData, mapData, eventData, mapWidth, mapHeight) {
      var areaId, choices, entrance, height, i, j, startIndex, width, _i, _j, _ref, _ref1;
      mapData = mapData || $dataMap.data;
      eventData = eventData || $dataMap.events;
      mapWidth = mapWidth || $dataMap.width;
      mapHeight = mapHeight || $dataMap.height;
      height = sourceData.length;
      width = sourceData[0].length;
      for (j = _i = 0, _ref = height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; j = 0 <= _ref ? ++_i : --_i) {
        for (i = _j = 0, _ref1 = width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          areaId = sourceData[j][i];
          choices = this.mapElements[areaId];
          if (!choices) {
            continue;
          }
          startIndex = choices[Math.randomIntWithMinMax(0, choices.length - 1)];
          if (areaId === RandomMapManager.constantAreaEntrance) {
            entrance = j;
          }
          this.copyMapData(startIndex, mapData, i * this.blockWidth, j * this.blockHeight, mapWidth, mapHeight);
          this.copyEventData(startIndex, eventData, i * this.blockWidth, j * this.blockHeight);
        }
      }
      $gameMap._lastRandomMazeMapData = mapData;
      $gameMap._lastRandomMazeEventData = eventData;
      entrance = entrance || 0;
      return entrance * this.blockHeight + this.entrancePosition;
    };

    return MapSource;

  })();

  RandomMapManager.MapSource.loadMap = function(id) {
    var $sourceMap, fileName;
    if (typeof id !== 'string') {
      id = id.padZero(3);
    }
    fileName = "Map" + id + ".json";
    $sourceMap = null;
    return DataManager.loadDataFile('$sourceMap', fileName);
  };

  RandomMapManager.MapSource.loadMapByFs = function(id) {
    var fileName, fs;
    if (typeof id !== 'string') {
      id = id.padZero(3);
    }
    fileName = "../Data/Map" + id + ".json";
    fs = require('fs');
    return fs.readFileSync(fileName).toString();
  };

  RandomMapManager.makeEntranceAndExit = function(map) {
    var entrance, exit;
    entrance = Math.randomIntWithMinMax(0, (map.length - 5) / 2);
    map[entrance * 2 + 1][0] = RandomMapManager.constantEntranceFlag;
    exit = Math.randomIntWithMinMax(0, (map.length - 3) / 2);
    return map[exit * 2 + 1][map[0].length - 1] = RandomMapManager.constantExitFlag;
  };

  this.RandomMapManager = RandomMapManager;

  RandomMapManager.generateAreaArrayByPrim = function(width, height) {
    var area, struct;
    struct = RandomMapManager.Prim.generateRandomStructure(width, height);
    RandomMapManager.makeEntranceAndExit(struct);
    area = RandomMapManager.convertStructureToAreaId(struct);
    return area;
  };

  RandomMapManager.Test = function() {
    throw new error("This is a static class");
  };

  RandomMapManager.Test.test1 = function() {
    var c, data, file, generate, struct;
    file = RandomMapManager.MapSource.loadMapByFs("002");
    data = JSON.parse(file);
    c = new RandomMapManager.MapSource(data);
    struct = RandomMapManager.Prim.generateRandomStructure(10, 10);
    RandomMapManager.makeEntranceAndExit(struct);
    console.log(struct);
    generate = RandomMapManager.convertStructureToAreaId(struct);
    console.log(generate);
    data = new Array(2500);
    return c.generateMap(generate, data, 50, 50);
  };

  _RandomMap_Alias_Game_Interpreter_pluginCommand = Game_Interpreter.prototype.pluginCommand;

  _RandomMap_Alias_Game_Interpreter_command201 = Game_Interpreter.prototype.command201;

  _RandomMap_Alias_Scene_Map_isReady = Scene_Map.prototype.isReady;

  _RandomMap_Alias_Scene_Map_onMapLoaded = Scene_Map.prototype.onMapLoaded;

  Game_Interpreter.prototype.pluginCommand = function(command, args) {
    var mapID, mapInt;
    _RandomMap_Alias_Game_Interpreter_pluginCommand(command, args);
    if (command === 'Maze') {
      mapID = args[0];
      mapInt = parseInt(mapID);
      if (mapInt) {
        mapID = mapInt;
      }
      return RandomMapManager.MapSource.loadMap(mapID);
    }
  };

  Scene_Map.prototype.IsReady = function() {
    if (!this._mapLoaded && DataManager.isMapLoaded()) {
      if (!$dataMap.meta) {
        DataManager.extractMetadata($dataMap);
      }
      if ($dataMap.meta.randomMaze) {
        if (!DataManager.isSourceMapLoaded) {
          console.log('No source maze map when ready check. Did you set the maze?');
          return false;
        }
      }
      this.onMapLoaded();
      this._mapLoaded = true;
    }
    return this._mapLoaded && Scene_Base.prototype.isReady.call(this);
  };

  Scene_Map.prototype.onMapLoaded = function() {
    var area, size;
    if (!$dataMap.meta) {
      DataManager.extractMetadata($dataMap);
    }
    if ($dataMap.meta.randomMaze) {
      if (this._transfer) {
        size = eval($dataMap.meta.randomMaze);
        area = RandomMapManager.generateAreaArrayByPrim(size[0], size[1]);
        if (!$sourceMap.source) {
          $sourceMap.source = new RandomMapManager.MapSource($sourceMap);
        }
        $gamePlayer._newY = $sourceMap.source.generateMap(area);
      } else {
        if ($gameMap._lastRandomMazeMapData) {
          $dataMap.data = $gameMap._lastRandomMazeMapData;
        }
        if ($gameMap._lastRandomMazeEventData) {
          $dataMap.events = $gameMap._lastRandomMazeEventData;
        }
      }
    } else {
      if ($gameMap._lastRandomMazeEventData) {
        $gameMap._lastRandomMazeEventData = null;
      }
      if ($gameMap._lastRandomMazeMapData) {
        $gameMap._lastRandomMazeMapData = null;
      }
    }
    return _RandomMap_Alias_Scene_Map_onMapLoaded.call(this);
  };

  DataManager.isSourceMapLoaded = function() {
    this.checkError();
    return !!$sourceMap;
  };

}).call(this);
