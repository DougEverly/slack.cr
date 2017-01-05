class Slack
  struct Message
    @@id = 0

    def initialize(@channel : String, @text : String)
    end

    def to_json(io)
      {
        "id"      => @@id,
        "type"    => "message",
        "channel" => @channel,
        "text"    => @text,
      }.to_json(io)
    end

    def get_event(event : JSON::Any)
      new(event)
    end

  end
end
