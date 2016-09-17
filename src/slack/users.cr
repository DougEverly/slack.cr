class Slack
  class Users
    def initialize
      @users_by_id = Hash(String, Slack::User).new
      @users_by_name = Hash(String, Slack::User).new
    end

    def <<(user : Slack::User)
      @users_by_id[user.id] = user
      @users_by_name["@" + user.name] = user
    end

    def [](key)
      @users_by_id[key]
    end

    def by_id
      @users_by_id
    end

    def by_name
      @users_by_name
    end

    def to_s(io : IO)
      io << @users_by_id.values.map { |u| u.to_s }.join(",")
    end
  end
end
