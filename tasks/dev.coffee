module.exports = (grunt) ->
  grunt.registerTask 'dev', [
    'coffeelint'
    'test'
    'watch:test'
  ]
