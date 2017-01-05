# require "./events/message.cr"

class Slack
  class ReplyTo
    def self.get_reply(event : JSON::Any)
      if event["reply_to"]?
        new(event)
      end
    end

    def self.get_reply(event : String)
      self.get_reply(JSON.parse(event))
    end

    @ok : Bool
    @reply_to : Int32

    def initialize(@raw : JSON::Any)
      @ok = @raw["ok"].as_bool
      @reply_to = @raw["reply_to"].as_i
    end
  end

  class Event
    property type : String
    property raw : JSON::Any
    @type = "unknown"
    @raw = JSON::Any.new(nil)

    def initialize(@raw : JSON::Any)
      if type = @raw["type"]?
        @type = type.as_s
      else
        @type = "unknown"
      end
    end

    def self.type
      @@type
    end

    def self.get_event(session : Slack, event : String)
      self.get_event(JSON.parse(event))
      @callback.try do |callback|
        @callback.call(session, event)
      end
    end

    def self.get_event(session : Slack, event : String, &block)
      j = JSON.parse(event)
      block.call(session, event)
    end

    def self.call(slack : Slack, event : Slack::Event)
      new(event).call(slack, event)
    end

    def call(session : Slack, event : Slack::Event)
      @@callback.try do |cb|
        cb.call(session, event)
      end
    end

    def self.register(type : String)
      klass = self.class.to_s
    end

    # EVENTS = [
    #   Event,
    #   # Event::Hello,
    #   Event::Message,
    #   Event::PinAdded,
    #   Event::PresenceChange,
    #   Event::ReactionAdded,
    #   Event::Ready,
    #   Event::ReconnectUrl,
    #   Event::UserChange,
    #   Event::UserTyping,
    # ]

    EVENT_MAP = Hash(String, Slack::Event.class).new

    def self.register(event : Slack::Event.class, *types : String)
      types.each do |type|
        # puts "Registering #{type} => #{event.name}"
        EVENT_MAP[type] = event
      end
    end

    def self.event_map
      EVENT_MAP
    end

    def self.get_event(type : String)
      event_map[type]?.try do |e|
        e.new(JSON.parse("{\"type\":\"ready\"}"))
      end
    end

    def self.get_event(event : JSON::Any)
      event["type"]?.try do |type|
        event_map[type.as_s]?.try do |e|
          e.new(event)
        end
      end
    end

    def get_event(event : JSON::Any)
      new(event)
    end

    def self.get_event(event : JSON::Any, &block)
      event["type"]?.try do |type|
        event_map[type.as_s]?.try do |e|
          yield e.new(event)
        end
      end
    end
  end

  class Subtype
  end
end
