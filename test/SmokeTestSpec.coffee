require('chai').should()

describe "ag-types", ->
  it "should be an object", ->
    require('../src/ag/types').should.be.an.object