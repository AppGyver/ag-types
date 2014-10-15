assert = require '../assert'
{objectWithProperty} = require './helpers'

module.exports =
  Property: (name, type = types.Any) ->
    assert.isFunction type
    (value) ->
      type(value).map(objectWithProperty name)
