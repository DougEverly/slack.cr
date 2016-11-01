Slack::Event.register(Slack::Event::StarAdded, "star_added")
Slack::Event.register(Slack::Event::StarRemoved, "star_removed")
Slack::Event.register(Slack::Event::PinAdded, "pin_added")

class Slack
  class Event
    # Implements https://api.slack.com/events/star_added
    class StarAdded < Event; end

    # Impements https://api.slack.com/events/star_removed
    class StarRemoved < Event; end

    # Implments https://api.slack.com/events/pin_added
    class PinAdded < Event; end
  end
end
