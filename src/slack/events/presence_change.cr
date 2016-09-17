class Slack
  class Event
    class PresenceChange < Slack::Event
      @@type = "presence_change"
      getter presence : String
      getter user : String

      def initialize(@raw : JSON::Any)
        super
        @presence = @raw["presence"].as_s
        @user = @raw["user"].as_s
      end
    end
  end
end
