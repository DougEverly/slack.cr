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

    def to_s(io)
      io << @name
    end
  end
end

class Slack
  class User
    class Profile
      JSON.mapping({
        first_name:  String?,
        last_name:   String?,
        avatar_hash: String?,
        fields:      Array(String)?,
        title:       String?,
        phone:       String?,
        skype:       String?,
        email:       String?,
        real_name:   String?,
      })
    end
  end
end
