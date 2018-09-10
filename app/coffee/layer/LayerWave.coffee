# @Time    : 2018/9/5 下午7:14
# 曲线效果

## 在ctor  onenter cleaup 等 都要写 @_super() 不管是 layer  scene node  都一样

LayerWave = ->
  return
LayerWave::init = ->
  self = this
  @ctor = cc.Layer.extend(
    sprite:null
    time : 0
    dt:0
    shader:null
    ctor:(params)->
      @_super()
      size = cc.winSize 
      helloLabel = new cc.LabelTTF("Hello World", "Arial", 38) 
      helloLabel.x = size.width / 2 
      helloLabel.y = size.height / 2 + 200 
      @sprite = new cc.Sprite(res.HelloWorld_png) 
      @sprite.attr({
        x: size.width / 2,
        y: size.height / 2
      })
      this.addChild(@sprite, 0)
      this.sprite.setScale(2.5)

    onEnter : ->
      @_super()
      vsh = "\n" +
          "attribute vec4 a_position;\n" +
          "attribute vec2 a_texCoord;\n" +
          "attribute vec4 a_color;\n" +
          "varying vec4 v_fragmentColor;\n" +
          "varying vec2 v_texCoord;\n" +
          "void main()\n" +
          "\n{\n" +
          "   gl_Position = CC_PMatrix * a_position;\n" +
          "   v_fragmentColor = a_color;\n" +
          "   v_texCoord = a_texCoord;\n" +
          "}"



      fsh = "\n" +
          "varying vec2 v_texCoord;\n" +
           "uniform float u_radius;\n"+

          "void main()\n" +
          "\n{\n" +
          "   float radius = u_radius;\n"+
          "   vec2 coord = v_texCoord;\n" +
          "   coord.x += (sin(coord.y * 8.0 * 3.1415926 + radius*3.1415926 *1000.0) / 30.0  )   ;\n" +
          "   vec2 uvs = coord.xy;\n" +
          "   gl_FragColor = texture2D(CC_Texture0, coord);\n" +
          "}"
      @graySprite(this.sprite,vsh,fsh)
      @schedule(@run1,0.1)
      _this = @
      @_listener_base = cc.EventListener.create(
          event: cc.EventListener.TOUCH_ONE_BY_ONE
          swallowTouches: false
          onTouchBegan: (selTouch, event)->
            return _this.onTouchBegan(selTouch, event)
          onTouchMoved: (selTouch, event)->
            return _this.onTouchMoved(selTouch, event)
          onTouchEnded: (selTouch, event)->
            return _this.onTouchEnded(selTouch, event)
          onTouchCancelled: (selTouch, event)->
            return _this.onTouchCancelled(selTouch, event)
      )
      @_listener_base._setFixedPriority(1)
      cc.eventManager.addListener(@_listener_base, @)


    onTouchBegan: ->
      console.log("onTouchBegan", @__classId)
      return true

    onTouchMoved: ->
      return true

    onTouchEnded: ->
      console.log("onTouchEnded", @__classId)
      return true

    onTouchCancelled: ->
      return true

      console.log(5)
    update:(dt)->
      @dt += dt
      if this.sprite
        this.time += dt
        this.shader.use()
        this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName('u_radius'), 0.003 * this.dt )
        this.shader.updateUniforms()



    createSprit:()->
      sprite = new cc.Sprite(res.HelloWorld_png) 
      sprite.attr({
        x: cc.winSize.width / 2,
        y: cc.winSize.height / 2
      }) 
      sprite.setScale(2.5)
      return sprite


    run1:(delta)->
      @dt += delta
      if this.sprite
        this.time += delta 
        this.shader.use() 
        this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName('u_radius'), 0.003 * this.dt )
        this.shader.updateUniforms() 
#        if this.dt >=5
#          this.sprite.removeFromParent()
#          this.sprite = this.createSprit()
#          @addChild(this.sprite)
#          this.unschedule(this.run1)
#          this.shader = null
    graySprite :(sprite,vertexSrc,grayShaderFragment)->
      if sprite
        shader = new cc.GLProgram()#cc.GLProgram.create("gray.vsh", "gray.fsh") 
        shader.retain()
        shader.initWithVertexShaderByteArray(vertexSrc, grayShaderFragment)
        shader.addAttribute(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        shader.addAttribute(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        shader.addAttribute(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
        shader.link()
        shader.updateUniforms()
        sprite.setShaderProgram(shader)
        this.shader = shader
    cleanup:->
      @_super()
      @_listener_base = undefined
      @unscheduleAllCallbacks()
  )

  return
LayerWave::get = (cb, cbTarget, params) ->
  @init()
  return new @ctor(params)
