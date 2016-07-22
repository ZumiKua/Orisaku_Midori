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
  @param WIDTH
  @desc the width of pictures.
  @default 431
  @param HEIGHT
  @desc the height of pictures.
  @default 624
  @param HITTED_EXPRESS
  @desc EXPRESS WILL BE PLAYED WHEN HITTED BY ENEMIES
  @default hitted
  @param ATTACK_EXPRESS
  @desc Express will be played when actor attacks.
  @default 624
###
_NiceBody_Alias_BattleManager_startAction = @BattleManager.startAction
@BattleManager.startAction = ()->
  _NiceBody_Alias_BattleManager_startAction.call(this)
  if SceneManager._scene._spriteset.nice_body
    SceneManager._scene._spriteset.nice_body.playBattleExpress(this._subject,this._targets)
_NiceBody_Alias_Spriteset_Battle_createLowerLayer = @Spriteset_Battle.prototype.createLowerLayer
@Spriteset_Battle.prototype.createLowerLayer = ()->
  _NiceBody_Alias_Spriteset_Battle_createLowerLayer.call(this)
  @nice_body = new NiceBody
  @_baseSprite.addChild(@nice_body)
  @nice_body.slideIn()


_NiceBody_Alias_Spriteset_Battle_update = @Spriteset_Battle.prototype.update

@Spriteset_Battle.prototype.update = ()->
  @nice_body.update4Battle()
  _NiceBody_Alias_Spriteset_Battle_update.call(this)

_Nicebody_Alias_Game_Interpreter_pluginCommand = Game_Interpreter.prototype.pluginCommand
@Game_Interpreter.prototype.pluginCommand = (command, args)->
  _Nicebody_Alias_Game_Interpreter_pluginCommand.call(this, command, args)
  if (command == 'NiceBody')
    switch(args[0])
      when "playExpress"
        if SceneManager._scene.nice_body
          SceneManager._scene.nice_body.express = args[1]
      when "show"
        if SceneManager._scene.nice_body
          SceneManager._scene.nice_body.slideIn()
      when "hide"
        if SceneManager._scene.nice_body
          SceneManager._scene.nice_body.slideOut()


_Nicebody_Alias_Scene_Map_createDisplayObjects = @Scene_Map.prototype.createDisplayObjects
@Scene_Map.prototype.createDisplayObjects = ()->
  _Nicebody_Alias_Scene_Map_createDisplayObjects.apply(this,arguments)
  @nice_body = new NiceBody()
  @addChildAt(@nice_body,1)
###
_Nicebody_Alias_Scene_Map_update = @Scene_Map.prototype.update
@Scene_Map.prototype.update = ()->
  _Nicebody_Alias_Scene_Map_update.apply(this,arguments)
  @nice_body.update()
###
parameters = PluginManager.parameters('NiceBody');
class @NiceBody extends @Sprite_Base
  constructor: ()->
    @initialize.call(this)
    @express_prefix = String(parameters['EXPRESS_PREFIX'] || "exp_")
    @hitted_express = String(parameters['HITTED_EXPRESS'] || "hitted")
    @attack_express = String(parameters['ATTACK_EXPRESS'] || "laugh")
    @orders = String(parameters['ORDER'] || "backhair|nakedbody|Head|Body|fronthair|Accessory").split("|")
    actor_id = Number(parameters['ACTOR_ID'] || "1")
    @_actor = $gameActors.actor(actor_id)
    @express = "normal"
    @anchor = new Point(0.5,1)
    @opacity = 0
    @express_sprite_ids = []
    @pic_width = Number(parameters['WIDTH'] || 431)
    @pic_height = Number(parameters['HEIGHT'] || 624)
    @x = Graphics.width - 160 + 80
    @y = @pic_height
    #@sprites = (new Sprite() for elem in @orders)
    #for sprite in @sprites
    #  sprite.blendMode = PIXI.blendModes.NORMAL
    #  @addChild(sprite)
    @refresh()
  playExpressHitted: ()->
    @express = @hitted_express
  playExpressAttack: ()->
    @express = @attack_express
  playBattleExpress: (sub,targets)->
    console.log(targets)
    if sub == @_actor
      if targets && targets.indexOf(@_actor) < 0
        @playExpressAttack()
        @back_to_normal_express = 60
    else if targets && targets.indexOf(@_actor) >= 0
      @playExpressHitted()
      @back_to_normal_express = 60
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
    ImageManager.loadPicture(fn)

  refresh: ()->
    @bitmap = new Bitmap(@pic_width,@pic_height)
    srcs = []
    already_blted = false
    for elem,i in @orders
      srcs[i] = @generateBitmap(elem)
    for elem,i in @orders
      srcs[i].addLoadListener(((self)->
          return if already_blted
          flag = true
          for src in srcs
            if(!src.isReady())
              flag = false
          if flag
            already_blted = true
            console.log(self)
            for src in srcs
              @bitmap.blt(src,0,0,@pic_width,@pic_height,0,0)
          0
        ).bind(this,srcs[i]))
    fflag = true
    for src in srcs
      if(!src.isReady())
        fflag = false
    if fflag
      already_blted = true
      for src in srcs
        @bitmap.blt(src,0,0,@pic_width,@pic_height,0,0)
    @old_express = @express
  update4Battle: ()->
    while (@_actor.isAnimationRequested())
      console.log(@_actor._animations)
      data = @_actor.shiftAnimation(true);
      animation = $dataAnimations[data.animationId];
      mirror = data.mirror;
      delay = 0
      delay = data.delay if animation.position != 3
      @startAnimation(animation, mirror, delay)
  update: ()->
    super
    if @express != @old_express
      @refresh()
      @old_express = @express
    if @showing
      @x -= 5
      @opacity += 13
      if @x <= Graphics.width - 160
        @x = Graphics.width - 160
        @showing = false
        @opacity = 255
    if @hiding
      @x += 5
      @opacity -= 13
      if @x >= Graphics.width - 160 + 80
        @x = Graphics.width - 160 + 80
        @hiding = false
        @opacity = 0
    if @back_to_normal_express
      @back_to_normal_express -= 1
      if @back_to_normal_express == 0
        @express = "normal"
        @back_to_normal_express = false



  slideIn: ()->
    @hiding = false
    @showing = true
    @opacity = 0
    @x = Graphics.width - 160 + 80
  slideOut: ()->
    @showing = false
    @hiding = true
    @opacity = 255
    @x = Graphics.width - 160
