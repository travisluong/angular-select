'use strict'

describe 'Directive: selector', () ->

  # load the directive's module
  beforeEach module 'angularSelectApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<selector></selector>'
    element = $compile(element) scope
    expect(element.text()).toBe ''
