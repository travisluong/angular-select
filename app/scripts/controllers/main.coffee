'use strict'

angular.module('angularSelectApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      { id: 1, name: 'HTML5 Boilerplate' },
      { id: 2, name: 'AngularJS' },
      { id: 3, name: 'Karma' }
    ]

    # initial select value
    $scope.selectedThing = $scope.awesomeThings[1]
