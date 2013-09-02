# ngTranslator

Translate you [AngularJS](http://angularjs.org/) applications.

## Usage

Configure the language you want:

	app = angular.module('YourModuleName', ['ngTranslator']);

	app.config(['translateConfigProvider', function(translateConfig) {
		translateConfig.setLanguage('de');
	}]);

Load the translations:

	app.run(['$http', 'translateData', function(http, translateData) {
		http.get('translation.json').success(function(translations) {
			translateData.setTranslations(translations);
		});
	}]);

Use it:

	<!-- simple content -->
	<p translate>first_paragraph</p>

	<!-- overwrite the language setting -->
	<p translate translate-lang="en">first_paragraph</p>

	<!-- translate an attribute -->
	<input type="text" translate-attribute="attributeName|translationKey">

	<!-- shortcut for placeholder attribute of input -->
	<input type="text" translate-placeholder="translationKey">

	<!-- shortcut for value attribute of input -->
	<input type="text" translate-value="translationKey">


**Notes:** 

* If a key or a language are not found an (configurable) error message will be displayed where the translation should be.
* If translation data is misconfigured for a key and (configurable) error message will be displayed where the translation should be.

## Translation data format

	{
		"de": {
			"first_paragraph": "Erster Absatz",
			"user_count": {
				"":"Kein Benutzer online",
				"0":"Kein Benutzer online",
				"1": "Ein Benutzer online",
				"2": "Zwei Benutzer online",
				"defaultTranslation": "{{ count }} Benutzer online"
			}
		},
		"en": {
			"first_paragraph": "First paragraph",
			"user_count": {
				"":"No User online",
				"0":"No User online",
				"1": "One User online",
				"2": "Two User online",
				"defaultTranslation": "{{ count }} User online"
			}
		}
	}

**Notes:**

* Translations could contain Angular expressions (e.g.: `{{ count }}`). These expression are watched and updated if they change
on the scope
* If you have a translation with multiple case it **must** have the field `defaultTranslation`. Only expressions from the
`defaultTranslation` field are watched.

