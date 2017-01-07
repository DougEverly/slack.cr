Slack::Event.register(Slack::Event::StarAdded, "star_added")
Slack::Event.register(Slack::Event::StarRemoved, "star_removed")
Slack::Event.register(Slack::Event::PinAdded, "pin_added")

class Slack
  class Event
    # Implements https://api.slack.com/events/star_added
    class StarAdded < Event
      JSON.mapping(
        type: String,
      )
    end

    # Impements https://api.slack.com/events/star_removed
    class StarRemoved < Event
      JSON.mapping(
        type: String,
      )
    end

    # Implments https://api.slack.com/events/pin_added
    class PinAdded < Event
      JSON.mapping(
        type: String,
      )
    end
  end
end
