assign = require 'lodash-node/modern/objects/assign'

module.exports = types = assign {
    projections: require './types/projections'
    recursive: require './types/recursive'
    Optional: require './types/optional'
    List: require './types/list'
  },
  require './types/primitives'
  require './types/objects'
  require './types/composites'
