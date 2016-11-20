###:
    @plugindesc Display character pictures when talking.
    @author ZumiKua
###
_MessageEx_Alias_Window_Message_initialize = @Window_Message.prototype.initialize
@Window_Message.prototype.initialize = ()->
  _MessageEx_Alias_Window_Message_initialize.apply(this,arguments)
  @leftCharacter = new Sprite()
  @leftShowing = ""
  @rightCharacter = new Sprite()
  @rightShowing = ""
  @leftCharacter.y = -Graphics.height + @height
  @rightCharacter.y = -Graphics.height + @height
  @addChildAt(@leftCharacter,0)
  @addChildAt(@rightCharacter,0)
_MessageEx_Alias_Window_Message_convertEscapeCharacters = @Window_Message.prototype.convertEscapeCharacters
@Window_Message.prototype.convertEscapeCharacters = (text)->
  text = _MessageEx_Alias_Window_Message_convertEscapeCharacters.apply(this,arguments)
  text = text.replace(/\x1bS/gi,(()->
    if @rightShowing != ""
      AnimateItDefaultCurve(@rightCharacter,"x",Graphics.width,30,"easeIn")
      AnimateItDefaultCurvePromiseVersion(@rightCharacter,"opacity",0,30,"easeIn").then ()->
        SceneManager._scene.nice_body?.slideIn()
    else
      SceneManager._scene.nice_body?.slideIn()
    ""
  ).bind(this))
  text = text.replace(/\x1bH/gi,()->
    if SceneManager._scene.nice_body
      SceneManager._scene.nice_body.slideOut()
    ""
  )
  text = text.replace(/\x1bE\[(\w+)\]/gi,(_,exp)->
    if SceneManager._scene.nice_body
      SceneManager._scene.nice_body.express = exp
    ""
  )
  text = text.replace(/\x1bL\[(\w*)\]/gi,((_,exp)->
    showFunc = ()->
      @leftCharacter.bitmap = ImageManager.loadPicture(exp)
      @leftShowing = exp
      @leftCharacter.bitmap.mustDo((bit)->
        @leftCharacter.x = -bit.width
        @leftCharacter.opacity = 0

        AnimateItDefaultCurve(@leftCharacter,"x",0,30,"easeOut")
        AnimateItDefaultCurve(@leftCharacter,"opacity",255,30,"easeOut")
        console.log(@leftCharacter.update)
      ,this)
    if(@leftShowing != exp && @leftShowing != "")
      AnimateItDefaultCurve(@leftCharacter,"x",-@leftCharacter.bitmap.width,30,"easeIn")
      AnimateItDefaultCurve(@leftCharacter,"opacity",0,30,"easeIn",showFunc.bind(this))
    else
      showFunc.call(this)
    ""
  ).bind(this))
  text = text.replace(/\x1bR\[(\w*)\]/gi,((_,exp)->
    showFunc = ()->
      @rightCharacter.bitmap = ImageManager.loadPicture(exp)
      @rightShowing = exp
      @rightCharacter.bitmap.mustDo((bit)->
        @rightCharacter.x = Graphics.width
        @rightCharacter.opacity = 0
        AnimateItDefaultCurve(@rightCharacter,"x",Graphics.width - @rightCharacter.bitmap.width,30,"easeOut")
        AnimateItDefaultCurve(@rightCharacter,"opacity",255,30,"easeOut")
      ,this)
    if(SceneManager._scene.nice_body?.alreadySlidedIn)
      console.log("xx")
      SceneManager._scene.nice_body.slideOut(showFunc.bind(this))
    else if(@rightShowing != exp && @rightShowing != "")
      AnimateItDefaultCurve(@rightCharacter,"x",Graphics.width,30,"easeIn")
      AnimateItDefaultCurve(@rightCharacter,"opacity",0,30,"easeIn",showFunc.bind(this))
    else
      showFunc.call(this)
    ""
  ).bind(this))
  text
_old_terminateMessage_ = @Window_Message.prototype.terminateMessage
@Window_Message.prototype.terminateMessage = ()->
  #console.log(@doesContinue())

  if(SceneManager._scene instanceof Scene_Map)
    isNextMessage = false
    nxtCode = $gameMap._interpreter.currentCommand()?.code
    if(nxtCode >= 101 && nxtCode <= 104 )
      isNextMessage = true
    unless isNextMessage
      if SceneManager._scene.nice_body?.alreadySlidedIn
        SceneManager._scene.nice_body?.slideOut()
      if @rightShowing != ""
        AnimateItDefaultCurve(@rightCharacter,"x",Graphics.width,30,"easeIn")
        AnimateItDefaultCurve(@rightCharacter,"opacity",0,30,"easeIn")
      if @leftShowing != ""
        AnimateItDefaultCurve(@leftCharacter,"x",-@leftCharacter.bitmap.width,30,"easeIn")
        AnimateItDefaultCurve(@leftCharacter,"opacity",0,30,"easeIn")
  _old_terminateMessage_.apply(this)
