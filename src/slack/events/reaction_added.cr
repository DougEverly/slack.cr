class Slack
  class Event
    class ReactionAdded < Slack::Event
      @@type = "presence_change"
      getter item : JSON::Any
      getter user : String
      getter reaction : String
      getter item_user : String
      getter event_ts : String

      def initialize(@raw : JSON::Any)
        super
        @item = @raw["item"]
        @user = @raw["user"].as_s
        @reaction = @raw["reaction"].as_s
        @item_user = @raw["item_user"].as_s
        @event_ts = @raw["event_ts"].as_s
      end
    end
  end
end
