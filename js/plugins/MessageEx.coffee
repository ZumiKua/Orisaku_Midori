###:
    @plugindesc Display character pictures when talking.
    @author ZumiKua
###
_MessageEx_Alias_Window_Message_convertEscapeCharacters = @Window_Message.prototype.convertEscapeCharacters
@Window_Message.prototype.convertEscapeCharacters = (text)->
  text = _MessageEx_Alias_Window_Message_convertEscapeCharacters.apply(this,arguments)
  text = text.replace(/\x1bS/gi,()->
    if SceneManager._scene.nice_body
      SceneManager._scene.nice_body.slideIn()
    ""
  )
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
  text
_old_terminateMessage_ = @Window_Message.prototype.terminateMessage
@Window_Message.prototype.terminateMessage = ()->
  #console.log(@doesContinue())

  if(SceneManager._scene instanceof Scene_Map)
    isNextMessage = false
    nxtCode = $gameMap._interpreter.currentCommand()?.code
    console.log(nxtCode)
    if(nxtCode >= 101 && nxtCode <= 104 )
      isNextMessage = true
    unless isNextMessage
      SceneManager._scene.nice_body?.slideOut()
  _old_terminateMessage_.apply(this)
