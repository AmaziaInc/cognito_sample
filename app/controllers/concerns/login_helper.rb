module LoginHelper
  extend ActiveSupport::Concern

  def login(id_token)
    cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_REGION'])
    logins = {ENV['COGNITO_USER_POOL_LOGIN_KEY'] => id_token}
    cognitoidentity.get_id(account_id: ENV['AWS_ACCOUNT_ID'],
                           identity_pool_id: ENV['COGNITO_IDENTITY_POOL_ID'],
                           logins: logins)
  end
end
