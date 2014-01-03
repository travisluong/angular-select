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
    link: (scope, element, attrs, ngModel) ->
      return if !ngModel

      scope.selectThing = (obj) ->
        ngModel.$setViewValue(obj)
        scope.viewValue = ngModel.$viewValue

      scope.$watch ngModel.$modelValue, ->
        scope.viewValue = ngModel.$modelValue

      dropdown = element.find('.angular-selector-dropdown')

      $('html').on 'click', (e) ->
        if !dropdown.hasClass('angular-selector-hidden')
          top = dropdown[0].getBoundingClientRect().top
          right = dropdown[0].getBoundingClientRect().right
          bottom = dropdown[0].getBoundingClientRect().bottom
          left = dropdown[0].getBoundingClientRect().left
          console.log(e.offsetX)
          console.log(e.offsetY)
          return if e.offsetY > top && e.offsetY < bottom && e.offsetX > left && e.offsetX < right
          dropdown.addClass('angular-selector-hidden')

      element.find('.angular-selector-display').on 'click', (e) ->
        e.stopPropagation()
        dropdown.toggleClass('angular-selector-hidden')
        console.log(dropdown[0].getBoundingClientRect().top)
        console.log(dropdown[0].getBoundingClientRect().left)
        console.log(dropdown[0].getBoundingClientRect().right)
        console.log(dropdown[0].getBoundingClientRect().bottom)

  )
