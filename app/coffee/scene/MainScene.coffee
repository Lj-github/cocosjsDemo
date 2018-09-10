
MainScene = ->
  return
MainScene::init = ->
  @ctor = cc.Scene.extend(
    ctor: (params) ->
      @_super()
      @dataList = []

    onEnter : ->
      @_super()
      console.log "enter == > " + "MainScene"
      node = new cc.Node()
      @addChild(node)
      node.setName("layerNode")
      this.createList()
      layer = new TapWater().get()
      node.addChild(layer)  

    createList:->
      node = new cc.Node()
      @addChild(node)
      size = cc.winSize  
      sprite = new cc.Sprite(res.HelloWorld_png)  
      sprite.attr({
        x: size.width / 2,
        y: size.height / 2
      })  
      #node.addChild(sprite, 0)
      tableView  = new cc.TableView(this,cc.size(200,cc.winSize.height))
      tableView.setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
      tableView.x = 0
      tableView.y = 0
      tableView.setDelegate(this)  
      tableView.setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)  
      node.addChild(tableView)  
      data  = [
        {item: "TapWater"},
        {item: "LayerWave"},
      ]
      this.dataList = data
      tableView.reloadData()  
      cc.director.setNotificationNode(node)



    tableCellTouched:(table, cell)->
      cc.log("cell touched at index: " + cell.getIdx())  
      idx = cell.getIdx()
      data = this.dataList[idx]
      runnineScene = cc.director.getRunningScene()
      layer = new window[data.item]().get()
      layerNode = runnineScene.getChildByName("layerNode")
      if layerNode
        layerNode.removeAllChildren()
        layerNode.addChild(layer)
    tableCellSizeForIndex: (table, idx)->
      return cc.size(150, 50)  

    tableCellAtIndex: (table, idx) ->
      strValue = idx.toFixed(0)  
      #获得一个cell，滑动cell的时候会执行这个方法，把没有显示（没渲染）的cell拿过来，更改内容，为了减小内存的开销
      data = this.dataList[idx]
      cell = table.dequeueCell()  
      label  
      if not cell
        cell = new cc.TableViewCell()
        label = new cc.LabelTTF(data.item, "Helvetica", 30)
        label.x = 0
        label.y = 0
        label.anchorX = 0
        label.anchorY = 0
        label.color = cc.color(255, 0, 0, 255)
        cell.addChild(label)
      else
        label = cell.getChildByTag(123)
        label.setString(data.item)
      return cell

   #设置cell个数
    numberOfCellsInTableView:  (table)->
      return this.dataList.length  



  )
  return
MainScene::get = (cb, cbTarget, params) ->
  @init()
  return new @ctor(params)