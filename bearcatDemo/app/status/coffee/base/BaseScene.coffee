###*
  Scene Base Object
  场景基类
  create by byron.song on 2015.10.16
###

BaseScene = ->
  @$id = 'baseScene'
  @$init = 'init'
  @ctor = null
  @$logger = null
  @$ez = null
  @$resourceUtil = null
  @$logger = null
  @$ccbLoader = null
  @$socketClient = null
  @$display = null
  @$userData = null
  @$gTblContainer = null
  return

BaseScene::init = ->
  self = this
  @ctor = cc.Scene.extend(
    ctor: ->
      @_super()

      @ez = self.$ez
      @display = self.$display
      @userData = self.$userData
      @gTblContainer = self.$gTblContainer
      @ccbLoader = self.$ccbLoader

      return

    onEnter: ->
      @_super()

    onExit: ->
      ## TODO 将来的规划:清理本次加载的缓存
      @_super()

    ###*
      * 发送Socket请求
      *
    ###
    send: (req, control, isSyncMessage) ->

      return



  )
  return

