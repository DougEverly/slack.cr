class Slack
  class Event
    class Hello < Slack::Event
      @@type = "hello"
    end
  end
end
