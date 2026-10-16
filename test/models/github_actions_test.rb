require "test_helper"

class GithubActionsTest < ActiveSupport::TestCase
  test "reads the versions marked ready from config/versions.yml" do
    versions = GithubActions.parse_versions(Rails.root.join("config/versions.yml").read)
    assert_equal "v1.0", versions.last.tag
    assert_kind_of Date, versions.last.published_at
    assert_match "Wells page", versions.last.notes
  end

  test "a broken versions file is reported, not crashed on" do
    assert_raises(GithubActions::Error) { GithubActions.parse_versions("- version: [") }
    assert_empty GithubActions.parse_versions("")
  end
end
