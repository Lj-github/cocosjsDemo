var res = {
    HelloWorld_png : "res/HelloWorld.png",
    fragmentWather : "res/shader/fragmentWather.fsh",
    vertex : "res/shader/vertex.vsh",



};

var g_resources = [];
for (var i in res) {
    g_resources.push(res[i]);
}
