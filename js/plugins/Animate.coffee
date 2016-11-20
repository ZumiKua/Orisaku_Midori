###:
 @plugindesc A helper script trys to make the implementation of animation effects more easily and painless.
 @author ZumiKua
###
makeNewUpdate = (obj)->
  return if obj.update.registeredFunc
  old_update = obj.update
  obj.update = ()->
    r = old_update?.apply(this,arguments)
    for func,i in obj.update.registeredFunc
      result = func?.call(this)
      if !result
        obj.update.registeredFunc[i] = null
    obj.update.registeredFunc.filter((e)->e)
    if(obj.update.registeredFunc.length == 0)
      obj.update = old_update
    r
  obj.update.registeredFunc = []
registerNewFunc = (obj,func)->
  makeNewUpdate(obj)
  obj.update.registeredFunc.push func
AnimateIt = (obj,param,target_value,duration,callback_func)->
  AnimateItDefaultCurve(obj,param,target_value,duration,"linear",callback_func)
AnimateItBezier = (obj,param,target_value,duration,p1x,p1y,p2x,p2y,callback_func)->
  start_value = obj[param]
  dist = target_value - obj[param]
  duration_in_ms = duration * 1000 / 60
  bezier = (x)->
    start_value + dist * Bezier.cubicBezier(p1x,p1y,p2x,p2y,x,duration_in_ms)
  AnimateItBase(obj,param,target_value,duration,bezier,callback_func)
AnimateItDefaultCurve = (obj,param,target_value,duration,curve_type,callback_func)->
  start_value = obj[param]
  dist = target_value - obj[param]
  duration_in_ms = duration * 10000 / 60
  unitBezier = Bezier[curve_type]
  return false unless unitBezier
  bezier  = (x)->
    start_value + dist * unitBezier(x,duration_in_ms)
  AnimateItBase(obj,param,target_value,duration,bezier,callback_func)
AnimateItBase = (obj,param,target_value,duration,value_func,callback_func)->
  count = 0
  registerNewFunc(obj,()->
    if(count == duration)
      obj[param] = target_value
      callback_func?.call(this)
      return false
    else
      obj[param] = value_func(count / duration)
      console.log(obj,param,obj[param],count,duration)
      count += 1
      return true
  )
AnimateItPromiseVersion = (obj,param,target_value,duration)->
  new Promise((resolve,reject)->
    AnimateIt(obj,param,target_value,duration,resolve)
  )
AnimateItDefaultCurvePromiseVersion = (obj,param,target_value,duration,curve_type)->
  new Promise((resolve,reject)->
    AnimateItDefaultCurve(obj,param,target_value,duration,curve_type,resolve)
  )
AnimateItBezierPromiseVersion = (obj,param,target_value,duration,p1x,p1y,p2x,p2y)->
  new Promise((resolve,reject)->
    AnimateItBezier(obj,param,target_value,duration,p1x,p1y,p2x,p2y,resolve)
  )
