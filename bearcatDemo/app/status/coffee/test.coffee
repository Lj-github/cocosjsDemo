# @Time    : 2018/9/5 下午2:05

##  var ds = new test().get()  获取类 cocos 类  如果是 自己写的类  可以直接使用 coffee 的 :: 形式  或者全部都这样

test = ->
  return
test::init = ->
  @ctor = cc.Layer.extend(
    ctor: (params) ->
      @_super()
    onEnter : ->
      console.log(5)

  )
  return
test::get = (cb, cbTarget, params) ->
  @init()
  return new @ctor(params)
