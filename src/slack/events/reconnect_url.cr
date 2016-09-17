class Slack
  class Event
    class ReconnectUrl < Event
      property url : String

      def initialize(@raw : JSON::Any)
        super
        @url = @raw["url"].as_s
      end
    end
  end
end
