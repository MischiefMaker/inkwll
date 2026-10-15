module SessionTestHelper
  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[Authentication::LOGIN_COOKIE] = Current.session.id
      cookies["inkwll_login"] = cookie_jar[Authentication::LOGIN_COOKIE]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("inkwll_login")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
