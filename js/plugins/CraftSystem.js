(function() {
  var Window_CraftHint, Window_Formulation,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Game_Party.prototype.checkFormulation = function(formulation) {
    var flag, ingredient, _i, _len, _ref;
    flag = true;
    _ref = formulation[1];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ingredient = _ref[_i];
      if (this.numItems(ingredient[0]) < ingredient[1]) {
        flag = false;
        break;
      }
    }
    return flag;
  };

  this.Game_Party.prototype.applyFormulation = function(formulation) {
    var ingredient, _i, _len, _ref;
    if (!this.checkFormulation(formulation)) {
      return false;
    } else {
      this.gainItem(formulation[0], 1);
      _ref = formulation[1];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ingredient = _ref[_i];
        this.gainItem(ingredient[0], -ingredient[1]);
      }
    }
    return true;
  };

  Window_CraftHint = (function(_super) {
    __extends(Window_CraftHint, _super);

    function Window_CraftHint() {
      this.initialize();
    }

    Window_CraftHint.prototype.initialize = function() {
      return Window_Base.prototype.initialize.call(this, 0, Graphics.height / 2, Graphics.width, Graphics.height / 4);
    };

    Window_CraftHint.prototype.refresh = function(formulation) {
      var i, ingredient, one_letter_width, string_have, string_need, w, ww, x, y, _i, _len, _ref, _results;
      this.contents.clear();
      if (!formulation) {
        return;
      }
      w = (this.contents.width - this.textPadding() * 2) / 2;
      _ref = formulation[1];
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        ingredient = _ref[i];
        x = this.textPadding() + w * (i % 2);
        y = this.lineHeight() * Math.floor(i / 2);
        this.drawItemName(ingredient[0], x, y, w);
        string_have = String($gameParty.numItems(ingredient[0]));
        string_need = String(ingredient[1]);
        one_letter_width = this.textWidth(")");
        x = x + w - one_letter_width - 20;
        this.drawText(')', x, y, one_letter_width);
        ww = this.textWidth(string_need);
        this.drawText(string_need, x - ww, y, ww);
        x -= ww;
        this.drawText("/", x - one_letter_width, y, one_letter_width);
        x -= one_letter_width;
        ww = this.textWidth(string_have);
        this.changePaintOpacity($gameParty.numItems(ingredient[0]) >= ingredient[1]);
        this.drawText(string_have, x - ww, y, ww);
        this.changePaintOpacity(true);
        x -= ww;
        _results.push(this.drawText('(', x - one_letter_width, y, one_letter_width));
      }
      return _results;
    };

    return Window_CraftHint;

  })(this.Window_Base);

  Window_Formulation = (function(_super) {
    __extends(Window_Formulation, _super);

    function Window_Formulation(formulations, hint_window, help_window) {
      this.formulations = formulations;
      this.hint_window = hint_window;
      this.help_window = help_window;
      this.initialize(0, 0, Graphics.width, Graphics.height / 2);
      this.refresh();
      this.select(0);
      this.activate();
    }

    Window_Formulation.prototype.select = function(index) {
      Window_Formulation.__super__.select.call(this, index);
      this.hint_window.refresh(this.formulations[index]);
      if (this.formulations[index]) {
        return this.help_window.setItem(this.formulations[index][0]);
      }
    };

    Window_Formulation.prototype.maxCols = function() {
      return 2;
    };

    Window_Formulation.prototype.maxItems = function() {
      return this.formulations.length;
    };

    Window_Formulation.prototype.getFormulation = function() {
      if (this.formulations) {
        return this.formulations[this.index()];
      } else {
        return null;
      }
    };

    Window_Formulation.prototype.refresh = function() {
      Window_Formulation.__super__.refresh.call(this);
      this.hint_window.refresh(this.getFormulation());
      if (this.getFormulation()) {
        return this.help_window.setItem(this.getFormulation()[0]);
      }
    };

    Window_Formulation.prototype.drawItem = function(index) {
      var rect;
      if (index < this.formulations.length) {
        rect = this.itemRectForText(index);
        this.changePaintOpacity($gameParty.checkFormulation(this.formulations[index]));
        return this.drawItemName(this.formulations[index][0], rect.x, rect.y, rect.width);
      }
    };

    return Window_Formulation;

  })(this.Window_Selectable);

  this.Scene_Craft = (function(_super) {
    __extends(Scene_Craft, _super);

    Scene_Craft.prototype.parse_formulation = function(text) {
      var arr, formulation, i, _i, _len, _ref;
      formulation = [];
      _ref = text.split(',');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        arr = i.split('*');
        formulation.push([$dataItems[Number(arr[0])], Number(arr[1])]);
      }
      return formulation;
    };

    Scene_Craft.prototype.gather_formulations = function() {
      var formulation_text, formulations, item, text, _i, _j, _len, _len1, _ref;
      formulations = [];
      for (_i = 0, _len = $dataItems.length; _i < _len; _i++) {
        item = $dataItems[_i];
        if (item) {
          if (formulation_text = item.meta.craft) {
            _ref = formulation_text.split('|');
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              text = _ref[_j];
              console.log(text);
              formulations.push([item, this.parse_formulation(text)]);
              console.log(formulations[formulations.length - 1]);
            }
          }
        }
      }
      return formulations;
    };

    function Scene_Craft() {
      this.initialize();
    }

    Scene_Craft.prototype.onOk = function() {
      if ($gameParty.applyFormulation(this.formulation_window.getFormulation())) {
        SoundManager.playOk();
        this.formulation_window.refresh();
      } else {
        SoundManager.playBuzzer();
      }
      return this.formulation_window.activate();
    };

    Scene_Craft.prototype.create = function() {
      Scene_Craft.__super__.create.call(this);
      this.formulations = this.gather_formulations();
      this.createWindowLayer();
      this.createHintWindow();
      this.createHelpWindow();
      return this.createFormulationWindow();
    };

    Scene_Craft.prototype.createFormulationWindow = function() {
      this.formulation_window = new Window_Formulation(this.formulations, this.hint_window, this.help_window);
      this.formulation_window.setHandler('ok', this.onOk.bind(this));
      this.formulation_window.setHandler('cancel', this.popScene.bind(this));
      return this._windowLayer.addChild(this.formulation_window);
    };

    Scene_Craft.prototype.createHintWindow = function() {
      this.hint_window = new Window_CraftHint();
      return this._windowLayer.addChild(this.hint_window);
    };

    Scene_Craft.prototype.createHelpWindow = function() {
      this.help_window = new Window_Help();
      this.help_window.y = Graphics.height * 0.75;
      this.help_window.height = Graphics.height / 4;
      this.help_window.createContents();
      return this._windowLayer.addChild(this.help_window);
    };

    return Scene_Craft;

  })(this.Scene_Base);

}).call(this);
