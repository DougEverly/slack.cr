class Slack
  class User
    JSON.mapping({
      id:        String,
      name:      String,
      team_id:   String?,
      deleted:   Bool?,
      real_name: String?,
      tz:        String?,
    })
  end
end
