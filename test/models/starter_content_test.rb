require "test_helper"

class StarterContentTest < ActiveSupport::TestCase
  test "a new game gets starter Boons and Banes and profile fields, once" do
    ProfileValue.delete_all
    ProfileField.delete_all
    Soul::Bnb.delete_all

    StarterContent.install!
    assert_equal 6, Soul::Bnb.boon.count
    assert_equal 6, Soul::Bnb.bane.count
    assert ProfileField.find_by(name: "Background").required?

    assert_no_difference -> { Soul::Bnb.count + ProfileField.count } do
      StarterContent.install!
    end
  end

  test "a game that already set up SOUL keeps its own Aspects" do
    assert_no_difference -> { Soul::Aspect.count } do
      StarterContent.install_soul!
    end
  end
end
