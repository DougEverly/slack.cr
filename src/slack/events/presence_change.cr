class Slack
  class Event
    class PresenceChange < Event
      def call
        puts "Hey, I have an event!"
      end
    end
  end
end
