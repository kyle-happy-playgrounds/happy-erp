require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

    test "should get index page after valid login" do
    get root_url
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
    assert_redirected_to root_url
    follow_redirect!
    assert_match "Signed in successfully.", response.body
  end

  test "should redirect to sign-in page after invalid login" do
    get root_url
    post user_session_url, params: {user: {email: "wrongemail@example.com", password: ""}}
    assert_response :unprocessable_entity
    assert_match "Invalid email or password.", response.body
  end


end
