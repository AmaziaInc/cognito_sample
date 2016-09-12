module LoginHelper
  extend ActiveSupport::Concern

  def login_with_cognito_identity
    cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_REGION'])
    cognitoidentity.get_id(account_id: ENV['AWS_ACCOUNT_ID'],
                           identity_pool_id: ENV['COGNITO_IDENTITY_POOL_ID'],
                           logins: login_params)
  end

  def login_params
    case params[:login_type]
    when 'facebook'
      {'graph.facebook.com' => params[:fb_access_token]}
    when 'user_pools'
      {ENV['COGNITO_USER_POOL_LOGIN_KEY'] => params[:id_token]}
    else
      raise ArgumentError, 'Unsupported login type.'
    end
  end
end
