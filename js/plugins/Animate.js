
/*:
 @plugindesc A helper script trys to make the implementation of animation effects more easily and painless.
 @author ZumiKua
 */
var AnimateIt, AnimateItBase, AnimateItBezier, AnimateItBezierPromiseVersion, AnimateItDefaultCurve, AnimateItDefaultCurvePromiseVersion, AnimateItPromiseVersion, makeNewUpdate, registerNewFunc;

makeNewUpdate = function(obj) {
  var old_update;
  if (obj.update.registeredFunc) {
    return;
  }
  old_update = obj.update;
  obj.update = function() {
    var func, i, j, len, r, ref, result;
    r = old_update != null ? old_update.apply(this, arguments) : void 0;
    ref = obj.update.registeredFunc;
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      func = ref[i];
      result = func != null ? func.call(this) : void 0;
      if (!result) {
        obj.update.registeredFunc[i] = null;
      }
    }
    obj.update.registeredFunc.filter(function(e) {
      return e;
    });
    if (obj.update.registeredFunc.length === 0) {
      obj.update = old_update;
    }
    return r;
  };
  return obj.update.registeredFunc = [];
};

registerNewFunc = function(obj, func) {
  makeNewUpdate(obj);
  return obj.update.registeredFunc.push(func);
};

AnimateIt = function(obj, param, target_value, duration, callback_func) {
  return AnimateItDefaultCurve(obj, param, target_value, duration, "linear", callback_func);
};

AnimateItBezier = function(obj, param, target_value, duration, p1x, p1y, p2x, p2y, callback_func) {
  var bezier, dist, duration_in_ms, start_value;
  start_value = obj[param];
  dist = target_value - obj[param];
  duration_in_ms = duration * 1000 / 60;
  bezier = function(x) {
    return start_value + dist * Bezier.cubicBezier(p1x, p1y, p2x, p2y, x, duration_in_ms);
  };
  return AnimateItBase(obj, param, target_value, duration, bezier, callback_func);
};

AnimateItDefaultCurve = function(obj, param, target_value, duration, curve_type, callback_func) {
  var bezier, dist, duration_in_ms, start_value, unitBezier;
  start_value = obj[param];
  dist = target_value - obj[param];
  duration_in_ms = duration * 10000 / 60;
  unitBezier = Bezier[curve_type];
  if (!unitBezier) {
    return false;
  }
  bezier = function(x) {
    return start_value + dist * unitBezier(x, duration_in_ms);
  };
  return AnimateItBase(obj, param, target_value, duration, bezier, callback_func);
};

AnimateItBase = function(obj, param, target_value, duration, value_func, callback_func) {
  var count;
  count = 0;
  return registerNewFunc(obj, function() {
    if (count === duration) {
      obj[param] = target_value;
      if (callback_func != null) {
        callback_func.call(this);
      }
      return false;
    } else {
      obj[param] = value_func(count / duration);
      console.log(obj, param, obj[param], count, duration);
      count += 1;
      return true;
    }
  });
};

AnimateItPromiseVersion = function(obj, param, target_value, duration) {
  return new Promise(function(resolve, reject) {
    return AnimateIt(obj, param, target_value, duration, resolve);
  });
};

AnimateItDefaultCurvePromiseVersion = function(obj, param, target_value, duration, curve_type) {
  return new Promise(function(resolve, reject) {
    return AnimateItDefaultCurve(obj, param, target_value, duration, curve_type, resolve);
  });
};

AnimateItBezierPromiseVersion = function(obj, param, target_value, duration, p1x, p1y, p2x, p2y) {
  return new Promise(function(resolve, reject) {
    return AnimateItBezier(obj, param, target_value, duration, p1x, p1y, p2x, p2y, resolve);
  });
};
