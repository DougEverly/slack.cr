class Slack
  class Event
    class Message < Slack::Event
      property type : String
      property user : String
      property text : String
      property ts : String
      property channel : String
      property subtype : String | Nil

      def initialize(@raw : JSON::Any)
        super
        @user = @raw["user"].as_s
        @channel = @raw["channel"].as_s
        @text = @raw["text"].as_s
        @ts = @raw["ts"].as_s
        @subtype = if @raw["subtype"]?
                     @raw["subtype"].as_s
                   end
      end

      def mentioned_users
        text.match(/<@(\S+)>/) do |m|
          return [m.string]
        end
        return Array(String).new
      end

      def test
        "TEST"
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

      def mentions(*users : User)
        mentons(users.to_a)
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
