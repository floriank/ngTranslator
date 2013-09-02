app = angular.module 'TranslateTest', ['ngTranslator']

app.config ['translateConfigProvider', (translateConfig) ->
	translateConfig.setLanguage 'de'
]

app.run ['$http', 'translateData', (http, translateData) ->
	http.get('translation.json').success (translations) ->
		translateData.setTranslations translations
]

app.controller 'TestController', ['$scope', (scope) ->
	#scope.$watch 'count', () ->
	#	counter = parseInt(scope.count)

]