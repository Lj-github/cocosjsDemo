// Generated by CoffeeScript 1.12.7
var LayerWave;

LayerWave = function() {};

LayerWave.prototype.init = function() {
  var self;
  self = this;
  this.ctor = cc.Layer.extend({
    sprite: null,
    time: 0,
    dt: 0,
    shader: null,
    ctor: function(params) {
      var helloLabel, size;
      this._super();
      size = cc.winSize;
      helloLabel = new cc.LabelTTF("Hello World", "Arial", 38);
      helloLabel.x = size.width / 2;
      helloLabel.y = size.height / 2 + 200;
      this.sprite = new cc.Sprite(res.HelloWorld_png);
      this.sprite.attr({
        x: size.width / 2,
        y: size.height / 2
      });
      this.addChild(this.sprite, 0);
      return this.sprite.setScale(2.5);
    },
    onEnter: function() {
      var _this, fsh, vsh;
      this._super();
      vsh = "\n" + "attribute vec4 a_position;\n" + "attribute vec2 a_texCoord;\n" + "attribute vec4 a_color;\n" + "varying vec4 v_fragmentColor;\n" + "varying vec2 v_texCoord;\n" + "void main()\n" + "\n{\n" + "   gl_Position = CC_PMatrix * a_position;\n" + "   v_fragmentColor = a_color;\n" + "   v_texCoord = a_texCoord;\n" + "}";
      fsh = "\n" + "varying vec2 v_texCoord;\n" + "uniform float u_radius;\n" + "void main()\n" + "\n{\n" + "   float radius = u_radius;\n" + "   vec2 coord = v_texCoord;\n" + "   coord.x += (sin(coord.y * 8.0 * 3.1415926 + radius*3.1415926 *1000.0) / 30.0  )   ;\n" + "   vec2 uvs = coord.xy;\n" + "   gl_FragColor = texture2D(CC_Texture0, coord);\n" + "}";
      this.graySprite(this.sprite, vsh, fsh);
      this.schedule(this.run1, 0.1);
      _this = this;
      this._listener_base = cc.EventListener.create({
        event: cc.EventListener.TOUCH_ONE_BY_ONE,
        swallowTouches: false,
        onTouchBegan: function(selTouch, event) {
          return _this.onTouchBegan(selTouch, event);
        },
        onTouchMoved: function(selTouch, event) {
          return _this.onTouchMoved(selTouch, event);
        },
        onTouchEnded: function(selTouch, event) {
          return _this.onTouchEnded(selTouch, event);
        },
        onTouchCancelled: function(selTouch, event) {
          return _this.onTouchCancelled(selTouch, event);
        }
      });
      this._listener_base._setFixedPriority(1);
      return cc.eventManager.addListener(this._listener_base, this);
    },
    onTouchBegan: function() {
      console.log("onTouchBegan", this.__classId);
      return true;
    },
    onTouchMoved: function() {
      return true;
    },
    onTouchEnded: function() {
      console.log("onTouchEnded", this.__classId);
      return true;
    },
    onTouchCancelled: function() {
      return true;
      return console.log(5);
    },
    update: function(dt) {
      this.dt += dt;
      if (this.sprite) {
        this.time += dt;
        this.shader.use();
        this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName('u_radius'), 0.003 * this.dt);
        return this.shader.updateUniforms();
      }
    },
    createSprit: function() {
      var sprite;
      sprite = new cc.Sprite(res.HelloWorld_png);
      sprite.attr({
        x: cc.winSize.width / 2,
        y: cc.winSize.height / 2
      });
      sprite.setScale(2.5);
      return sprite;
    },
    run1: function(delta) {
      this.dt += delta;
      if (this.sprite) {
        this.time += delta;
        this.shader.use();
        this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName('u_radius'), 0.003 * this.dt);
        return this.shader.updateUniforms();
      }
    },
    graySprite: function(sprite, vertexSrc, grayShaderFragment) {
      var shader;
      if (sprite) {
        shader = new cc.GLProgram();
        shader.retain();
        shader.initWithVertexShaderByteArray(vertexSrc, grayShaderFragment);
        shader.addAttribute(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION);
        shader.addAttribute(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR);
        shader.addAttribute(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS);
        shader.link();
        shader.updateUniforms();
        sprite.setShaderProgram(shader);
        return this.shader = shader;
      }
    },
    cleanup: function() {
      this._super();
      this._listener_base = void 0;
      return this.unscheduleAllCallbacks();
    }
  });
};

LayerWave.prototype.get = function(cb, cbTarget, params) {
  this.init();
  return new this.ctor(params);
};
