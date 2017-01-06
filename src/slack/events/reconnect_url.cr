Slack::Event.register(Slack::Event::ReconnectUrl, "reconnect_url")

class Slack
  class Event
    # Implements https://api.slack.com/events/reconnect_url
    class ReconnectUrl < Slack::Event
      JSON.mapping(
        type: String,
        url: String,
      )
      # property url : String

      # def initialize(@raw : JSON::Any)
      #   super
      #   @url = @raw["url"].as_s
      # end
    end
  end
end
