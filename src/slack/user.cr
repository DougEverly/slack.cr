# Slack::User
#
# Models Slack User
class Slack
  class User
    JSON.mapping({
      id:        String,
      name:      String,
      team_id:   String?,
      deleted:   Bool?,
      real_name: String?,
      tz:        String?,
      profile:   JSON::Any?,
    })

    def initialize(json : JSON::Any)
      @id = json["id"]
      @name = json["name"]
      @profile = json["profile"]
    end

    def to_s(io)
      io << @name
    end
  end
end
