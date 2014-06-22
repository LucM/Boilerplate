angular.module('app')
.config ($urlRouterProvider, $stateProvider) ->

  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'app',
      url: '/'
      templateUrl: 'tpl-layout.html'