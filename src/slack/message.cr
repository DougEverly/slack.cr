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
  end
end
