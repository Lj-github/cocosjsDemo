/*!
 * .______    _______     ___      .______       ______     ___   .__________.
 * (   _  )  (   ____)   /   \     (   _  )     (      )   /   \  (          )
 * |  |_)  ) |  |__     /  ^  \    |  |_)  )   |  ,----'  /  ^  \ `---|  |---`
 * |   _  <  |   __)   /  /_\  \   |      )    |  |      /  /_\  \    |  |
 * |  |_)  ) |  |____ /  _____  \  |  |)  ----.|  `----./  _____  \   |  |
 * (______)  (_______/__/     \__\ ( _| `.____) (______)__/     \__\  |__|
 *
 * Bearcat grunt-bearcat-browser
 * Copyright(c) 2015 fantasyni <fantasyni@163.com>
 * MIT Licensed
 */

'use strict';

var BearcatBin = require('bearcat/bin/bearcat-bin');

module.exports = function(grunt) {

  grunt.registerMultiTask('bearcat_browser', 'grunt bearcat browser task', function() {
    // Merge task-specific and/or target-specific options with these defaults.
    var options = this.options({

    });

    this.files.forEach(function(opts) {
      opts['output'] = opts['dest'];
      BearcatBin.doGenerateIdPaths(opts);
    });
  });

};