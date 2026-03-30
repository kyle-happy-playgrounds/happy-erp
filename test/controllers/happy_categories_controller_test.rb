require "test_helper"

class HappyCategoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    post user_session_url, params: {user: {email: @user.email, password: '123456'}}
  end

  #  #index
  test "Index page should show all categories" do
    get happy_categories_path
    assert_response :success
    assert response.body.include?("#{HappyCategory.count} in total") ||
    response.body.include?("<b>all #{HappyCategory.count}</b> happy categories")
  end

    test "Index page shows specific category from search" do
    first_cate = HappyCategory.first
        get happy_customers_path, params: {search: {
      category: first_cate.category
    }}
    assert_response :success
    assert_select "td", text: first_cate.id.to_s
  end

    test "should create valid category under company" do
    assert_difference "HappyCategory.count", 1 do
      post happy_categories_path, params: {happy_category: {happy_company_id: 1, happy_profit_center_id:1,
                                          happy_vendor_id: 1, category:"Test Category", user_id: 1, user_id_update: 1,
                                          active:true}}
    end
    assert_equal "Product Category Saved!", flash[:success]
  end

    test "should fail to create invalid customer under company" do
    assert_no_difference "HappyCustomer.count" do
      post happy_categories_path, params: {happy_category: { happy_profit_center_id:1,
                                          happy_vendor_id: 1, category:"Main Parts", user_id: 1, user_id_update: 1,
                                          active:true}}
    end
    assert_response :unprocessable_entity
  end
end
