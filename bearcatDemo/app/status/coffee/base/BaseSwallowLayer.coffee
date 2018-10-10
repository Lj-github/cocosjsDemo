###*
  Layer Base Object
  Layer基类
  create by byron.song on 2015.10.16
###

BaseSwallowLayer = ->
  @$id = 'baseSwallowLayer'
  @$init = 'init'
  @$ez = null
  @$resourceUtil = null
  @$logger = null
  @$ccbLoader = null
  @$socketClient = null
  @$display = null
  @$topic = null
  @$userData = null
  @$gTblContainer = null
  @$configData = null
  @$formDialog = null
  @$redDot = null
  @ctor = null

  return

BaseSwallowLayer::init = ->
  self = this

  @ctor = cc.Layer.extend(
    ctor: (params)->
      @_super()
      @log = self.$logger.log
      @info = self.$logger.info
      @error = self.$logger.error
      @isDebugEnabled = self.$logger.isDebugEnabled
      @isInfoEnabled = self.$logger.isInfoEnabled
      @ez = self.$ez
      @display = self.$display
      @topic = self.$topic
      @userData = self.$userData
      @gTblContainer = self.$gTblContainer
      @ccbLoader = self.$ccbLoader
      @resourceUtil = self.$resourceUtil
      @socketClient = self.$socketClient
      @configData = self.$configData
      @formDialog = self.$formDialog
      @redDot = self.$redDot
      @setContentSize(params.sizeContent)

      return

    onEnter: ->
      @log("onEnter", @__classId)
      @_super()
      # touch event
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

    onExit: ->
      @cleanShoudian()
      @log("onExit", @__classId)
      ## 移除 Touch 监听
      @removeTouchListener()
      @_super()

    removeTouchListener: ->
      if @_listener_base
        cc.eventManager.removeListener(@_listener_base)
        @_listener_base.onTouchBegan = undefined
        @_listener_base.onTouchMoved = undefined
        @_listener_base.onTouchEnded = undefined
        @_listener_base.onTouchCancelled = undefined
      @_listener_base = undefined

    cleanup: ->
      @isAlreadyCleanUp = @__instanceId
      @__topLayer = undefined
      if @__ccbOutletNames
        for outletName in @__ccbOutletNames
          @[outletName] = undefined
      @_super()


    onTouchBegan: ->
      @log("onTouchBegan", @__classId)
      return true

    onTouchMoved: ->
      return true

    onTouchEnded: ->
      @log("onTouchEnded", @__classId)
      return true

    onTouchCancelled: ->
      return true
      
    ############# Touch Event ####################
    setVisible: (isVisible)->
      if @_visible != isVisible
        @_swallowTouches(isVisible)

      @_super(isVisible)

    _swallowTouches: (swallowTouches)->
      @_listener_base.swallowTouches = swallowTouches if @_listener_base


  )
  return

BaseSwallowLayer::get = (params)->
  new @ctor(params)
