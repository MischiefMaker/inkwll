require "test_helper"

class GithubActionsTest < ActiveSupport::TestCase
  test "reads the versions marked ready, newest first" do
    yaml = <<~YAML
      - version: v1.1
        commit: #{"b" * 40}
        date: 2026-10-20
        notes: |
          Newer things.
      - version: v1.0
        commit: #{"a" * 40}
        date: 2026-10-16
        notes: First version.
    YAML
    versions = GithubActions.parse_versions(yaml)
    assert_equal %w[ v1.1 v1.0 ], versions.map(&:tag)
    assert_equal Date.new(2026, 10, 16), versions.last.published_at
    assert_match "Newer things", versions.first.notes
  end

  test "the real versions file can be read" do
    assert_nothing_raised { GithubActions.parse_versions(Rails.root.join("config/versions.yml").read) }
  end

  test "a broken versions file is reported, not crashed on" do
    assert_raises(GithubActions::Error) { GithubActions.parse_versions("- version: [") }
    assert_empty GithubActions.parse_versions("")
  end
end
