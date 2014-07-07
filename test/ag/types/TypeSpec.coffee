require('chai').should()

types = require '../../../src/ag/types'

describe "Typing data with steroids.data.types", ->
  it "Should have a String type", ->
    types.String.should.be.a 'function'

  describe 'String type', ->
    it 'Should pass a string', ->
      types.String('anything').isSuccess.should.be.true

    it 'Should not pass undefined', ->
      types.String(undefined).isFailure.should.be.true

    it 'Should allow extracting value', ->
      types.String('anything').get().should.equal 'anything'

  it "Should have a Property type", ->
    types.Property.should.be.a 'function'

  describe 'Property type', ->
    NameProperty = types.Property('name')

    it 'Should accept a property name and return a validator', ->
      NameProperty.should.be.a 'function'

    it 'Should pass an object with the property', ->
      NameProperty(name: 'anything').isSuccess.should.be.true

    it 'Should fail an object without the property', ->
      NameProperty({}).isFailure.should.be.true

    it 'Should fail undefined', ->
      NameProperty(undefined).isFailure.should.be.true

    StringNameProperty = types.Property('name', types.String)

    it 'Optionally accepts a type for the property', ->
      StringNameProperty(name: undefined).isFailure.should.be.true
      StringNameProperty(name: 'anything').isSuccess.should.be.true

    it 'Allows extracting property from object', ->
      StringNameProperty(name: 'anything').get().should.equal 'anything'

  it "Should have an Object type", ->
    types.Object.should.be.a 'function'

  describe "Object type", ->
    TaskType = types.Object(description: types.String)

    it 'Should accept an object of types and return a validator', ->
      TaskType.should.be.a.function

    it 'Should pass an object whose properties pass validation', ->
      TaskType(description: 'anything').isSuccess.should.be.true
      TaskType(description: undefined).isFailure.should.be.true

    it 'Allows access to validated object', ->
      TaskType(description: 'anything').get().description.should.equal 'anything'

  it "Should have a List type", ->
    types.List.should.be.a 'function'

  describe "List type", ->
    StringList = types.List(types.String)

    it 'Should accept a type and return a validator', ->
      StringList.should.be.a.function

    it 'Should pass a list whose items pass validation', ->
      StringList([]).isSuccess.should.be.true
      StringList(['anything']).isSuccess.should.be.true

    it 'Should fail if input is not a list', ->
      for notAList in [null, {}, 'anything']
        StringList(notAList).isFailure.should.be.true

    it 'Should fail if any item does not pass', ->
      StringList([null]).isFailure.should.be.true
      StringList(['anything', null]).isFailure.should.be.true

    it 'Allows access to validated list', ->
      StringList(['anything']).get()[0].should.equal 'anything'

  it "Should have a Map type", ->
    types.Map.should.be.a 'function'

  describe "Map type", ->
    StringMap = types.Map(types.String)
    it 'Should accept a type and return a validation', ->
      StringMap.should.be.a.function

    it 'Should pass an object whose elements pass validation', ->
      StringMap({}).isSuccess.should.be.true
      StringMap(foo: "bar").isSuccess.should.be.true

    it 'Should fail if input is not an object', ->
      for notAnObject in [null, [], 'anything']
        StringMap(notAnObject).isFailure.should.be.true

    it 'Should fail if any item does not pass', ->
      StringMap(foo: "bar", qux: 123).isFailure.should.be.true

  it "Should have a Boolean type", ->
    types.Boolean.should.be.a 'function'

  describe "Boolean type", ->
    it "Should not accept empty values", ->
      types.Boolean(null).isFailure.should.be.true

    it "Should accept true and false", ->
      types.Boolean(true).isSuccess.should.be.true
      types.Boolean(false).isSuccess.should.be.true

  it "Should have an Optional type", ->
    types.Optional.should.be.a 'function'

  describe "Optional type", ->
    OptionalBoolean = types.Optional(types.Boolean)
    
    it "Should accept a type and return a validator", ->
      OptionalBoolean.should.be.a 'function'

    it 'Should accept undefined values', ->
      OptionalBoolean(null).isSuccess.should.be.true

    it 'Should accept values matching the inner type', ->
      OptionalBoolean(true).isSuccess.should.be.true

    it 'Should not accept values not accepted by the inner type', ->
      OptionalBoolean('anything').isFailure.should.be.true

  it "Should have a disjunction type", ->
    types.OneOf.should.be.a.function

  describe "Disjunction type OneOf", ->
    BooleanOrString = types.OneOf([types.Boolean, types.String])

    it "Should accept a list of types and return a validator", ->
      BooleanOrString.should.be.a.function

    it "Should accept any of the provided types", ->
      for booleanOrStringValue in [true, false, 'anything']
        BooleanOrString(booleanOrStringValue).isSuccess.should.be.true

    it "Should not accept values not accepted by any inner type", ->
      for notABooleanOrStringValue in [null, {}, [], 123]
        BooleanOrString(notABooleanOrStringValue).isFailure.should.be.true

  it "Should have a Property projection", ->
    types.projections.Property.should.be.a 'function'

  describe "Object property projection", ->
    projectToStringProperty = types.projections.Property('stringProperty', types.String)

    it "Should accept a property name and return a projection", ->
      projectToStringProperty.should.be.a.function

    it 'Should project the value into a validation', ->
      do (projectedString = projectToStringProperty('anything')) ->
        projectedString.isSuccess.should.be.true
        projectedString.get().should.deep.equal stringProperty: 'anything'

    it "Should not project anything that doesn't match the property type", ->
      for totallyNotAString in [false, null, {}, []]
        notAProjectedString = projectToStringProperty totallyNotAString
        notAProjectedString.isFailure.should.be.true



