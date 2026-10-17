require "test_helper"

class EventsTest < ActionDispatch::IntegrationTest
  def place
    Room.listed.order(:id).first
  end

  def make_event(starts_at: 2.days.from_now, host: characters(:wren))
    Event.create!(title: "Midwinter Ball", room: place, starts_at: starts_at, host: host, created_by: host.account)
  end

  test "a player hosts an event in their own time zone, and guests can read the calendar" do
    sign_in_as(accounts(:alice))
    post events_path, params: { event: { title: "Midwinter Ball", room_id: place.id, starts_at: "2099-12-21T20:00", host_id: characters(:wren).id }, utc_offset: "-60" }
    event = Event.last
    assert_equal characters(:wren), event.host
    assert_equal Time.utc(2099, 12, 21, 19, 0), event.starts_at
    sign_out

    get events_path
    assert_response :success
    assert_select ".event-card__title", text: "Midwinter Ball"
    get event_path(event)
    assert_response :success
  end

  test "players without an approved character can't host, and only the host or staff change an event" do
    event = make_event
    sign_in_as(accounts(:bob))
    patch event_path(event), params: { event: { title: "Taken over" } }
    assert_equal "Midwinter Ball", event.reload.title
    delete event_path(event)
    assert_not event.reload.cancelled?
    sign_out

    sign_in_as(accounts(:builder))
    delete event_path(event)
    assert event.reload.cancelled?
  end

  test "characters sign up and drop out, but not someone else's" do
    event = make_event
    sign_in_as(accounts(:bob))
    post event_signups_path(event), params: { character_id: characters(:wren).id }
    assert_equal 0, event.signups.count
    post event_signups_path(event), params: { character_id: characters(:sable).id }
    assert_equal [ characters(:sable) ], event.characters.to_a
    sign_out

    sign_in_as(accounts(:alice))
    delete event_signup_path(event, event.signups.first)
    assert_equal 0, event.signups.count, "the host's player can take people off"
  end

  test "when it starts a Chapter opens at the Place with the host, and sign-ups are alerted" do
    event = make_event
    event.signups.create!(character: characters(:sable))
    event.update_columns(starts_at: 1.minute.ago)
    EventStartJob.perform_now
    event.reload
    assert event.opened?
    chapter = event.scene
    assert_equal place, chapter.room
    assert_equal [ characters(:wren) ], chapter.characters.to_a
    assert Alert.exists?(account: accounts(:bob), kind: "event", event: event, scene: chapter)
    assert Alert.exists?(account: accounts(:alice), kind: "event", event: event)

    sign_in_as(accounts(:bob))
    post event_signups_path(event), params: { character_id: characters(:sable).id }
    assert_redirected_to event_path(event)
    get alerts_path
    assert_select ".alerts__event", text: "Midwinter Ball"
  end

  test "events can't be set in the past" do
    sign_in_as(accounts(:alice))
    post events_path, params: { event: { title: "Too late", room_id: place.id, starts_at: "2001-01-01T10:00", host_id: characters(:wren).id } }
    assert_response :unprocessable_entity
    assert_equal 0, Event.count
  end
end
