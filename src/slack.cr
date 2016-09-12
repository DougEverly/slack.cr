require "http/client"
require "http/web_socket"
require "json"
require "./slack/**"

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

class Users
  # @users = Hash(String, User)
  def initialize
    @users = Hash(String, Slack::User).new
  end

  # def initialize(io : JSON::PullParser)
  #   @users = Hash(String, User).new
  # end

  def <<(user : Slack::User)
    @users[user.id] = user
    @users["@" + user.name] = user
  end

  def [](key)
    @users[key]
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

class Slack
  property wss : String | Nil
  property config
  property me : User?
  property users : Hash(String, Slack::User)
  property prefs : JSON::Any?
  property channels : Hash(String, Slack::Channel)
  property s : HTTP::WebSocket?

  # @config : JSON::Any

  @me : User?
  @mid : Int32
  @self : JSON::Any?
  @users : Users

  # @callbacks :  Hash(Slack::Event.class, Proc(Slack, Slack::Event, Nil))

  # def on(event_type, &cb)
  #   add_callback(event_type.class, Proc(Slack, Slack::Event, Nil).new do |session, event|
  #     puts "someone is typing"
  #   end
  #   )
  # end

  def initialize(@token : String)
    @mid = 0
    @users = Users.new
    @channels = Hash(String, Slack::Channel).new
    @endpoint = "slack.com"
    # @callbacks = Hash(Slack::Event.class,  ((Slack, Slack::Event)->)).new {|h,k| h[k] = ->(session : Slack, event : Slack::Event) {} }
    @callbacks = Hash(Slack::Event.class, Array(Proc(Slack, Slack::Event, Nil))).new { |h, k| h[k] = Array(Proc(Slack, Slack::Event, Nil)).new }
    load_config
  end

  def add_callback(t : Slack::Event.class, cb : Proc(Slack, Slack::Event, Nil))
    @callbacks[t] << cb
    pp @callbacks
  end

  def on_user_typing(&cb : Proc(Slack, Slack::Event, Nil))
    @callbacks[Slack::Event::UserTyping] << cb
  end

  def on_user_change(&cb : Proc(Slack, Slack::Event, Nil))
    @callbacks[Slack::Event::UserChange] << cb
  end

  def load_config
    client = HTTP::Client.new @endpoint, tls: true
    response = client.get("/api/rtm.start?token=#{@token}")
    response.status_code # => 200
    response.body
    config = Slack::Hello.from_json(response.body)
    config.users.each do |user|
      pp user
      @users << user
    end
    config.channels.each do |channel|
      @channels[channel.id] = channel
      @channels["#" + channel.name] = channel
    end
    pp @users
    if config
      # pp config
      @wss = config.url
      @me = config.me
    end
    client.close
  end

  def send(msg : Object)
    @s.try do |s|
      s.send(msg.to_json)
    end
  end

  # def me
  #   @config.me
  # end
  def run
    @running = true
    while @running
      connect
    end
  end

  def run(&block : Slack ->)
    @running = true
    connect
    while @running
      connect
    end
  end

  def connect
    puts "Connecting..."
    if wss = @wss
      @s = HTTP::WebSocket.new(wss)
      @s.try do |s|
        s.on_close do |m|
          puts "Connection closed: #{m}"
        end

        ready_event = Slack::Event.get_event("ready")

        # puts " .... "
        # @callbacks[Slack::Event::Ready]?.try do |cbs|
        #   cbs.each do |cb|
        #   cb.call(self, ready_event)
        #   end
        # end

        s.on_message do |j|
          x = JSON.parse(j)
          Slack::Event.get_event(x) do |event|
            pp event.class
            if event
              puts event.class
              if cbs = @callbacks[event.class]?
                cbs.each do |cb|
                  cb.call(self, event)
                end
              end
              case event
              when Slack::Reconnect
                @wss = event.url
                s.close
              else
              end
            elsif reply = Slack::ReplyTo.get_reply(j)
              pp reply
            end
          end
        end

        s.run
      end
    end
  end
end
