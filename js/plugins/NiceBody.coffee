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
###
parameters = PluginManager.parameters('NiceBody');
_Nicebody_Alias_Scene_Map_createDisplayObjects = @Scene_Map.prototype.createDisplayObjects
@Scene_Map.prototype.createDisplayObjects = ()->
  _Nicebody_Alias_Scene_Map_createDisplayObjects.apply(this,arguments)
  @nice_body = new NiceBody()
  @addChild(@nice_body)
_Nicebody_Alias_Scene_Map_update = @Scene_Map.prototype.update
@Scene_Map.prototype.update = ()->
  _Nicebody_Alias_Scene_Map_update.apply(this,arguments)
  @nice_body.update()
class @NiceBody extends @Sprite
  constructor: ()->
    @constructor.prototype.initialize.call(this)
    @orders = String(parameters['ORDER'] || "backhair|nakedbody|Head|Body|fronthair|Accessory").split("|")
    actor_id = Number(parameters['ACTOR_ID'] || "1")
    @_actor = $gameActors.actor(actor_id)
    @x = Graphics.width - 320
    @sprites = (new Sprite() for elem in @orders)
    for sprite in @sprites
      sprite.blendMode = PIXI.blendModes.NORMAL;
      @addChild(sprite)
    @refresh()
  generateBitmap: (elem)->
    #fall on default
    fn = elem
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
    console.log(fn)
    ImageManager.loadPicture(fn)
  refresh: ()->
    for elem,i in @orders
      @sprites[i].bitmap = @generateBitmap(elem)
