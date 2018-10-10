
require('./bearcat-bootstrap.js');
var bearcat = require('bearcat'); // 依赖bearcat库
window.bearcat = bearcat; // using browserify to resolve npm modules

cc.game.onStart = function () {
    cc.view.enableRetina(true);
    cc.view.adjustViewPort(true);
    cc.view.setDesignResolutionSize(720, 1280, cc.ResolutionPolicy.SHOW_ALL);
    var resize = true;
    var specialPfs = ['weibo']
    if (sdkManager && (sdkManager.upperChannel == 'djs' && specialPfs.indexOf(sdkManager.sdkType) == -1) && cc.sys.os == cc.sys.OS_IOS)
        resize = false;
    cc.view.resizeWithBrowserSize(resize);

    if (!window.easyGameConf.forJSDeveloper) {
        // 开发状态不使用 bundle
        var idPaths = __bearcatData__.idPaths;
        for (var key in idPaths) {
            if (idPaths.hasOwnProperty(key)) {
                idPaths[key] = 'static/script/release/bundle.js';
            }
        }
    }

    //load resources
    bearcat.createApp();

    bearcat.use(['game']);
    bearcat.use(['resourceUtil']);

    bearcat.start(function () {
        var game = bearcat.getBean('game');
        game.start();
    });

};

//cc.game.run();

