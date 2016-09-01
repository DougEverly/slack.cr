class Slack
  class Reconnect < Event
    property type : String
    property url : String

    def initialize(@raw : JSON::Any)
      super
      @url = @raw["url"].as_s
    end
  end
end
