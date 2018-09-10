
var HelloWorldLayer = cc.Layer.extend({
    sprite:null,
    shader:null,
    ctor:function () {
        this._super();
        var size = cc.winSize;
        var helloLabel = new cc.LabelTTF("Hello World", "Arial", 38);
        helloLabel.x = size.width / 2;
        helloLabel.y = size.height / 2 + 200;
        this.sprite = new cc.Sprite(res.HelloWorld_png);
        this.sprite.attr({
            x: size.width / 2,
            y: size.height / 2
        });
        this.addChild(this.sprite, 0);
        this.sprite.setScale(2.5)
        var vsh = "\n" +
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
            "}";

        //TexCoords的值是（0,0）到（1,1）


        var fsh = "\n" +
            "varying vec2 v_texCoord;\n" +
             "uniform float u_radius;\n"+

            "void main()\n" +
            "\n{\n" +
            "   float radius = u_radius;\n"+
            "   vec2 coord = v_texCoord;\n" +
            "   coord.x += (sin(coord.y * 8.0 * 3.1415926 + radius*3.1415926 *1000.0) / 30.0  )   ;\n" +
            "   vec2 uvs = coord.xy;\n" +
            "   gl_FragColor = texture2D(CC_Texture0, coord);\n" +
            "}";
        this.graySprite(this.sprite,vsh,fsh)
        this.schedule(this.run1,0.1);

        return true;
    },
    createSprit:function(){
        var sprite = new cc.Sprite(res.HelloWorld_png);
        sprite.attr({
        x: cc.winSize.width / 2,
        y: cc.winSize.height / 2
        });
        this.addChild(sprite, 0);
        sprite.setScale(2.5)
        return sprite
    },
    time : 0,
    dt:0,
    run1 :function(delta){
        this.dt += delta;
       // if(this.dt>3.14){this.dt-= 3.14;}
        if (this.sprite){
            this.time += delta;
            this.shader.use();
            var dd = 0.003 *(Math.cos(this.dt))

            this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName('u_radius'), 0.003 * this.dt );
            // this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName('u_lightness'), Math.abs(Math.sin(2 * this.dt)));
            this.shader.updateUniforms();
            if (this.dt >=5){
                this.sprite.removeFromParent()
                this.sprite = this.createSprit()
                this.unschedule(this.run1)
                this.shader = null
            }
        }
    },
    graySprite : function (sprite,vertexSrc,grayShaderFragment)
    {
        if (sprite) {
            var shader = new cc.GLProgram();//cc.GLProgram.create("gray.vsh", "gray.fsh");
            shader.retain();
            //this.shader.initWithVertexShaderByteArray(_default_vert, _black_white_frag);
            // shader.init(res.gray_vsh, res.gray_fsh);
            shader.initWithVertexShaderByteArray(vertexSrc, grayShaderFragment);
            shader.addAttribute(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION);
            shader.addAttribute(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR);
            shader.addAttribute(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS);
            //shader.addAttribute(cc.UNIFORM_TIME_S, cc.UNIFORM_SINTIME);
            shader.link();
            shader.updateUniforms();
            sprite.setShaderProgram(shader);
            window.SSS = sprite
            this.shader = shader;
        }
    },



});

var HelloWorldScene = cc.Scene.extend({
    onEnter:function () {
        this._super();
        var node = new cc.Node()
        //node.setPosition(cc.p(cc.winSize.width/2,cc.winSize.height/2))
        this.addChild(node)
        node.setName("layerNode")
        this.createList()
        var layer = new HelloWorldLayer();
        node.addChild(layer);
    },

    createList:function(){
        var node = new cc.Node()
        this.addChild(node)
        var size = cc.winSize;
        var sprite = new cc.Sprite(res.HelloWorld_png);
        sprite.attr({
            x: size.width / 2,
            y: size.height / 2
        });
        node.addChild(sprite, 0);


        var tableView  = new cc.TableView(this,cc.size(200,cc.winSize.height))
        tableView.setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView.x = 0
        tableView.y = 0
        tableView.setDelegate(this);
        tableView.setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
        node.addChild(tableView);
        const data  = [
            {item: "TapWater"},
            {item: "DrawWords"},
        ]
        this.dataList = data
        tableView.reloadData();
        cc.director.setNotificationNode(node)

    },
      //TableView继承ScrollView有这俩个方法，不需要添加任何内容
    //scrollViewDidScroll: function (view) {
    //},
    //scrollViewDidZoom: function (view) {
    //},
    //设置点击cell后的回调函数
    tableCellTouched: function (table, cell) {
        cc.log("cell touched at index: " + cell.getIdx());
        var idx = cell.getIdx()
        var data = this.dataList[idx]
        var runnineScene = cc.director.getRunningScene()
        var layer = new window[data.item]()
        var layerNode = runnineScene.getChildByName("layerNode")
        if (layerNode){
            layerNode.removeAllChildren()
            layerNode.addChild(layer)
        }
    },

    //设置cell大小
    tableCellSizeForIndex: function (table, idx) {
        return cc.size(150, 50);
    },
    dataList:[],
    //添加Cell
    tableCellAtIndex: function (table, idx) {
        var strValue = idx.toFixed(0);
        //获得一个cell，滑动cell的时候会执行这个方法，把没有显示（没渲染）的cell拿过来，更改内容，为了减小内存的开销
        var data = this.dataList[idx]
        var cell = table.dequeueCell();
        var label;
        if (!cell) {
            cell = new cc.TableViewCell();
            // 添加文本
            label = new cc.LabelTTF(data.item, "Helvetica", 30);
            label.x = 0;
            label.y = 0;
            label.anchorX = 0;
            label.anchorY = 0;
            label.color = cc.color(255, 0, 0, 255);
            cell.addChild(label);
        } else {
            //更改文本信息
            label = cell.getChildByTag(123);
            label.setString(data.item);
        }
        return cell;
    },
   //设置cell个数
    numberOfCellsInTableView: function (table) {
        return this.dataList.length;
    }

});

