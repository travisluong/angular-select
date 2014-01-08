'use strict'

angular.module('angularSelectApp')
  .directive('selector', ['$filter', '$interval', '$timeout', ($filter, $interval, $timeout) ->
    templateUrl: '/views/selector.html'
    restrict: 'E'
    require: 'ngModel'
    replace: true
    scope:
      collection: "="
      display: "@"
      labelProp: "@"
      valueProp: "@"
      limit: "@"
      type: "@"
    link: (scope, element, attrs, ngModel) ->
      return if !ngModel
      scope.currentObj = {}
      scope.hoverObj = null
      scope.dropdownHidden = true
      hoverIdx = -1
      scope.stop = undefined

      # this is for the up and down keys
      # we don't want to key through the entire collection,
      # just the filtered objects
      scope.getData = (collection, search) ->
        scope.queryData = $filter('filter')(collection, search)
        scope.hoverObj = scope.queryData[0]

      # selectThing is called by the click handler
      scope.selectThing = (obj) ->
        ngModel.$setViewValue(obj)
        scope.currentObj = obj
        scope.hoverObj = obj

      # watching for modelValue to change
      # used to show the initial object name on load
      # otherwise the initial value in view will be blank
      scope.$watch ngModel.$modelValue, ->
        angular.forEach scope.collection, (obj) ->
          if scope.type == "string"
            if ngModel.$modelValue && obj[scope.valueProp] == ngModel.$modelValue
              scope.currentObj = obj
          else if ngModel.$modelValue && obj[scope.valueProp] == ngModel.$modelValue[scope.valueProp]
            scope.currentObj = obj

      # part of the solution to initial value not showing
      scope.stopInterval = ->
        if angular.isDefined(scope.stop)
          $interval.cancel(scope.stop)
          scope.stop = undefined

      # this is to fix the problem of initial value not showing
      # use an interval to continuously check the model
      # when there is a change, we update the currentObj
      # stop the interval after we update the currentObj
      scope.stop = $interval( (->
        angular.forEach scope.collection, (obj) ->
          if scope.type == "string"
            if ngModel.$modelValue && obj[scope.valueProp] == ngModel.$modelValue
              scope.currentObj = obj
          else if ngModel.$modelValue && obj[scope.valueProp] == ngModel.$modelValue[scope.valueProp]
            scope.currentObj = obj
            scope.stopInterval()
        ), 100 )

      # stop the interval after 5 seconds
      $timeout( (->
        scope.stopInterval()
        ), 5000
      )

      # set the query data as soon as collection is loaded
      # so we can use it in our keypress handlers
      scope.$watch scope.collection, ->
        scope.queryData = $filter('filter')(scope.collection, null)

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

      moveActiveDown = ->
        if hoverIdx < scope.queryData.length - 1 && hoverIdx < scope.limit - 1
          hoverIdx++
        scope.hoverObj = scope.queryData[hoverIdx]

      moveActiveUp = ->
        if hoverIdx > 0
          hoverIdx--
        scope.hoverObj = scope.queryData[hoverIdx]

      # stops event propagation up to html to prevent dropdown from closing
      input.on 'click', (e) ->
        e.stopPropagation()

      # escape key closes dropdown
      scope.keydownHandler = ->
        if event.keyCode == 27 # escape
          scope.dropdownHidden = true
        if event.keyCode == 40 # down arrow
          moveActiveDown()
        if event.keyCode == 38 # up arrow
          moveActiveUp()
        if event.keyCode == 13 # enter
          scope.selectActive()
          scope.dropdownHidden = true

      # clicking anywhere outside the dropdown box closes it
      $('html').on 'click', (e) ->
        if scope.dropdownHidden == false
          rect = dropdown[0].getBoundingClientRect()
          return if e.offsetY > rect.top && e.offsetY < rect.bottom && e.offsetX > rect.left && e.offsetX < rect.right
          scope.dropdownHidden = true
          # we need to use $apply because this isnt an angular event
          scope.$apply()

      # clicking on the select widget shows it
      # we must use dom manipulation because
      # angular cannot call input.focus() or other dom stuff inside ng-click handler
      display.on 'click', (e) ->
        e.stopPropagation()
        scope.dropdownHidden = false
        scope.$apply()
        input.focus()

  ])
