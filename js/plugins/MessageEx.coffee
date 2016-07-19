###
_MessageEx_Alias_Window_Message_subWindows = @Window_Message.prototype.subWindows
@Window_Message.prototype.subWindows = ()->
  old = _MessageEx_Alias_Window_Message_subWindows.apply(this,arguments)
  old.unshift @nice_body
  old

_MessageEx_Alias_Window_Message_createSubWindows =  @Window_Message.prototype.createSubWindows
@Window_Message.prototype.createSubWindows = ()->
  _MessageEx_Alias_Window_Message_createSubWindows.apply(this,arguments)
  @nice_body = new NiceBody();

Scene_Map.prototype.createMessageWindow = ()->
    this._messageWindow = new Window_Message()
    this.addChild(this._messageWindow.nice_body)
    this.addWindow(this._messageWindow)
    this._messageWindow.subWindows().forEach(((window)->
        this.addWindow(window)
    ), this);
###
_MessageEx_Alias_Window_Message_convertEscapeCharacters = @Window_Message.prototype.convertEscapeCharacters
@Window_Message.prototype.convertEscapeCharacters = (text)->
  text = _MessageEx_Alias_Window_Message_convertEscapeCharacters.apply(this,arguments)
  text = text.replace(/\x1bS/gi,()->
    if SceneManager._scene.nice_body
      SceneManager._scene.nice_body.show()
    ""
  )
  text = text.replace(/\x1bH/gi,()->
    if SceneManager._scene.nice_body
      SceneManager._scene.nice_body.hide()
    ""
  )
  text = text.replace(/\x1bE\[(\w+)\]/gi,(_,exp)->
    if SceneManager._scene.nice_body
      SceneManager._scene.nice_body.express = exp
    ""
  )
  console.log(text)
  text
