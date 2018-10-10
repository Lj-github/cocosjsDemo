var TapWater  = cc.Layer.extend({
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
        //gl.getActiveAttrib()
        var _that = this
        cc.loader.loadTxt(res.fragmentWather,function (x,fragmentWather) {
            cc.loader.loadTxt(res.vertex,function (x,vertex) {
                _that.initShader(vertex,fragmentWather)
            })
        })

        return true;
    },
    initShader:function(v,f){
        this.graySprite(this.sprite,v,f)
        this.schedule(this.run1,1/60);
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
            this.shader.use();
            this.time += 0.01;
            if (this.time >1){ this.time = 0.0 }
            this.shader.setUniformLocationWith1f(this.shader.getUniformLocationForName("time"),this.time)
            /**
             *  web 开发时候 使用 setUniformLocationWith3f (  10,  0.8,  0.1 ) 这种的 cc.sys.isNative  使用  setUniformVec2 这种的 ({ x: 10, y: 0.8, z: 0.1 })
             */

            this.shader.updateUniforms();
            if (this.dt >=5){
                // this.sprite.removeFromParent()
                // this.sprite = this.createSprit()
                // this.unschedule(this.run1)
                // this.shader = null
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
           // shader.addAttribute(cc.UNIFORM_SAMPLER_S,cc.UNIFORM_SAMPLER );
            //shader.addAttribute(cc.UNIFORM_TIME_S, cc.UNIFORM_SINTIME);
            shader.link();
            shader.updateUniforms();
            sprite.setShaderProgram(shader);
            this.shader = shader;
            this.shader.setUniformLocationWith2f(this.shader.getUniformLocationForName('center'), 0.5, 0.5  );
            this.shader.setUniformLocationWith3f(this.shader.getUniformLocationForName('params'),  10, 0.8, 0.1 );
        }
    },
});