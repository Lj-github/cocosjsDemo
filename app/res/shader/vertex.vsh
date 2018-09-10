attribute vec4 a_position; // attribute变量是只能在vertex shader中使用的变量
attribute vec2 a_texCoord;   //
attribute vec2 a_color;

uniform vec2 projectionVector;

varying vec2 v_texCoord;
varying vec4 vColor;

const vec2 center = vec2(-1.0, 1.0);

void main(void) {
    gl_Position = CC_PMatrix *  a_position ;  //出属性-变换后的顶点的位置，用于后面的固定的裁剪等操作。所有的顶点着色器都必须写这个值。
    v_texCoord = a_texCoord;
    vColor = vec4(a_color.x, a_color.x, a_color.x, a_color.y);
}
