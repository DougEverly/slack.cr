class Slack
  class Hello
    JSON.mapping({
      ok:       Bool,
      me:       {type: User, key: "self"},
      users:    Array(User),
      url:      String,
      channels: Array(Slack::Channel),
    })
  end
end

module MemberConverter
  def self.from_json(value : JSON::PullParser)
    # value.read_array
    t = Array(String).new
    value.read_array do
      t << v.read_string
    end
  end
end

struct Team
  # JSON.mapping({
  property id : String?
  property name : String?
  property domain : String?
  # })
end

class Slack
  class Channel
    JSON.mapping({
      id:      String,
      name:    String,
      topic:   {type: Topic, nilable: true},
      purpose: {type: Topic, nilable: true},
      members: {type: Array(String), nilable: true},
    })

    struct Topic
      JSON.mapping({
        value:    String,
        creator:  String,
        last_set: Int32,
      })
    end
  end
end
