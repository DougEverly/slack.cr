Slack::Event.register(Slack::Event::PresenceChange, "presence_change")

class Slack
  class Event
    # Implements https://api.slack.com/events/presence_change
    class PresenceChange < Slack::Event
      @@type = "presence_change"
      JSON.mapping(
        type: String,
        presence: String,
        user: String
      )
      # getter presence : String
      # getter user : String

      # def initialize(@raw : JSON::Any)
      #   super
      #   @presence = @raw["presence"].as_s
      #   @user = @raw["user"].as_s
      # end
    end
  end
end
