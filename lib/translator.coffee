###
Copyright (c) 2013 Philipp Klose <me@thehippo.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
###

do (angular) ->
	"use strict"
	angular.module('ngTranslator', [])
	.directive('translate', ['translateProcessor', (translateProcessor) ->
		restrict: 'AC'
		link: (scope, element, attrs) ->
			key = element[0].innerText
			lang = if attrs.translateLang? then attrs.translateLang else null
			translateProcessor.process key, lang, scope, (content) ->
				element[0].innerText = content
				return
			return
	])
	.directive('translateAttribute', ['translateProcessor', (translateProcessor) ->
		restrict: 'AC'
		link: (scope, element, attrs) ->
			attributeName = attrs.translateAttribute
			key = attrs[attributeName]
			lang = if attrs.translateLang? then attrs.translateLang else null
			translateProcessor.process key, lang, scope, (content) ->
				element[0].setAttribute attributeName, content
				return
			return
	])
	.directive('translatePlaceholder', ['translateProcessor', (translateProcessor) ->
		restrict: 'AC'
		link: (scope, element, attrs) ->
			key = attrs.translatePlaceholder
			lang = if attrs.translateLang? then attrs.translateLang else null
			translateProcessor.process key, lang, scope, (content) ->
				element[0].setAttribute 'placeholder', content
				return
			return	
	])
	.directive('translateValue', ['translateProcessor', (translateProcessor) ->
		restrict: 'AC'
		link: (scope, element, attrs) ->
			key = attrs.translateValue
			lang = if attrs.translateLang? then attrs.translateLang else null
			translateProcessor.process key, lang, scope, (content) ->
				element[0].setAttribute 'value', content
				return
			return
	])
	.service('translateProcessor', ['$interpolate', 'translator', 'translateConfig', (interpolate, translator, translateConfig) ->
		@process = (key, lang, scope, callback) ->
			translator.translate(key, lang).then (translation) ->
				matchReg = /{{([^}]+)}}/g
				switch typeof translation
					when "string"
						interpolateFunction = interpolate(translation)
						watcher = translation.match matchReg
					when "object"
						if translation.constructor == Object
							if translation.defaultTranslation?
								interpolateFunction = interpolate(translation.defaultTranslation)
								watcher = translation.defaultTranslation.match matchReg
							else
								callback translateConfig.getDefaultError().replace '@@', key
								return
						else
							callback translateConfig.getConfigError().replace '@@', key
							return
					else
						callback translateConfig.getConfigError().replace '@@', key
						return

				if watcher
					for match in watcher
						expr = match[2..match.length-3]
						scope.$watch expr, (newVal) ->
							if typeof translation is "object"
								if translation[newVal]?
									interpolateFunction = interpolate(translation[newVal])
								else
									interpolateFunction = interpolate(translation.defaultTranslation)
							callback interpolateFunction(scope)
							return
						return
				callback interpolateFunction(scope)
				return
			, (error) ->
				callback error
				return
			return
		return
	])
	.service('translator', ['$q', 'translateConfig', 'translateData', (q, translateConfig, translateData) ->
		@translate = (key, lang) ->
			result = q.defer()
			lang = if lang is null then translateConfig.getLanguage() else lang
			translateData.getTranslation(lang).then (translation) ->
				result.reject translateConfig.getKeyError().replace '@@', key unless key? and translation[key]?
				result.resolve translation[key]
				return
			, (errorLang) ->
				result.reject translateConfig.getLangError().replace '@@', errorLang
				return
			result.promise
		return
	])
	.provider('translateConfig', [() ->
		@defaultLanguage = 'en'
		@languageError = 'Not translation for language "@@"'
		@keyError = 'No translation for key "@@"'
		@badConfigError = 'Missconfigured translation for key "@@"'
		@defaultMissingError = 'No default translation configured for "@@"'
		@$get = () ->
			lang = @defaultLanguage
			langError = @languageError
			keyError = @keyError
			defaultError = @defaultMissingError
			badConfigError = @badConfigError
			getLanguage: () ->
				lang
			getLangError: () ->
				langError
			getKeyError: () ->
				keyError
			getDefaultError: () ->
				defaultError
			getConfigError: () ->
				badConfigError
		@setLanguage = (lang) ->
			@defaultLanguage = lang
			return
		@setLanguageError = (error) ->
			@languageError = error
			return
		@setKeyError = (error) ->
			@keyError = error
			return
		@setBadConfigError = (error) ->
			@badConfigError = error
			return
		@setDefaultMissingError = (error) ->
			@defaultMissingError = error
			return
		return
	])
	.factory('translateData', ['$q', (q) ->
		done = q.defer()

		setTranslations: (obj) ->
			translations = {}
			for lang, translation of obj
				translations[lang] = translation
			done.resolve translations
			return
		getTranslation: (lang) ->
			translation = q.defer()
			done.promise.then (translations) ->
				translation.reject lang unless lang? and translations[lang]?
				translation.resolve translations[lang]
				return
			translation.promise				
	])
	return