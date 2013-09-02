do (angular) ->
	"use strict"
	angular.module('ngTranslator', [])
	.directive('translate', ['$interpolate', 'translator', 'translateConfig', (interpolate, translator, translateConfig) ->
		restrict: 'AC'
		link: (scope, element, attrs) ->
			key = element[0].innerText
			lang = if attrs.translateLang? then attrs.translateLang else null
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
								element[0].innerText = translateConfig.getDefaultError().replace '@@', key
								return
						else
							element[0].innerText = translateConfig.getConfigError().replace '@@', key
							return
					else
						element[0].innerText = translateConfig.getConfigError().replace '@@', key
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
							element[0].innerText = interpolateFunction(scope)
							return
						return
				element[0].innerText = interpolateFunction(scope)
				return
			, (error) ->
				element[0].innerText = error
				return
			return
	])
	#.service(''
	#)
	.service('translator', ['$q', 'translateConfig', 'translateData', (q, translateConfig, translateData) ->
		@translate = (key, lang = null) ->
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
			translation.promise				
			
	])
	return