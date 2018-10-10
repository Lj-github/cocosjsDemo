// Generated by CoffeeScript 1.12.7

/**
  Form Base Object
  模态窗口基类 （屏蔽所有后面的 CCLayer 触摸事件）
  create by byron.song on 2015.10.17
 */
var BaseForm;

BaseForm = function() {
  this.$id = 'baseForm';
  this.$init = 'init';
  this.$baseLayer = null;
  this.ctor = null;
  this.$topic = null;
};

BaseForm.prototype.init = function() {
  var notMap, self;
  self = this;
  notMap = {
    "formLoading": true,
    "formLoadingOnce": true,
    "formWait": true,
    "formhint3": true,
    "formhint2": true
  };
  this.ctor = bearcat.getBean('baseLayer').ctor.extend({
    ctor: function(layerDefine) {
      this._super(layerDefine);
      this.opacity = 170;
      if (layerDefine.isBlack) {
        this.opacity = 255;
      }
      this.__colorLayer = this.display.newColorLayer(cc.color(0, 0, 0, this.opacity));
      this.addChild(this.__colorLayer, -1);
    },
    onEnter: function() {
      this._super();
      this._swallowTouches(true);
      return this.inAction();
    },
    isForm: function() {
      if (this.__isForm !== void 0) {
        return this.__isForm;
      }
      return true;
    },
    onExit: function() {
      this._super();
      if (!notMap[this.__classId]) {
        return self.$topic.publish(cz.MSG_FORM_EXIT);
      }
    },

    /**
      * 设置灰度背景是否可显示
      *
      * @param {Boolean} isVisible
     */
    setColorLayerVisible: function(isVisible) {
      return this.__colorLayer.setVisible(isVisible);
    },
    inAction: function() {
      if (cz.ignoreMap[this.__classId] || !this.isForm()) {
        return;
      }
      this.__colorLayer.setScale(1.43);
      this.setScale(0.7);
      this.runAction(cc.sequence(cc.scaleTo(0.1, 1.1), cc.scaleTo(0.1, 1), cc.callFunc(this.afterInAction, this)));
      this.__colorLayer.setOpacity(80);
      return this.__colorLayer.runAction(cc.fadeTo(0.25, this.opacity));
    },
    afterInAction: function() {},
    removeFromParent: function() {
      if (this._hasShow) {
        this._super();
        return;
      }
      return this.outAction();
    },
    outAction: function() {
      this._hasShow = true;
      if (cz.ignoreMap[this.__classId] || !this.isForm()) {
        this.removeFromParent();
        return;
      }
      this.runAction(cc.sequence(cc.scaleTo(0.1, 0.7), cc.callFunc(function() {
        return this.removeFromParent();
      }, this)));
      return this.__colorLayer.runAction(cc.fadeTo(0.1, 80));
    }
  });
};

BaseForm.prototype.get = function() {
  return new this.ctor();
};

BaseForm.prototype.makeEmptyForm = function() {
  var form, ignorForm;
  ignorForm = cc.director.getRunningScene().getChildByTag(cz.COMMON_FORM_TOP_UP);
  if (ignorForm) {
    return;
  }
  form = new this.ctor(this);
  cc.director.getRunningScene().addChild(form, cz.ZORDER_FORM_TOP_UP || 0, cz.COMMON_FORM_TOP_UP);
  return form;
};