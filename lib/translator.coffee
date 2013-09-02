do (angular) ->
	"use strict"
	angular.module('ngTranslator', [])
	.directive('translate', ['translator', (translator) ->
		restrict: 'AC'
		link: (scope, element, attrs) ->
			key = element[0].innerText
			lang = if attrs.lang? then attrs.lang else null
			translator.translate(key, lang).then (translation) ->
				element[0].innerText = translation
			, (error) ->
				element[0].innerText = error
			return
	])
	.service('translator', ['$q', 'translateConfig', 'translateData', (q, translateConfig, translateData) ->
		@translate = (key, lang = null) ->
			result = q.defer()
			lang = if lang is null then translateConfig.getLanguage() else lang
			translateData.getTranslation(lang).then (translation) ->
				result.reject translateConfig.getKeyError().replace '@@', key unless key? and translation[key]?
				result.resolve translation[key]
			, (errorLang) ->
				result.reject translateConfig.getLangError().replace '@@', errorLang
			result.promise
	])
	.provider('translateConfig', [() ->
		@defaultLanguage = 'en'
		@languageErrorMessage = 'Not translation for language "@@"'
		@keyErrorMessage = 'No translation for key "@@"'
		@$get = () ->
			lang = @defaultLanguage
			langError = @languageErrorMessage
			keyError = @keyErrorMessage
			getLanguage: () ->
				lang
			getLangError: () ->
				langError
			getKeyError: () ->
				keyError
		@setLanguage = (lang) ->
			@defaultLanguage = lang
			return
		@setLanguageError = (error) ->
			@languageErrorMessage = error
			return
		@setKeyError = (error) ->
			@keyErrorMessage = error
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
			translation.promise				
			
	])
	return