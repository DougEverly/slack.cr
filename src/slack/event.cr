# require "./events/message.cr"

class Slack
  class ReplyTo
    def self.get_reply(event : JSON::Any)
      pp event
      if event["reply_to"]?
        new(event)
      end
    end

    def self.get_reply(event : String)
      self.get_reply(JSON.parse(event))
    end

    @ok : Bool
    @reply_to : Int32

    def initialize(@raw : JSON::Any)
      @ok = @raw["ok"].as_bool
      @reply_to = @raw["reply_to"].as_i
    end
  end

  class Event
    property type : String

    property callback : Proc(Slack, Slack::Event, Nil)?

    @@callback = nil # ->(session : Slack, event : Slack::Event) {  puts "here" }

    def self.callback=(callback : Proc(Slack, Slack::Event, Nil)?)
      puts "Setting callback..."
      pp callback
      @@callback = callback
    end

    def self.callback
      @@callback
    end

    def callback
      @callback ||= self.callback
    end

    def initialize(@raw : JSON::Any)
      @type = @raw["type"].as_s
      # @callbacks = Hash(Class, (Slack, Slack::Event)->).new
      # @callback = self.callback
      # @callback = nil
      # @callback = Proc(Slack, Slack::Event, Nil).new { |session, event| puts "got event" }
      # @callback = self.callback
    end

    def self.get_event(session : Slack, event : String)
      self.get_event(JSON.parse(event))
      @callback.try do |callback|
        @callback.call(session, event)
      end
    end

    def self.get_event(session : Slack, event : String, &block)
      j = JSON.parse(event)
      block.call(session, event)
    end

    def self.call(slack : Slack, event : Slack::Event)
      new(event).call(slack, event)
    end

    def call(session : Slack, event : Slack::Event)
      puts "Calling callback...."
      pp @@callback
      pp @callback
      @@callback.try do |cb|
        puts "Callback is not nil!"
        cb.call(session, event)
      end
    end

    def self.event_map
      event_map = {
        "message"                 => Event::Message,
        "hello"                   => Event,
        "presence_change"         => Event::PresenceChange,
        "user_typing"             => Event::UserTyping,
        "reconnect_url"           => Event,
        "channel_marked"          => Event,
        "channel_created"         => Event,
        "channel_joined"          => Event,
        "channel_left"            => Event,
        "channel_deleted"         => Event,
        "channel_rename"          => Event,
        "channel_archive"         => Event,
        "channel_unarchive"       => Event,
        "channel_history_changed" => Event,
        "dnd_updated"             => Event,
        "dnd_updated_user"        => Event,
        "im_created"              => Event,
        "im_open"                 => Event,
        "im_close"                => Event,
        "im_marked"               => Event,
        "im_history_changed"      => Event,
        "group_joined"            => Event,
        "group_left"              => Event,
        "group_open"              => Event,
        "group_close"             => Event,
        "group_archive"           => Event,
        "group_unarchive"         => Event,
        "group_rename"            => Event,
        "group_marked"            => Event,
        "group_history_changed"   => Event,
        "file_created"            => Event,
        "file_shared"             => Event,
        "file_unshared"           => Event,
        "file_public"             => Event,
        "file_private"            => Event,
        "file_change"             => Event,
        "file_deleted"            => Event,
        "file_comment_added"      => Event,
        "file_comment_edited"     => Event,
        "file_comment_deleted"    => Event,
        "pin_added"               => PinAdded,
        "pin_removed"             => Event,
        "presence_change"         => Event,
        "manual_presence_change"  => Event,
        "pref_change"             => Event,
        "user_change"             => Event,
        "team_join"               => Event,
        "star_added"              => StarAdded,
        "star_removed"            => StarRemoved,
        "reaction_added"          => Event,
        "reaction_removed"        => Event,
        "emoji_changed"           => Event,
        "commands_changed"        => Event,
        "team_plan_change"        => Event,
        "team_pref_change"        => Event,
        "team_rename"             => Event,
        "team_domain_change"      => Event,
        "email_domain_changed"    => Event,
        "team_profile_change"     => Event,
        "team_profile_delete"     => Event,
        "team_profile_reorder"    => Event,
        "bot_added"               => Event,
        "bot_changed"             => Event,
        "accounts_changed"        => Event,
        "team_migration_started"  => Event,
        "reconnect_url"           => Event,
        "Experimental"            => Event,
        "subteam_created"         => Event,
        "subteam_updated"         => Event,
        "subteam_self_added"      => Event,
        "subteam_self_removed"    => Event,
      }
    end

    def self.get_event(event : JSON::Any)
      event["type"]?.try do |type|
        event_map[type.as_s]?.try do |e|
          e.new(event)
        end
      end
    end

    def self.get_event(event : JSON::Any, &block)
      event["type"]?.try do |type|
        event_map[type.as_s]?.try do |e|
          yield e.new(event)
        end
      end
    end
  end

  class Subtype
  end
end
