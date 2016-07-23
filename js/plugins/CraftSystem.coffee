@Game_Party.prototype.checkFormulation = (formulation)->
  flag = true
  for ingredient in formulation[1]
    if @numItems(ingredient[0]) < ingredient[1]
      flag = false
      break
  flag
@Game_Party.prototype.applyFormulation = (formulation)->
  if !@checkFormulation(formulation)
    return false
  else
    @gainItem(formulation[0],1)
    for ingredient in formulation[1]
      @gainItem(ingredient[0],-ingredient[1])
  return true
class Window_CraftHint extends @Window_Base
  constructor: ()->
    @initialize()
  initialize: ()->
    Window_Base.prototype.initialize.call(this, 0, Graphics.height / 2, Graphics.width, Graphics.height / 4);
  refresh: (formulation)->
    @contents.clear()
    return if !formulation
    w = (@contents.width - @textPadding() * 2) / 2
    for ingredient,i in formulation[1]
      x = @textPadding() + w * (i % 2)
      y = @lineHeight() * Math.floor(i / 2)
      @drawItemName(ingredient[0],x,y,w)
      string_have = String($gameParty.numItems(ingredient[0]))
      string_need = String(ingredient[1])
      one_letter_width = @textWidth(")")
      x = x+w-one_letter_width-20
      @drawText(')',x,y,one_letter_width)
      ww = @textWidth(string_need)
      @drawText(string_need,x-ww,y,ww)
      x -= ww
      @drawText("/",x-one_letter_width,y,one_letter_width)
      x -= one_letter_width
      ww = @textWidth(string_have)

      @changePaintOpacity($gameParty.numItems(ingredient[0]) >= ingredient[1])
      @drawText(string_have,x-ww,y,ww)
      @changePaintOpacity(true)
      x -= ww
      @drawText('(',x-one_letter_width,y,one_letter_width)
class Window_Formulation extends @Window_Selectable
  constructor: (@formulations,@hint_window,@help_window)->
    @initialize(0,0,Graphics.width,Graphics.height/2)
    @refresh()
    @select(0)
    @activate()
  select: (index)->
    super(index)
    @hint_window.refresh(@formulations[index])
    if @formulations[index]
      @help_window.setItem(@formulations[index][0])
  maxCols: ()->
    2
  maxItems: ()->
    @formulations.length
  getFormulation: ()->
    if @formulations
      @formulations[@index()]
    else
      null
  refresh: ()->
    super()
    @hint_window.refresh(@getFormulation())
    @help_window.setItem(@getFormulation()[0]) if @getFormulation()
  drawItem: (index)->
    if(index < @formulations.length)
      rect = @itemRectForText(index)
      @changePaintOpacity($gameParty.checkFormulation(@formulations[index]))
      @drawItemName(@formulations[index][0],rect.x,rect.y,rect.width)
class @Scene_Craft extends @Scene_Base
  parse_formulation: (text)->
    formulation = []
    for i in text.split(',')
      arr = i.split('*')
      formulation.push([$dataItems[Number(arr[0])],Number(arr[1])])
    formulation
  gather_formulations: ()->
    formulations = []
    for item in $dataItems
      if item
        if formulation_text = item.meta.craft
          for text in formulation_text.split('|')
            console.log(text)
            formulations.push([item,@parse_formulation(text)])
            console.log(formulations[formulations.length - 1])
    formulations
  constructor: ()->
    @initialize()
  onOk: ()->
    if $gameParty.applyFormulation(@formulation_window.getFormulation())
      SoundManager.playOk()
      @formulation_window.refresh()
    else
      SoundManager.playBuzzer()
    @formulation_window.activate()
  create: ()->
    super()
    @formulations = @gather_formulations()
    @createWindowLayer()
    @createHintWindow()
    @createHelpWindow()
    @createFormulationWindow()
  createFormulationWindow: ()->
    @formulation_window = new Window_Formulation(@formulations,@hint_window,@help_window)
    @formulation_window.setHandler('ok',@onOk.bind(this));
    @formulation_window.setHandler('cancel',@popScene.bind(this));
    @_windowLayer.addChild(@formulation_window)
  createHintWindow: ()->
    @hint_window = new Window_CraftHint()
    @_windowLayer.addChild(@hint_window)
  createHelpWindow: ()->
    @help_window = new Window_Help()
    @help_window.y = Graphics.height * 0.75
    @help_window.height = Graphics.height / 4
    @help_window.createContents()
    @_windowLayer.addChild(@help_window)
