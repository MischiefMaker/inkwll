require "test_helper"

class Admin::WorldImportsControllerTest < ActionDispatch::IntegrationTest
  def pack_file
    text = { format: WorldPack::FORMAT, name: "Tiny World",
      areas: [ { name: "Tiny Area", entrance: "Tiny Place" } ],
      places: [ { name: "Tiny Place", area: "Tiny Area" } ] }.to_json
    Rack::Test::UploadedFile.new(StringIO.new(text), "application/json", original_filename: "tiny.world.json")
  end

  test "only the Founder can import a world" do
    sign_in_as(accounts(:wellkeeper))
    get admin_world_import_path
    assert_redirected_to root_path
    post admin_world_import_path, params: { pack: pack_file }
    assert_not Area.exists?(name: "Tiny Area")
  end

  test "the Founder sees what will change, then imports it" do
    sign_in_as(accounts(:founder))
    get admin_world_import_path
    assert_response :success

    post admin_world_import_path, params: { pack: pack_file }
    assert_response :redirect, "Turbo only follows a form that redirects"
    follow_redirect!
    assert_response :success
    assert_match "Tiny Place", response.body
    assert_not Area.exists?(name: "Tiny Area"), "nothing changes until Import is pressed"

    upload = css_select("form[action='#{apply_admin_world_import_path}'] input[name=upload]").first["value"]
    post apply_admin_world_import_path, params: { upload: upload }
    assert_redirected_to root_path
    assert Area.exists?(name: "Tiny Area")
  end

  test "a file that isn't a world pack is turned away" do
    sign_in_as(accounts(:founder))
    post admin_world_import_path, params: { pack: Rack::Test::UploadedFile.new(file_fixture("pixel.png"), "image/png") }
    assert_redirected_to admin_world_import_path
  end
end
