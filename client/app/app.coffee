'use strict'

angular.module('mafiaOnlineApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ui.bootstrap',
  'ui.router'
])
  .config (['$stateProvider', '$urlRouterProvider', '$locationProvider', '$httpProvider', ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
    $urlRouterProvider
    .otherwise('/')

    $locationProvider.html5Mode true
    $httpProvider.interceptors.push 'authInterceptor'
  ])
  .factory('authInterceptor', ['$rootScope', '$q', '$cookieStore', '$location', ($rootScope, $q, $cookieStore, $location) ->
    # Add authorization token to headers
    request: (config) ->
      config.headers = config.headers or {}
      config.headers.Authorization = 'Bearer ' + $cookieStore.get('token')  if $cookieStore.get('token')
      config

    # Intercept 401s and redirect you to login
    responseError: (response) ->
      if response.status is 401
        $location.path '/login'
        # remove any stale tokens
        $cookieStore.remove 'token'
        $q.reject response
      else
        $q.reject response
  ])
  .run (['$rootScope', '$location', ($rootScope, $location) ->
    # Redirect to login if route requires auth and you're not logged in
  ])