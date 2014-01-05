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
      scope.viewValue = null
      scope.currentObj = null

      # selectThing is called by the click handler
      scope.selectThing = (obj) ->
        ngModel.$setViewValue(obj)
        scope.viewValue = obj.name
        scope.currentObj = obj

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
        dropdown_ul = dropdown.find('ul')
        dropdown_lis = dropdown_ul.find('li')
        dropdown_active = dropdown_lis.find('a.active')
        text = dropdown_active.text()
        ngModel.$setViewValue(text)
        scope.viewValue = text
        # because selectActive is being called from a keydown handler
        # we must use scope.$apply here to update the scope
        scope.$apply()

      moveActiveDown = ->
        dropdown_ul = dropdown.find('ul')
        dropdown_lis = dropdown_ul.find('li')
        dropdown_first = dropdown_ul.find('li:first-child')
        dropdown_active = dropdown_lis.find('a.active')

        if dropdown_active.length > 0
          next_li = dropdown_active.parent().next()
          next_li.find('a').addClass('active')
          dropdown_active.removeClass('active')

        if dropdown_active.length == 0
          dropdown_first.find('a').addClass('active')

      moveActiveUp = ->
        dropdown_ul = dropdown.find('ul')
        dropdown_lis = dropdown_ul.find('li')
        dropdown_last = dropdown_ul.find('li').last()
        dropdown_active = dropdown_lis.find('a.active')

        if dropdown_active.length > 0
          # no prev() method exists in angular's jqlite, we we must use this
          prev_li = dropdown_active.parent()[0].previousElementSibling
          $(prev_li).find('a').addClass('active')
          dropdown_active.removeClass('active')

        if dropdown_active.length == 0
          dropdown_last.find('a').addClass('active')

      # stops event propagation up to html to prevent dropdown from closing
      input.on 'click', (e) ->
        e.stopPropagation()

      # escape key closes dropdown
      input.on 'keydown', (e) ->
        if e.keyCode == 27 # escape
          dropdown.addClass('angular-selector-hidden')
        if e.keyCode == 40 # down arrow
          moveActiveDown()
        if e.keyCode == 38 # up arrow
          moveActiveUp()
        if e.keyCode == 13 # enter
          scope.selectActive()
          dropdown.addClass('angular-selector-hidden')

      # clicking anywhere outside the dropdown box closes it
      $('html').on 'click', (e) ->
        console.log(e.offsetX)
        console.log(e.offsetY)
        if !dropdown.hasClass('angular-selector-hidden')
          rect = dropdown[0].getBoundingClientRect()
          return if e.offsetY > rect.top && e.offsetY < rect.bottom && e.offsetX > rect.left && e.offsetX < rect.right
          dropdown.addClass('angular-selector-hidden')

      # TODO: refactor this to use ng-show
      # clicking on the select widget shows it
      display.on 'click', (e) ->
        e.stopPropagation()
        dropdown.removeClass('angular-selector-hidden')
        input.focus()

  )
