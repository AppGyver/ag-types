assign = require 'lodash-node/modern/objects/assign'
{Success, Failure} = require 'data.validation'

module.exports = types = assign {
    data:
      Validation: {Success, Failure}
    projections: require './types/projections'
    recursive: require './types/recursive'
    Optional: require './types/optional'
    List: require './types/list'
    json: require './types/json'
    Try: require './types/try'
  },
  require './types/primitives'
  require './types/objects'
  require './types/composites'
