###*
  Layer Base Object
  Layer基类
  create by byron.song on 2015.10.16
###

BaseLayer = ->
  @$id = 'baseLayer'
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

BaseLayer::init = ->
  self = this

  @ctor = cc.Layer.extend(
    ctor: (classDefine, isAppend)->
      @_super()
      # log
      @log = self.$logger.log
      @info = self.$logger.info
      @error = self.$logger.error
      @isDebugEnabled = self.$logger.isDebugEnabled
      @isInfoEnabled = self.$logger.isInfoEnabled
      @setContentSize(720,1280)
      # common variable
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

      # init
      @__classId = "BaseLayer"
      if classDefine
        @__classDefine = classDefine
        # class id，取自 self.$id
        @__classId = classDefine.$id
        # 是否支持返回按钮
        @__isAppendLayer = classDefine.isAppendLayer

      #banner类型
      @bannerType = cz.BannerType.OTHER

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

      # Socket Response Map
      # key: message.code, value: Response Message Class
      @_messageDefineMap = {}
      # serial map
      @_messageSerialMap = {}
      # 是否存在主题定义，若有，onExit的时候，自动退订
      @_isTopicSubcribe = false
      # 记录当前发出的指令跟按钮之间的关系，如果有关联，则当收到serial一致的消息反馈时，自动执行 control.finishMenuEvent
      # key: message.serial, value: ControlButton | MenuItem
      @_control4MsgMap = {}
      if cc.MenuItemTouchBeganTarget
        cc.MenuItemTouchBeganTarget._state = cc.MENU_STATE_WAITING
        cc.MenuItemTouchBeganTarget = undefined
#      @subscribe('SocketDisconnect', @socketDisconnect)
      @log('@userData.eduIdx = ',@userData.eduIdx)
      @subscribe(cz.MSG_RENWU_EDU_START,@taskEdu)
#      cc.sys.isMobile = true
#      cz.isAdaption = true
      if cc.sys.isMobile and cz.isAdaption
        gameBody = document.getElementById("gameBody");
        widthScale = (1280/720)/(gameBody.clientHeight/gameBody.clientWidth);
        cc.view.setDesignResolutionSize(720*widthScale,1280, cc.ResolutionPolicy.SHOW_ALL)
        scene = cc.director.getRunningScene()
        if scene and scene.adjustPositionX
          scene.adjustPositionX()


    onExit: ->
      @log("onExit", @__classId)
      ## 移除Socket监听
      self.$socketClient.unregisterAllOnTarget(@) if @_messageDefineMap


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

    #清理cell挂载的ccb对象
    clearCellOutCCBList:(cell)->
      if cell and cell._outCCBList
        for NodeObj in cell._outCCBList
          @clearCellCCB(NodeObj)
        cell._outCCBList = undefined
    #为传入的cell添加挂载的obj以便于后面删除，暂时预留
    addCelloutCCBList:(cell,NodeObj)->
      if cell and NodeObj
        if not cell._outCCBList then cell._outCCBList = []
        cell._outCCBList.push(NodeObj)
    #清除一个ccb对象
    clearCellCCB:(Nodeobj)->
      if Nodeobj and Nodeobj.__ccbOutletNames
        for outletName in Nodeobj.__ccbOutletNames
          Nodeobj[outletName] = undefined
    #清除cell的数据
    clearCell:(cell)->
      @clearCellOutCCBList(cell)
      if cell and cell._ccb
        if cc.isArray(cell._ccb)
          for i in [0 .. (cell._ccb.length - 1)]
            @clearCellCCB(cell._ccb[i].getParent())
            cell._ccb[i] = undefined
        else
          @clearCellCCB(cell)
        cell._ccb = undefined
        @log('clear used cell')
        cell.removeAllChildren()
        cell.removeFromParent()

    clearTableView:->
      if @tableView
        cellsFreed = @tableView._cellsFreed
        count  = cellsFreed.count()
        for i in [0 .. (count - 1)]
          cell = cellsFreed.objectAtIndex(i)
          if cell and cell._ccb
            @clearCell(cell)
            cell = undefined
        for i in [0 .. (count - 1)]
          cellsFreed.removeObjectAtIndex(count - 1 - i)
        cellsFreed = undefined
        cellsUsed = @tableView._cellsUsed
        count  = cellsUsed.count()
        for i in [0 .. (count - 1)]
          cell = cellsUsed.objectAtIndex(i)
          @clearCell(cell)
          cell = undefined
        for i in [0 .. (count - 1)]
          cellsUsed.removeObjectAtIndex(count - 1 - i)
        cellsUsed = undefined
        @tableView = undefined



    onTouchBegan:(touch, event) ->
      if touch
        pos = touch.getLocation()
        target = event.getCurrentTarget()
        chileren = target.getChildren()
        all = @ez.getTouchNodeByPos(chileren,pos)
        allImgFile = @ez.getNodeListImg(all)
        @log("onTouchImgURL", allImgFile)
      @log("onTouchBegan", @__classId)
      return true

    onTouchMoved: ->
      return true

    onTouchEnded: ->
      @log("onTouchEnded", @__classId)
      return true

    onTouchCancelled: ->
      return true

    addLayer: (newLayer,isForceAdd)->
      topLayer = @__topLayer || self._G_Toplayer
      if not topLayer
        @error("this._topLayer is undefined!!!")
        return
      if this.gettopLayer()._currLayer.__classId == newLayer.__classId and cz.baseLayer_canotReAdd[newLayer.__classId]
        self.$topic.publish(cz.MSG_SAME_ADD_UPDATE, newLayer)
        return

      if newLayer.isForm()
        # 弹出窗体
        topLayer.addForm(newLayer)
      else if newLayer.isAppend()
        # 新页面支持返回事件
        topLayer.appendLayer(newLayer)
      else
        # 其他的，都是一级页面
#        guajiLayer = @getByTag(cz.GuajiCheckTag)
#        if guajiLayer
#          guajiLayer.setVisible(false)
        topLayer.addFirstLayer(newLayer,isForceAdd)
#      if newLayer.__classId is 'formBattleArray'
#        @log("scalenewlayer2:", newLayer.__classId)
#        newLayer.setScale(2)
#        newLayer.setAnchorPoint(cc.p(0,0))

    isAppend: ->
      return @__isAppendLayer

    isForm: ->
      if @__isForm != undefined
        return @__isForm
      return false
    getReturnParams:->
      return {returnParams:{layerName:@__classId,returnParams:@returnParams}}

    tryInitPreInfo:(params)->
      if (params && params.returnParams)
        @returnParams = params.returnParams

    tryReturnPre:(cb,cbParams)->
      if @returnParams
        bearcat.getBean(@returnParams.layerName).get((form)->
          @addLayer(form)
          if cb
            cb.call(this,cbParams)
        ,@,@returnParams)
        return true
      else
        if cb
          cb.call(this,cbParams)


    ###*
      * 根据tag删除子界面
    ###
    removeByTag: (tag)->
      topLayer = @__topLayer || self._G_Toplayer
      if not topLayer
        return
      topLayer.removeChildByTag(tag)
    ###*
      * 根据tag获取自界面
    ###
    getByTag: (tag) ->
      topLayer = @__topLayer || self._G_Toplayer
      if not topLayer
        return undefined
      childlayer = topLayer.getChildByTag(tag)
      return childlayer

    gettopLayer: ()->
      topLayer = @__topLayer || self._G_Toplayer
      if not topLayer
        return undefined
      return topLayer
    removeForm: ->
      topLayer = @__topLayer || self._G_Toplayer
      if not topLayer
        return
      children = topLayer.getChildren()
      len = children.length
      for i in [len..1] by -1
        lastChild = children[i-1]
        if lastChild and typeof(lastChild.isForm) is 'function' and lastChild.isForm()
          lastChild.removeFromParent()

    removeFormExceptSelf: ->
      topLayer = @__topLayer || self._G_Toplayer
      if not topLayer
        return
      children = topLayer.getChildren()
      len = children.length
      for i in [len..1] by -1
        lastChild = children[i-1]
        if lastChild and typeof(lastChild.isForm) is 'function' and lastChild.isForm() and (lastChild.__classId isnt @__classId)
          lastChild.removeFromParent()

    ###*
      * 加载本 Layer 除构造函数之外所需的额外资源，完成后执行相应的回调函数
      *
      * @param {cc.Node} parent
      * @param {function} [optional] callback
      *
    ###
    addTo: (parent, cb) ->
      baseResources = @getBaseResources?() ? undefined
      if baseResources
        self.$resourceUtil.load(baseResources, ->
          parent.addChild(@)
          if cb
            cb.call(parent)
        , @)
      else
        parent.addChild(@)
        if cb
          cb.call(parent)
      return


    ############ 以下为 cc.TableViewDelegate 以及 cc.TableViewDataSource 方法 ##############
    ###*
      * tableCellSizeForIndex
      * 如果单元格的大小并不一致，则需要 override 该方法
      * return {cc.size}
    ###
    tableCellSizeForIndex: (table, idx)->
        return @_cellSize

    ###*
      * tableCellAtIndex
      * 具体的 Layer|Form 实现类，需实现 createTableCellPoints: (idx, cell) -> 方法，才能完成一个TableCell的实现工作
      * return {cc.TableViewCell}
    ###
    tableCellAtIndex: (table, idx)->
      cell = table.dequeueCell()
#      if cell
#        cell.removeAllChildren()
#      else
#        cell = new cc.TableViewCell()
      if not cell
        cell = new cc.TableViewCell()
      @createTableCellPoints(idx, cell)

      return cell

    numberOfCellsInTableView: (table) ->
      return 0
    ###*
      * 记载ccb文件，创建的 Node 直接添加为 TableViewCell 的 child node
      * 同时将ccb中的事件回调方法转移到当前 Layer 上
      *
      * @param {String} file
      * @param {cc.TableViewCell} tableViewCell
      * @param {cc.Size} [optional] parentSize，如果为null，则默认为window size
      * @param {String} [optional] resourcePath，默认为 "res/ui/"
      * return {cc.Node}
    ###


    ############ 以下为 Socket相关 方法 ##############
    registerOnSocketEvent: (responseDefine, cb, once) ->


    ###*
      * 发送Socket请求
      *
      * @param {GameProtocol.Message} req 请求指令
      * @param {cc.ControlButton|CCMenuItem} control 发出指令的按钮，当收到相应反馈后，自动执行对应的finishMenuEvent
      * @param {Boolean} isSyncMessage 是否同步指令，若是，则服务器端反馈的serial则与req.serial一致，若非，则为0 （例如战斗请求）
      *
    ###
    send: (req, control, isSyncMessage) ->

      return

    _sendMessage: (req, control, isSyncMessage) ->
      # 由于本次输出 for 循环较多，因此需要判断是否支持 debug 输出

      return




    ############ 以下为 Topic相关 方法 ##############
    ###*
      * 订阅某个Topic相关事件
      * Example:
      *   添加订阅
      *   @subscribe("AAA", (p1, p2) ->
            @log("AAA", p1, p2)
          )
      *   发出事件广播
          @topic.publish("AAA", "Google", 200)
      *
      * @param {String} topic
      * @param {Function} cb
      *
    ###
    subscribe: (topic, cb) ->
      if @_isTopicSubcribe == undefined
        self.$logger.error("You Should subscribe topic after BaseLayer.onEnter!!!")
        return

      @topic.subscribe(topic, cb, @)
      @_isTopicSubcribe = true

    ############# Touch Event ####################
    setVisible: (isVisible)->
      if @_visible != isVisible
        @_swallowTouches(isVisible)

      @_super(isVisible)

    _swallowTouches: (swallowTouches)->
      @_listener_base.swallowTouches = swallowTouches if @_listener_base


    #################### Label Stroke #################
    ###*
      * 设置CCB LabelTTF 和 ControlButton 外描边
      * @param {cc.LabelTTF|cc.ControlButton} node
      * @param {cc.Color} strokeColor The color of stroke
      * @param {Number} strokeSize The size of stroke
      * @param {cc.Color} fillColor The fill color of the label
    ###
    enableLabelStroke: (node, strokeColor, strokeSize, fontFillColor) ->
      if node instanceof cc.ControlButton
        @ez.makeCCButtonTitleOutline(node, strokeColor, strokeSize, fontFillColor || node.getTitleColorForState(cc.CONTROL_STATE_NORMAL))
      else if node instanceof cc.LabelTTF
        @ez.makeCCBLabelOutline(node, strokeColor, strokeSize, fontFillColor || node.getColor())

    ###*
      * 设置CCB LabelTTF 和 ControlButton 外描边为白色
      * @param {cc.LabelTTF|cc.ControlButton} node
      * @param {Number} strokeSize The size of stroke
      * @param {cc.Color} color The fill color of the label
      * Examples:
      *
      * 单个 CCNode
      *  @enableLabelStrokeWhite(@menuPlay, 2)
      * 多个 CCNode
          @enableLabelStrokeWhite([
            {
              node: @menuLogin
              strokeSize: 2
            },
            {
              node: @menuCreate
              strokeSize: 4
            }
          ])
    ###
    enableLabelStrokeWhite: (node, strokeSize, color) ->
      if cc.isArray(node)
        for value in node
          @enableLabelStroke(node.node, cc.color.WHITE, node.strokeSize, node.color)
      else
        @enableLabelStroke(node, cc.color.WHITE, strokeSize, color)

    ###*
      * 设置CCB LabelTTF 和 ControlButton 外描边为黑色
      * @param {cc.LabelTTF|cc.ControlButton} node
      * @param {Number} strokeSize The size of stroke
      * @param {cc.Color} color The fill color of the label
      * Examples:
      * 单个 CCNode
      *  @enableLabelStrokeBlack(@menuPlay, 2)
      * 多个 CCNode
          @enableLabelStrokeBlack([
            {
              node: @menuLogin
              strokeSize: 2
            },
            {
              node: @menuCreate
              strokeSize: 4
            }
          ])
    ###
    enableLabelStrokeBlack: (node, strokeSize, color) ->
      if cc.isArray(node)
        for value in node
          @enableLabelStroke(value.node, cc.color.BLACK, value.strokeSize, value.color)
      else
        @enableLabelStroke(node, cc.color.BLACK, strokeSize, color)

    #正常描边颜色 3b4447
    enableLabelStrokeCommon: (node, strokeSize, color,strokeColor) ->
      if not strokeSize then strokeSize = 2
      if not strokeColor then strokeColor = cz.COLOR_STROKE1
      if cc.isArray(node)
        for value in node
          @enableLabelStroke(value.node, strokeColor, value.strokeSize, value.color)
      else
        @enableLabelStroke(node, strokeColor, strokeSize, color)


    ###
    * 递归设置节点的孩子节点的描边，暂时只支持通用的描边颜色，宽度为2
    ###
    addChildrenStroke: (root)->
      if root instanceof cc.LabelTTF or root instanceof cc.ControlButton
        @enableLabelStrokeCommon(root, 2)
      children = root.getChildren()
      for node in children
        @addChildrenStroke(node)



    getTopClassLayer: ->
      topLayerClass = bearcat.getBean("topLayer")
      return topLayerClass

    isFirstGoShowForm: (params) ->
      if params and params.isGet
        return true
      return false

    isNumEnough: (type,id,needcount) ->
      if type == cz.JL_TYPE.DAOJU
        dapju = @userData.getDaojuById(id)
        count = dapju and dapju.daojuCount or 0
        if count >= needcount
          return true
#      @ez.showTip(@gTblContainer.beizhuDefMap[154].words)
      @lackHint(id, needcount)
      return false

    setZhongzuPic: (node, level) ->
      @loadResource([cz.zhongzuLevel[level]], ->
        node.setTexture(cz.zhongzuLevel[level])
      ,undefined ,false)


    createEditBox: (nodeInput,HOLD_STR,isCenter,MAX_LENGTH)->
      editbox = @display.newEditBox(nodeInput.getContentSize(), new cc.Scale9Sprite("pika_tongyong_kuozhan.png"))
      nodeInput.addChild(editbox)
      editbox.setAnchorPoint(cc.p(0,0))
      editbox.setPlaceHolder(HOLD_STR)
      editbox.setPlaceholderFont(cz.UI_FONT_DEFAULT)
      editbox.setPlaceholderFontSize(22)
      editbox.setPosition(cc.p(2, 0))
      editbox.setFontSize(24)
      editbox.setDelegate(this)
      editbox.setFontColor(cc.color(255, 255, 255))
      editbox.setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
      editbox.setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
      editbox.setMaxLength(MAX_LENGTH or 15)
#      if isCenter
#        editbox.setAl
      @editbox = editbox

  )
  return

BaseLayer::getMessageName = (msg)->
  defineMap = @__messageDefineMap
  if not defineMap
    defineMap = {}
    # init message define name
    for key, msgDefine of GameProtocol
      code = msgDefine.MAIN_TYPE << 8 | msgDefine.SUB_TYPE
      defineMap[code] = key
    @__messageDefineMap = defineMap
  msgCode = msg.messageCode
  if not msgCode
    msgCode = msg.mainType << 8 | msg.subType
  return defineMap[msgCode]

BaseLayer::makeEmptyFirstLayer = ->
  layer = new @ctor(@)
  layer._hideHomeBar = true
  sp = layer.display.newSprite('res/ui/'+'zd_caocj.jpg',360,640)
  layer.addRegisterImg('res/ui/'+'zd_caocj.jpg')
  layer.addChild(sp)
  return layer

BaseLayer::get = ->
  new @ctor()

