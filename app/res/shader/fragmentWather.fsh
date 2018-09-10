precision lowp float;       //顶点着色器中默认精度
varying vec2 v_texCoord; //多纹理的时候这个参数代表着纹理的层。
varying vec4 vColor;            //varying变量是vertex和fragment shader之间做数据传递用的。一般vertex shader修改varying变量的值，
                                //然后fragment shader使用该varying变量的值。因此varying变量在vertex和fragment shader二者之间的声明必须是一致的。application不能使用此变量。
                                // 意思就是  在 vertex和fragment shader 两个里面都要一样写的
//uniform sampler2D CC_Texture0; // 访问一个二维纹理

uniform vec2 center;       //   uniform 变量就像是C语言里面的常量（const ） 在shader 里面不能改变  只能通过外面改变
uniform vec3 params ;       // 10.0, 0.8, 0.1"
uniform float time;         //

void main()
{
    vec2 uv = v_texCoord.xy; // v_texCoord.xy代表像素在Framebuffer画面的位置，gl_FragCoord.z代表这个店在做Z Buffer测试时所用的Z值
    vec2 texCoord = uv;

    float dist = distance(uv, center); // 计算向量 uv ，center 之间的距离

    if ( (dist <= (time + params.z)) && (dist >= (time - params.z)) )  // 应该是要 突起的部分
    {
        float diff = (dist - time);
        float powDiff = 1.0 - pow(abs(diff*params.x), params.y); // pow  x的y次方。如果x小于0，结果是未定义的。同样，如果x=0并且y<=0,结果也是未定义的。使用时应特别注意。
                                                                   //abs    返回x的绝对值
        float diffTime = diff  * powDiff;
        vec2 diffUV = normalize(uv - center);  //标准化向量，返回一个方向和x相同但长度为1的向量   相当于 单位向量 模等于1
        texCoord = uv + (diffUV * diffTime);   //
    }
    gl_FragColor = texture2D(CC_Texture0, texCoord);   // 	输出的颜色用于随后的像素操作
}
