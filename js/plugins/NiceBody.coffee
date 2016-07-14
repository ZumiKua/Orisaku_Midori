###:
  @plugindesc	Show the nice body of our character and her beautiful clothes.
  @author	ZumiKua
  @param	ORDER
  @desc	The order of the layer.First one is at the bottom.If the elements match
        the equipment type, the layer specified by the note <pic:#{picname}> will
        be displayed. Otherwise the picture with this name will be displayed.
        "express" means express layer.
        Use "|" to split the layer array.
  @default	backhair|nakedbody|Head|Body|fronthair|Accessory
  @param	ACTOR_ID
  @desc	The ID of actor who is displayed.
  @default	1
  @param EXPRESS_PREFIX
  @desc the prefix of express picture.
  @default exp_
###
_Nicebody_Alias_Game_Interpreter_pluginCommand = Game_Interpreter.prototype.pluginCommand
@Game_Interpreter.prototype.pluginCommand = (command, args)->
  _Nicebody_Alias_Game_Interpreter_pluginCommand.call(this, command, args)
  if (command == 'NiceBody')
    switch(args[0])
      when "playExpress"
        console.log(SceneManager._scene.nice_body)
        if SceneManager._scene.nice_body
          SceneManager._scene.nice_body.express = args[1]

parameters = PluginManager.parameters('NiceBody');
_Nicebody_Alias_Scene_Map_createDisplayObjects = @Scene_Map.prototype.createDisplayObjects
@Scene_Map.prototype.createDisplayObjects = ()->
  _Nicebody_Alias_Scene_Map_createDisplayObjects.apply(this,arguments)
  @nice_body = new NiceBody()
  @addChildAt(@nice_body,1)
_Nicebody_Alias_Scene_Map_update = @Scene_Map.prototype.update
@Scene_Map.prototype.update = ()->
  _Nicebody_Alias_Scene_Map_update.apply(this,arguments)
  @nice_body.update()
class @NiceBody extends @Sprite
  constructor: ()->
    @initialize.call(this)
    @express_prefix = String(parameters['EXPRESS_PREFIX'] || "exp_")
    @orders = String(parameters['ORDER'] || "backhair|nakedbody|Head|Body|fronthair|Accessory").split("|")
    actor_id = Number(parameters['ACTOR_ID'] || "1")
    @_actor = $gameActors.actor(actor_id)
    @express = "normal"
    @x = Graphics.width - 320
    @express_sprite_ids = []
    @sprites = (new Sprite() for elem in @orders)
    for sprite in @sprites
      sprite.blendMode = PIXI.blendModes.NORMAL
      @addChild(sprite)
    @refresh()
  generateBitmap: (full_elem)->
    splited_elem = full_elem.split(",")
    elem = splited_elem[0]
    part = splited_elem[1]
    #fall on default
    fn = elem
    #express?
    if elem == "express"
      fn = @express_prefix + @express
    #slot?
    for etype,i in $dataSystem.equipTypes
      if etype == elem
        fn = @_actor.equips()[i-1].meta.pic
        break
    #variables?
    if(match_result = (/v\[(\d+)\]/.exec(elem)))
      v = Number(match_result[1])
      if $gameVariables[v]
        fn = "v_"+v+"_" + $gameVariables[v]
      else
        fn = "v_"+v+"_0"
    #resolve part
    if part
      fn += "_" + part
    console.log(fn)
    ImageManager.loadPicture(fn)

  refresh: ()->
    for elem,i in @orders
      if(elem.split(",")[0] == "express")
        @express_sprite_ids.push i
      @sprites[i].bitmap = @generateBitmap(elem)
    @old_express = @express
  update: ()->
    if @express != @old_express
      for id in @express_sprite_ids
        @sprites[id].bitmap = @generateBitmap(@orders[id])
      @old_express = @express
