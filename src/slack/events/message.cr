Slack::Event.register(Slack::Event::Message, "message")

class Slack
  class Event
    # Implements https://api.slack.com/events/message
    class Message < Slack::Event
      @@type = "message"
      property type : String
      property user : String
      property text : String
      property ts : String
      property channel : String
      property subtype : String?

      def initialize(@raw : JSON::Any)
        super
        @user = @raw["user"].as_s
        @channel = @raw["channel"].as_s
        @text = @raw["text"].as_s
        @ts = @raw["ts"].as_s
        @raw["subtype"]?.try do |s|
          @subtype = s.as_s
        end
      end

      def mentioned_users
        text.match(/<@(\S+)>/) do |m|
          return [m.string]
        end
        return Array(String).new
      end

      def mentions(s : String)
        text =~ /#{s}/
      end

      def mentions(s : String)
        text =~ /#{s}/
      end

      def mentions(s : String)
        text =~ /#{s}/
      end

      def mentions(s : Array(String))
        s.each do |item|
          if text =~ /#{item}/
            return true
          end
        end
      end

      def mentions(*s : String)
        mentions(s.to_a)
      end

      def mentions(person : User?)
        text =~ /<@#{person.id}>/ if person
      end

      def from(person : User?)
        if person
          user == person.id
        end
      end

      def mentions(*users : User)
        mentions(users.to_a)
      end

      def mentions(users : Array(User))
        users.each do |user|
          if person
            text =~ /<@#{user.id}>/
            return true
          end
        end
      end

      def post(text : String)
        Response.new(channel, text)
      end

      def reply(text : String)
        Slack::Message.new(channel, text)
      end
    end
  end
end
