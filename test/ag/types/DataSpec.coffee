require('chai').should()

types = require '../../../src/ag/types'

describe "ag-types.data", ->
  it "is an object", ->
    types.data.should.be.an 'object'

  describe "Validation", ->
    it "is an object", ->
      types.data.should.have.property('Validation').be.an 'object'

    it "exposes Success", ->
      types.data.Validation.should.have.property('Success').be.a 'function'

    it "exposes Failure", ->
      types.data.Validation.should.have.property('Failure').be.a 'function'

