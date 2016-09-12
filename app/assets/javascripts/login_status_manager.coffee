class window.LoginStatusManager
  constructor: (@loginCookieName) ->

  isLoggedIn: () ->
    return Cookies.get(@loginCookieName) != undefined

  login: (loginId) ->
    Cookies.set(@loginCookieName, loginId, {expires: 30})

  logout: ->
    Cookies.remove(@loginCookieName)


window.loginStatusManager = new LoginStatusManager('cognito_sample_id')
