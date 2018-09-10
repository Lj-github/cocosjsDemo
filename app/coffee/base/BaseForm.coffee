###*
  Form Base Object
  模态窗口基类 （屏蔽所有后面的 CCLayer 触摸事件）
  create by byron.song on 2015.10.17
###

BaseForm = ->
  @$id = 'baseForm'
  @$init = 'init'
  @$baseLayer = null
  @ctor = null
  @$topic = null
  return

BaseForm::init = ->
  self = @
  notMap = {
    "formLoading":true
    "formLoadingOnce":true
    "formWait":true
    "formhint3":true
    "formhint2":true
  }
  @ctor = bearcat.getBean('baseLayer').ctor.extend(
    ctor: (layerDefine)->
      @_super(layerDefine)
      @opacity = 170
      if layerDefine.isBlack
        @opacity = 255

      # 灰度背景，自动添加，可以通过 @setColorLayerVisible(false) 来隐藏
      @__colorLayer = @display.newColorLayer(cc.color(0, 0, 0, @opacity))
      @addChild(@__colorLayer, -1)

      return

    onEnter:->
      @_super()
      @_swallowTouches(true)
      @inAction()
    isForm: ->
      if @__isForm != undefined
        return @__isForm
      return true
    onExit:->
      @_super()
      if not notMap[@__classId]
        self.$topic.publish(cz.MSG_FORM_EXIT)
    ###*
      * 设置灰度背景是否可显示
      *
      * @param {Boolean} isVisible
    ###
    setColorLayerVisible: (isVisible)->
      @__colorLayer.setVisible(isVisible)

    inAction:()->
      if cz.ignoreMap[@__classId] or not @isForm() then return
      @__colorLayer.setScale(1.43)
      @setScale(0.7)
#      @runAction(cc.scaleTo(0.3,1).easing(cc.easeSineIn()))
#      @runAction(cc.sequence(cc.scaleTo(0.2,1.1).easing(cc.easeSineIn()),cc.scaleTo(0.1,1).easing(cc.easeSineInOut())))
#      @runAction(cc.scaleTo(0.3,1).easing(cc.easeBounceOut()))
#      @runAction(cc.scaleTo(0.5,1).easing(cc.easeElasticOut()))
      @runAction(cc.sequence(cc.scaleTo(0.1,1.1),cc.scaleTo(0.1,1),cc.callFunc(@afterInAction,@)))
      @__colorLayer.setOpacity(80)
      @__colorLayer.runAction(cc.fadeTo(0.25,@opacity))

    afterInAction:()->

    removeFromParent:()->
      if @_hasShow
        @_super()
        return
      @outAction()

    outAction:()->
      @_hasShow = true
      if cz.ignoreMap[@__classId] or not @isForm()
        @removeFromParent()
        return
      @runAction(cc.sequence(cc.scaleTo(0.1,0.7),cc.callFunc(->
        @removeFromParent()
      ,@)))
      @__colorLayer.runAction(cc.fadeTo(0.1,80))

  )
  return

BaseForm::get = ->
  new @ctor()

BaseForm::makeEmptyForm = ->
  ignorForm = cc.director.getRunningScene().getChildByTag(cz.COMMON_FORM_TOP_UP)
  if ignorForm
    return
  form = new @ctor(@)
  cc.director.getRunningScene().addChild(form, cz.ZORDER_FORM_TOP_UP or 0, cz.COMMON_FORM_TOP_UP)
  return form

