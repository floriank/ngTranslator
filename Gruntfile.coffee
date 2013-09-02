tasks = ['contrib-coffee', 'contrib-watch']

module.exports = (grunt) ->

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json' 
		coffee:
			lib:
				src: ['./lib/*.coffee']
				dest: './test/translator.js'
			test:
				src: ['./test/*.coffee']
				dest: './test/test.js'
		watch:
			lib:
				files: ['./lib/*.coffee']
				tasks: ['coffee:lib']
			test:
				files: ['./test/*.coffee']
				tasks: ['coffee:test']


	grunt.loadNpmTasks "grunt-#{task}" for task in tasks

	grunt.registerTask "default", ['coffee:lib', 'coffee:test']
