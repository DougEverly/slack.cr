class Slack
  class Event
    class UserChange < Slack::Event
      property user : String
      property team_id : String
      property name : String
      property deleted : Bool

      def initialize(raw : JSON::Any)
        @name = "unknown"
        @user = "unknown"
        @team_id = "unknown"
        @deleted = false
        super
        if u = @raw["user"]?
          @user = u["id"].as_s
          @team_id = u["team_id"].as_s
          u["textname"]?.try do |n|
            @name = n.as_s
         end
          @deleted = u["deleted"].as_bool
        end
      end
    end
  end
end
