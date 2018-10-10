// define(function(require, exports, module) {
var Car = function() {
	this.$id = "car";
	this.$engine = null;
	this.$Vnum = "${car.num}";
}

Car.prototype.run = function() {
	this.$engine.run();
	console.log('car run...' + this.$Vnum);
}

module.exports = Car;
// })