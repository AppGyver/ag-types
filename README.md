ag-types - arbitrary data structure validation for Javascript
========

[![Build Status](http://img.shields.io/travis/AppGyver/ag-types/master.svg)](https://travis-ci.org/AppGyver/ag-types)
[![NPM version](http://img.shields.io/npm/v/ag-types.svg)](https://www.npmjs.org/package/ag-types)
[![Dependency Status](http://img.shields.io/david/AppGyver/ag-types.svg)](https://david-dm.org/AppGyver/ag-types)
[![Coverage Status](https://img.shields.io/coveralls/AppGyver/ag-types.svg)](https://coveralls.io/r/AppGyver/ag-types)

You've got incoming JSON data that you'd like to access using Javascript, but you can't be sure its structure matches what you expect. `ag-types` allows you to validate the structure of the input graph before you crash and burn on a `TypeError: 'undefined' is not an object`.


## Installation

    npm install ag-types


## Usage

Examples in Coffeescript.


### Describe your type

    { Object, String, Optional, Map, Any } = require 'ag-types'
    RequestType = Object {
      url: String
      method: String
      params: Optional Map Any
    }

Construct a type validator by simply mirroring the structure of what you want.


### Validate input data against the type

    input = {
      url: 'http://example.com'
    }
    RequestType(input)

Your validator is a function that returns a [data.validation](https://github.com/folktale/data.validation).


### Continue off the validation result

    RequestType(input).fold(
      (errors) -> console.log "This doesn't look like a valid request: ", errors
      (request) -> doRequest request
    )

If an error occurs, the errors object will hold details of what went wrong. Otherwise you're good to go with the data.


## Development

    npm install
    grunt test watch:test --force

