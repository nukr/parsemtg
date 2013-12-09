module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    compass:
      dist:
        options:
          sassDir: 'public/sass'
          cssDir: 'public/stylesheets'
    # nodemon:
    #   dev:
    #     options:
    #       file: 'app.js'
    mochaTest:
      test:
        src:
          ['test/**/*.js']
        options:
          reporter: 'spec'
          timeout: 1000
    coffee:
      compile:
        files:
          'routes/index.js': 'routes/index.coffee'
          'public/javascripts/main.js': 'public/javascripts/main.coffee'
          'test/tests.js': 'test/tests.coffee'
    # concurrent:
    #   dev:
    #     tasks: ['watch', 'nodemon']
    #     options:
    #       logConcurrentOutput: true
    # 2013-11-25 不能動 nodemon 0.7.10
    # 之後在看看更新後能不能動
    watch:
      coffeeCompile:
        files: ['**/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
      mochaTest:
        files: ['routes/**/*.coffee', 'test/**/*.coffee']
        tasks: ['mochaTest']
        options:
          spawn: true
      compass:
        files: ['public/sass/*.sass']
        tasks: ['compass']
        options:
          spawn: false
          livereload: true

  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-compass')
  grunt.registerTask('default', ['compass', 'mochaTest', 'coffee', 'watch', ])
