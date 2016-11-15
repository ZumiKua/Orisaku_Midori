###:
    @plugindesc Make player's inventory has limit size.
    @author ZumiKua
###

class Infinity_Inventory
  members:()-> []
  maxItems:()-> 99
#generate prototype for infinityInventory
for method in ["items","weapons","armors","equipItems","allItems","hasItem","hasMaxItems","gainItem","isAnyMemberEquipped","discardMembersEquip","loseItem","itemContainer","numItems"]
  Infinity_Inventory.prototype[method] = @Game_Party.prototype[method]

_infinityInventory_Alias_initAllItems = @Game_Party.prototype.initAllItems
@Game_Party.prototype.initAllItems = ()->
  _infinityInventory_Alias_initAllItems.call(this)
  @infinityInventory = new Infinity_Inventory()
  @infinityInventory._items = {}
  @infinityInventory._weapons = {}
  @infinityInventory._armors = {}

@Game_Party.prototype.maxItems =(item)->
  Number(item.meta.maxNum || 99)
@Game_Party.prototype.transferItems = (src,dest,item,count)->
  if src.numItems(item) < count
    count = src.numItems(item)
  src.loseItem(item,count)
  dest.gainItem(item,count)
@Game_Party.prototype.transferToInfinityInventory = (item,count)->
  @transferItems(@,@infinityInventory,item,count)
@Game_Party.prototype.transferToPlayerInventory = (item,count)->
  if @maxItems(item) < @numItems(item) + count
    count = @maxItems(item) - @numItems(item)
  @transferItems(@infinityInventory,@,item,count)
_infinityInventory_Alias_gainItem = @Game_Party.prototype.gainItem
@Game_Party.prototype.gainItem = (item,count,includeEquip)->
  if this instanceof Game_Party
    if @numItems(item) + count > @maxItems(item)
      boxCount = count - (@maxItems(item) - @numItems(item))
      boxCount = 0 if boxCount < 0
      count -= boxCount
      @infinityInventory.gainItem(item,boxCount,includeEquip) if boxCount > 0
    _infinityInventory_Alias_gainItem.call(this,item,count,includeEquip)
    [count,boxCount]
  else
    _infinityInventory_Alias_gainItem.call(this,item,count,includeEquip)

class Window_TransferItemList extends Window_ItemList
  constructor: (@itembox)->
    @initialize(0,@fittingHeight(2),Graphics.width/2,Graphics.height-@fittingHeight(2))
    @refresh()
    @resetScroll()
  isEnabled: (item)->
    if @itembox instanceof Game_Party
      true
    else
      $gameParty.numItems(item) < $gameParty.maxItems(item)
  maxCols: ()->
    1
  selectLast: ()->
    0
  makeItemList: ()->
    @_data = @itembox.allItems()
    @_data = [null] if @_data.length == 0
  cursorRight: ()->
    @cursorRightHandler() if @cursorRightHandler
  cursorLeft: ()->
    @cursorLeftHandler() if @cursorLeftHandler
  drawItemNumber: (item,x,y,width)->
    if @needsNumber()
        @drawText(':', x, y, width - @textWidth('00'), 'right')
        @drawText(@itembox.numItems(item), x, y, width, 'right')

class Window_TransferNumber extends Window_Selectable
  constructor: ()->
    width = 200
    height = 100
    @initialize((Graphics.width - width) / 2,(Graphics.height - height) / 2,width,height)
    @openness = 0
    @_number = 0
  setup: (@_max)->
    @_number = 1
    @refresh()
  addNumber: (num)->
    @_number += num
    @_number = @_number.clamp(1, @_max)
    @refresh()
  number: ()->
    @_number
  refresh: ()->
    @contents.clear();
    @drawMultiplicationSign();
    @drawNumber();
  update: ()->
    super()
    if(Input.isRepeated("right"))
      @addNumber(1)
    if(Input.isRepeated("left"))
      @addNumber(-1)
    if(Input.isRepeated("up"))
      @addNumber(10)
    if(Input.isRepeated("down"))
      @addNumber(-10)
  drawNumber: ()->
    @drawText(@_number,0,(@contents.height-@lineHeight())/2,@contents.width,"right")
  drawMultiplicationSign: ()->
    @drawText("×",0,(@contents.height-@lineHeight())/2,@contents.width-72,"right")
  updateCursor: ()->
    @setCursorRect(@contents.width-54,(@contents.height-@lineHeight())/2,60,@lineHeight())

class @Scene_Transfer extends @Scene_Base
  constructor: ()->
    @initialize()

  create: ()->
    super()
    @bg = new Sprite()
    @bg.bitmap = SceneManager.backgroundBitmap()
    @addChild(@bg)
    @createWindowLayer()
    @playerInventoryWindow = new Window_TransferItemList($gameParty)
    @playerInventoryWindow.cursorRightHandler = @onRight.bind(this)
    @boxInventoryWindow = new Window_TransferItemList($gameParty.infinityInventory)
    @boxInventoryWindow.x = Graphics.width / 2
    @boxInventoryWindow.cursorLeftHandler = @onLeft.bind(this)
    @playerInventoryWindow.setHandler("ok",@onPlayerOk.bind(this))
    @boxInventoryWindow.setHandler("ok",@onBoxOk.bind(this))
    @playerInventoryWindow.setHandler("cancel",@popScene.bind(this))
    @boxInventoryWindow.setHandler("cancel",@popScene.bind(this))
    @numberWindow = new Window_TransferNumber()
    @numberWindow.setHandler("ok",@onNumberOk.bind(this))
    @helpWindow = new Window_Help()
    @playerInventoryWindow.setHelpWindow(@helpWindow)
    @boxInventoryWindow.setHelpWindow(@helpWindow)
    @addWindow(@helpWindow)
    @addWindow(@playerInventoryWindow)
    @addWindow(@boxInventoryWindow)
    @addWindow(@numberWindow)

    @playerInventoryWindow.activate()
    @playerInventoryWindow.select(0)
    @box_index = 0
    @player_index = 0
  onRight: ()->
    @playerInventoryWindow.deactivate()
    @player_index = @playerInventoryWindow.index()
    @playerInventoryWindow.deselect()
    @boxInventoryWindow.activate()
    @boxInventoryWindow.select(@box_index)
    SoundManager.playCursor()
  onLeft: ()->
    @playerInventoryWindow.activate()
    @playerInventoryWindow.select(@player_index)
    @boxInventoryWindow.deactivate()
    @box_index = @boxInventoryWindow.index()
    @boxInventoryWindow.deselect()
    SoundManager.playCursor()
  onPlayerOk: ()->
    @numberWindow.open()
    @numberWindow.activate()
    @numberWindow.setup($gameParty.numItems(@playerInventoryWindow.item()))
    @type = 1 #player
    SoundManager.playOk()
  onBoxOk: ()->
    @numberWindow.open()
    @numberWindow.activate()
    num = $gameParty.infinityInventory.numItems(@boxInventoryWindow.item())
    num2 = $gameParty.maxItems(@boxInventoryWindow.item()) - $gameParty.numItems(@boxInventoryWindow.item())
    num = num2 if num > num2
    @numberWindow.setup(num)
    @type = 2 #box
    SoundManager.playOk()
  onNumberOk: ()->
    switch @type
      when 1
        item = @playerInventoryWindow.item()
        number = @numberWindow.number()
        $gameParty.transferToInfinityInventory(item,number)
        @playerInventoryWindow.activate()
      when 2
        $gameParty.transferToPlayerInventory(@boxInventoryWindow.item(),@numberWindow.number())
        @boxInventoryWindow.activate()
    @numberWindow.close()
    @playerInventoryWindow.refresh()
    @boxInventoryWindow.refresh()
    SoundManager.playOk()
  onNumberCancel: ()->
    switch @type
      when 1
        @playerInventoryWindow.activate()
      when 2
        @boxInventoryWindow.activate()
