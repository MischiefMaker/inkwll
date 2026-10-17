require "test_helper"

class BirthdaysTest < ActionDispatch::IntegrationTest
  test "lists characters with a birthday this game month, by day" do
    today = IcClock.today
    field = profile_fields(:birthday)
    ProfileValue.create!(character: characters(:sable), profile_field: field, value: today.change(year: today.year - 20, day: 1).iso8601)
    ProfileValue.create!(character: characters(:wren), profile_field: field, value: (today.change(day: 1) - 2.months).change(year: today.year - 30).iso8601)

    get birthdays_path
    assert_response :success
    assert_select ".birthdays__name", text: "Sable"
    assert_select ".birthdays__name", text: "Wren", count: 0
    assert_select ".birthdays__age", text: /20/
  end

  test "there's no birthdays page without a Birthday field" do
    profile_fields(:birthday).destroy
    get birthdays_path
    assert_response :not_found
  end
end
