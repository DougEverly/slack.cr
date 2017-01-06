Slack::Event.register(Slack::Event::UserTyping, "user_typing")

class Slack
  class Event
    # Implements https://api.slack.com/events/user_typing
    class UserTyping < Slack::Event
      JSON.mapping(
        type: String,
      )
    end
  end
end
