tasks = ['contrib-coffee', 'contrib-watch', 'devserver', 'contrib-copy', 'contrib-uglify']

module.exports = (grunt) ->

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		coffee:
			lib:
				options:
					bare: yes
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
		copy:
			angular:
				expand: yes
				cwd: './vendor/angular/'
				src: 'angular.*'
				dest: './test/'
				flatten: yes
			bootstrap:
				expand: yes
				cwd: './vendor/bootstrap/dist/'
				src: '**'
				dest: './test/bootstrap'

		devserver:
			options:
				base: './test'
				port: 8000

		uglify:
			compile:
				files:
					'./dist/translator.min.js':'./test/translator.js'


	grunt.loadNpmTasks "grunt-#{task}" for task in tasks
	grunt.registerTask "vendor", ["copy:angular", "copy:bootstrap"]
	grunt.registerTask "default", ['vendor', 'coffee:lib', 'coffee:test']
	grunt.registerTask "server", ['devserver']
