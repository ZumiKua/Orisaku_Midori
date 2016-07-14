###
  * @plugindesc	Show the nice body of our character and her beautiful clothes.
  * @author	ZumiKua
  * @param	ORDER
  * @desc	The order of the layer.First one is at the bottom.If the elements match
        the equipment type, the layer specified by the note <pic:#{picname}> will
        be displayed. Otherwise the picture with this name will be displayed.
        "express" means express layer.
        Use "|" to split the layer array.
  * @default	"backhair|nakedbody|Head|Body|fronthair|Accessory"

###
class NiceBody
  constructor: ()->
