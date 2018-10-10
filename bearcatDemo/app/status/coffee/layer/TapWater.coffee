# @Time    : 2018/9/5 下午7:25
#  水纹效果

TapWater = ->
  $id = "TapWater"
  return
TapWater::init = ->
  @ctor = cc.Layer.extend(
    sprite:null
    time : 0
    dt:0
    ctor: (params) ->
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
      _that = @
      cc.loader.loadTxt(res.fragmentWather,(x,fragmentWather)->
        cc.loader.loadTxt(res.vertex, (x,vertex)->
          _that.initShader(vertex,fragmentWather)))
      console.log(5)

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
    onTouchBegan:(selTouch, event) ->
      console.log("onTouchBegan", @__classId)
      pos = selTouch.getLocation()
      target = event._currentTarget.sprite
      if cc.rectContainsPoint(target.getBoundingBox(),pos)
        @changeShaderCenter(pos)



      return true
    changeShaderCenter:(pos)->
      x = Math.abs( pos.x- @sprite.x)/@sprite.width
      y = Math.abs( pos.y- @sprite.y)/@sprite.height
      @shader.setUniformLocationWith2f(@shader.getUniformLocationForName('center'), x, y  );


    onTouchMoved: ->
      return true

    onTouchEnded: ->
      console.log("onTouchEnded", @__classId)
      return true

    onTouchCancelled: ->
      return true

    initShader:(v,f) ->
      @graySprite(@sprite,v,f)
      @schedule(@run1,1/60)
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
        @shader.use();
        @time = 0.0 if this.time >1
        @time += 0.01;
        @shader.setUniformLocationWith1f(this.shader.getUniformLocationForName("time"),this.time)
        # web 开发时候 使用 setUniformLocationWith3f (  10,  0.8,  0.1 ) 这种的 cc.sys.isNative  使用  setUniformVec2 这种的 ({ x: 10, y: 0.8, z: 0.1 })
        @shader.updateUniforms()
        #if this.dt >=5
#            // this.sprite.removeFromParent()
#            // this.sprite = this.createSprit()
#            // this.unschedule(this.run1)
#            // this.shader = null
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
        this.shader.setUniformLocationWith2f(this.shader.getUniformLocationForName('center'), 0.5, 0.5  );
        this.shader.setUniformLocationWith3f(this.shader.getUniformLocationForName('params'),  10, 0.8, 0.1 );

    cleanup:->
      @_super()
      @unscheduleAllCallbacks()
  )
  return
TapWater::get = (cb, cbTarget, params) ->
  @init()
  return new @ctor(params)
