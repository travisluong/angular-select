'use strict'

angular.module('angularSelectApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      { id: 1, name: 'HTML5 Boilerplate' },
      { id: 2, name: 'AngularJS' },
      { id: 3, name: 'Karma' }
      { id: 4, name: 'Ruby on Rails' }
      { id: 5, name: 'CoffeeScript' }
      { id: 6, name: 'Yeoman' }
      { id: 7, name: 'Grunt' }
      { id: 8, name: 'Bower' }
      { id: 9, name: 'NodeJS' }
      { id: 10, name: 'Travis' }
    ]

    # initial select value (the ng-model for directive)
    $scope.selectedThing = $scope.awesomeThings[1]
