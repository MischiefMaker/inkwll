require "test_helper"

# Browser checks sign up players. These rules keep them from leaving players
# with a known password on the live game again (see docs/deploying.md).
class ProbeSafetyTest < ActiveSupport::TestCase
  WORKFLOWS = Dir[Rails.root.join(".github/workflows/*.{yml,yaml}")]
  PROBE_SCRIPTS = Dir[Rails.root.join("script/probe/*.js")]

  test "no workflow both signs players up and talks to the live game" do
    WORKFLOWS.each do |file|
      text = File.read(file)
      next unless text.include?("/registration")
      assert_not text.include?("INKWLL_SERVER"), "#{File.basename(file)} signs players up, so it must not use the live game's address"
    end
  end

  test "no workflow or browser check writes a password into the file" do
    (WORKFLOWS + PROBE_SCRIPTS).each do |file|
      File.readlines(file).each_with_index do |line, index|
        assert_no_match(/\b(pw|pass|password)\b\s*[:=]\s*['"](?!\$)[^'"]+['"]/i, line,
          "#{File.basename(file)}:#{index + 1} has a password in it; make a random one for each run instead")
      end
    end
  end

  test "the browser checks refuse to run against anything but a local copy" do
    common = File.read(Rails.root.join("script/probe/common.js"))
    assert_includes common, "['127.0.0.1', 'localhost'].includes(host)"
    PROBE_SCRIPTS.excluding(Rails.root.join("script/probe/common.js").to_s).each do |file|
      assert_includes File.read(file), "require('./common')", "#{File.basename(file)} must use common.js"
    end
  end
end
