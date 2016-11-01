Slack::Event.register(Slack::Event::UserTyping, "user_typing")

class Slack
  class Event
    # Implements https://api.slack.com/events/user_typing
    class UserTyping < Event; end
  end
end
