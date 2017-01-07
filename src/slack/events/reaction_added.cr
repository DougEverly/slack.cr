Slack::Event.register(Slack::Event::ReactionAdded, "reaction_added")

class Slack
  class Event
    # Implements https://api.slack.com/events/reaction_added
    class ReactionAdded < Slack::Event
      @@type = "reaction_added"
      JSON.mapping(
        type: String,
        item: JSON::Any,
        user: String,
        reaction: String,
        item_user: String,
        event_ts: String,
      )
    end
  end
end
