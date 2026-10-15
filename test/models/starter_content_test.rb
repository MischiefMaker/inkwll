require "test_helper"

class StarterContentTest < ActiveSupport::TestCase
  test "a new game gets starter Boons and Banes and profile fields, once" do
    ProfileValue.delete_all
    ProfileField.delete_all
    Soul::Bnb.delete_all
    Soul::RatingGuide.delete_all

    StarterContent.install!
    assert_equal 6, Soul::Bnb.boon.count
    assert_equal 6, Soul::Bnb.bane.count
    assert ProfileField.find_by(name: "Background").required?
    assert Soul::RatingGuide.exists?(name: "Superhuman")

    assert_no_difference -> { Soul::Bnb.count + ProfileField.count } do
      StarterContent.install!
    end
  end

  test "a game that already set up SOUL keeps its own Aspects" do
    assert_no_difference -> { Soul::Aspect.count } do
      StarterContent.install_soul!
    end
  end

  test "the starter Boons and Banes come back only when no active ones are left" do
    Soul::Bnb.delete_all
    Soul::Bnb.create!(kind: "boon", name: "Mine", description: "x")
    StarterContent.restore_bnbs!
    assert_equal 1, Soul::Bnb.count, "a game with its own active ones is left alone"

    Soul::Bnb.delete_all
    StarterContent.restore_bnbs!
    assert_equal 6, Soul::Bnb.where(kind: "boon").count
    assert_equal 6, Soul::Bnb.where(kind: "bane").count
    StarterContent.restore_bnbs!
    assert_equal 12, Soul::Bnb.count, "and not twice"
  end
end
