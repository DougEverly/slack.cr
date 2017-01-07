class Slack
  class Event
    class Ready < Event
      JSON.mapping(
        type: String,
      )
    end
  end
end
