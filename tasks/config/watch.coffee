module.exports =
  test:
    files: [
      '<%= files.src %>'
      '<%= files.test %>'
    ]
    tasks: [
      'coffeelint'
      'test'
    ]