require "test_helper"

class NotionDatabaseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get notion_database_index_url
    assert_response :success
  end
end
