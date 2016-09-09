# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class window.CognitoWrapper
  constructor: ->
    @isReady = false

  setup: (@appMetaDataId) ->
    @appMetaData = $(@appMetaDataId)

    # Initialize the Amazon Cognito credentials provider
    AWS.config.region = @appMetaData.data('aws-region') # Region
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: @appMetaData.data('cognito-identity-pool-id'),
    })

    # Initialize the Amazon Cognito credentials provider
    AWSCognito.config.region = @appMetaData.data('aws-region') # Region
    AWSCognito.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: @appMetaData.data('cognito-identity-pool-id'),
    })
    @isReady = true

  _getUserPool = () ->
    data = {
      UserPoolId: @appMetaData.data('cognito-user-pool-id'),
      ClientId: @appMetaData.data('cognito-client-id'),
      Paranoia: 7
    }
    new AWSCognito.CognitoIdentityServiceProvider.CognitoUserPool(data)

  signUp: (username, password, attributeList, successCallback, failureCallback) ->
    userPool = _getUserPool.call @
    userPool.signUp(username, password, attributeList, null,
      (err, result) ->
        if err
          failureCallback(err)
        else
          successCallback(result)
    )

  confirmRegistration: (username, activationCode, successCallback, failureCallback) ->
    userPool = _getUserPool.call @
    userData = {
      Username: username,
      Pool: userPool
    };

    cognitoUser = new AWSCognito.CognitoIdentityServiceProvider.CognitoUser(userData);
    cognitoUser.confirmRegistration(activationCode, true,
      (err, result) ->
        if err
          failureCallback(err)
        else
          successCallback(result)
    )


showMessage = (targetNode, message_text, message_class)->
  messageAlert = targetNode
  messageAlert.text(message_text)
  messageAlert.addClass(message_class)
  messageAlert.show()
  setTimeout(->
    messageAlert.fadeOut()
    messageAlert.removeClass(message_class)
  , 5000)

signUp = (e)->
  e.preventDefault()
  if cognitoWrapper.isReady
    # Use email as username.
    username = $('#email').val()
    password = $('#password').val()
    dataEmail = { Name: 'email', Value: username }

    attributeEmail = new AWSCognito.CognitoIdentityServiceProvider.CognitoUserAttribute(dataEmail)
    attributeList = []
    attributeList.push(attributeEmail)

    signUpSuccessHandler = (email)->
      $('.form-signup').fadeOut()
      $('.form-activation').fadeIn()
      $('#activationEmail').val(email)

    cognitoWrapper.signUp(username, password, attributeList,
      (result)=>
        signUpSuccessHandler(username)
      ,
      (error)=>
        if error.name == 'UsernameExistsException'
          message = 'This email address is already exists. Please enter activation code.'
          showMessage($(".form-activation .message"), message, "alert-success")
          signUpSuccessHandler(username)
          return

        showMessage($(".form-signup .message"), error, "alert-danger")
    )

activation = (e)->
  e.preventDefault()
  if cognitoWrapper.isReady
    username = $('#activationEmail').val()
    activationCode = $('#activationCode').val()

    activationSuccessHandler = (idToken, accessToken)->
      $.post("/users",
        {
          'id_token': idToken,
          'access_token': accessToken
        }, (data) ->
          $('.form-activation').fadeOut()
          $('.success-box').fadeIn()
        , 'json'
      )

    cognitoWrapper.confirmRegistration(username, activationCode,
      (result) ->
        activationSuccessHandler(
          result.getIdToken().getJwtToken(),
          result.getAccessToken().getJwtToken())
      ,
      (error) ->
        showMessage($(".form-activation .message"), error, "alert-danger")
    )

cognitoWrapper = new CognitoWrapper()
$(document).on('click', '#user_add_btn', signUp)
$(document).on('click', '#user_activation_btn', activation)

$(document).ready ->
  cognitoWrapper.setup('meta[name=AppInfo]')

