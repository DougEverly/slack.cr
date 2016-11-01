Slack::Event.register(Slack::Event::ReconnectUrl, "reconnect_url")

class Slack
  class Event
    # Implements https://api.slack.com/events/reconnect_url
    class ReconnectUrl < Event
      property url : String

      def initialize(@raw : JSON::Any)
        super
        @url = @raw["url"].as_s
      end
    end
  end
end
