Slack::Event.register(Slack::Event::Hello, "hello")

class Slack
  class Event
    # Implements https://api.slack.com/events/hello
    class Hello < Slack::Event
      @@type = "hello"
    end
  end
end
