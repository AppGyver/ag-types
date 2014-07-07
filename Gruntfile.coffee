module.exports = (grunt) ->
  baseConfig = {
    dir:
      src: 'src'
      tasks: 'tasks'
      test: 'test'
    files:
      src: '<%= dir.src %>/**/*.coffee'
      test: '<%= dir.test %>/**/*Spec.coffee'
  }

  require('load-grunt-config')(grunt, {
    configPath: "#{__dirname}/tasks/config"
    config: baseConfig
  })
  require('load-grunt-tasks')(grunt)

  grunt.loadTasks baseConfig.dir.tasks
  