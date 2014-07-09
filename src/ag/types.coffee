{pairs, map, mapValues} = require 'lodash'
{Success, Failure} = require 'data.validation'

# List [String, Validation] -> Validation Object
objectSequence = (nameValidationPairs) ->
  failures = []
  result = for [name, validation] in nameValidationPairs
    validation.fold(
      (failure) -> failures.push failure; [name, null]
      (success) -> [name, success]
    )

  if failures.length > 0
    Failure failures
  else
    Success pairsToObject result

# List [String, Any] -> Object
pairsToObject = (pairs) ->
  result = {}
  for [key, value] in pairs
    result[key] = value
  result

# List Validation -> Validation List
listSequence = (list) ->
  failures = []
  result = for validation in list
    validation.fold(
      (failure) -> failures.push failure; null
      (success) -> success
    )
  if failures.length > 0
    Failure failures
  else
    Success result

# (name) -> (value) -> {name: value}
objectWithProperty = (name) -> (value) ->
  object = {}
  object[name] = value
  object

nativeTypeValidator = (type) -> (input) ->
  if typeof input is type
    Success input
  else
    Failure ["Input was not of type #{type}"]

isArray = (input) -> (Object::toString.call input) is '[object Array]'
isObject = (input) -> (Object::toString.call input) is '[object Object]'

assertFunction = (input) ->
  unless typeof input is 'function'
    throw new Error "Type constructor argument was of type '#{typeof input}', function expected"

module.exports = types =
  Any: (input) ->
    if input?
      Success input
    else
      Failure ["Input was undefined"]

  OneOf: (types) ->
    for type in types
      assertFunction type
    (input) ->
    fail = Failure []
    for type in types
      validation = type(input)
      if validation.isSuccess
        return validation
      else
        fail = fail.ap validation
    fail

  String: nativeTypeValidator 'string'

  Boolean: nativeTypeValidator 'boolean'

  Number: nativeTypeValidator 'number'

  Property: (name, type = types.Any) ->
    assertFunction type
    (object) ->
      (if object?[name]?
        type object[name]
      else
        type null
      ).leftMap (errors) ->
        result = {}
        result[name] = errors
        result

  Object: (memberTypes) ->
    propertyNamesToTypes = mapValues memberTypes, (type, name) ->
      assertFunction type
      types.Property(name, type)

    (object) ->
      objectSequence (
        pairs mapValues propertyNamesToTypes, (propertyType) ->
          propertyType(object)
      )

  List: (type) ->
    assertFunction type
    (list) ->
      if not isArray list
        Failure ['Input was not an array']
      else
        listSequence (type(value) for value in list)

  Map: (type) ->
    assertFunction type
    (object) ->
      if not isObject object
        Failure ['Input was not an object']
      else
        objectSequence (
          pairs mapValues object, (_, propertyName) ->
            types.Property(propertyName, type)(object)
        )
    
  Optional: (type) ->
    assertFunction type
    (input) ->
      if input?
        type(input)
      else
        Success null

  projections:
    Property: (name, type = types.Any) ->
      assertFunction type
      (value) ->
        type(value).map(objectWithProperty name)

