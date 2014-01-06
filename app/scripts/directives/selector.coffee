'use strict'

angular.module('angularSelectApp')
  .directive('selector', () ->
    templateUrl: 'views/selector.html'
    restrict: 'E'
    require: 'ngModel'
    replace: true
    scope:
      collection: "="
      display: "@"
      labelProp: "@"
      valueProp: "@"
    link: (scope, element, attrs, ngModel) ->
      return if !ngModel
      scope.currentObj = null
      scope.hoverObj = null
      scope.dropdownHidden = true
      hoverIdx = -1

      # selectThing is called by the click handler
      scope.selectThing = (obj) ->
        ngModel.$setViewValue(obj)
        scope.currentObj = obj
        scope.hoverObj = obj

      # watching for modelValue to change
      # used to show the initial object name on load
      scope.$watch ngModel.$modelValue, ->
        scope.viewValue = ngModel.$modelValue
        angular.forEach scope.collection, (obj) ->
          if obj[attrs.valueProp] == ngModel.$modelValue
            scope.viewValue = obj[attrs.labelProp]
            scope.currentObj = obj

      # get jqlite elements
      dropdown = element.find('.angular-selector-dropdown')
      input = dropdown.find('input')
      display = element.find('.angular-selector-view-value')

      # select active is called by the keypress handler
      scope.selectActive = ->
        scope.currentObj = scope.hoverObj
        ngModel.$setViewValue(scope.hoverObj)
        # because selectActive is being called from a keydown handler
        # we must use scope.$apply here to update the scope
        scope.$apply()

      moveActiveDown = ->
        if hoverIdx >= scope.collection.length - 1
          hoverIdx = -1
        else
          hoverIdx++
        scope.hoverObj = scope.collection[hoverIdx]
        scope.$apply()

      moveActiveUp = ->
        if hoverIdx < 0
          hoverIdx = scope.collection.length - 1
        else
          hoverIdx--
        scope.hoverObj = scope.collection[hoverIdx]
        scope.$apply()

      # stops event propagation up to html to prevent dropdown from closing
      input.on 'click', (e) ->
        e.stopPropagation()

      # escape key closes dropdown
      input.on 'keydown', (e) ->
        if e.keyCode == 27 # escape
          scope.dropdownHidden = false
        if e.keyCode == 40 # down arrow
          moveActiveDown()
        if e.keyCode == 38 # up arrow
          moveActiveUp()
        if e.keyCode == 13 # enter
          scope.selectActive()
          scope.dropdownHidden = true
        scope.$apply()

      # clicking anywhere outside the dropdown box closes it
      $('html').on 'click', (e) ->
        if scope.dropdownHidden == false
          rect = dropdown[0].getBoundingClientRect()
          return if e.offsetY > rect.top && e.offsetY < rect.bottom && e.offsetX > rect.left && e.offsetX < rect.right
          scope.dropdownHidden = true
          scope.$apply()

      # TODO: refactor this to use ng-show
      # clicking on the select widget shows it
      display.on 'click', (e) ->
        e.stopPropagation()
        scope.dropdownHidden = false
        scope.$apply()
        input.focus()

  )
