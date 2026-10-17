module EventsHelper
  # A moment shown in the reader's own time zone (local_time_controller.js),
  # printed in UTC for anyone without JavaScript.
  def local_time(time, css_class = nil)
    tag.time time.utc.strftime("%a %-d %B %Y, %H:%M UTC"), datetime: time.utc.iso8601, class: [ "local-time", css_class ], data: { controller: "local-time" }
  end
end
