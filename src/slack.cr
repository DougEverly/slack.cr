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

class User
  JSON.mapping({
    id:   String,
    name: String,
  })
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
    @users = Hash(String, User).new
  end

  # def initialize(io : JSON::PullParser)
  #   @users = Hash(String, User).new
  # end

  def <<(user : User)
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

struct Response
  @@id = 0

  def initialize(@channel : String, @text : String)
  end

  def to_json(io)
    {
      "id"      => @@id,
      "type"    => "message",
      "channel" => @channel,
      "text"    => @text,
    }.to_json(io)
  end
end

class Slack
  property wss : String | Nil
  property config
  property me : User?
  property users : Hash(String, User)
  property prefs : JSON::Any?
  property channels : Hash(String, Slack::Channel)
  property s : HTTP::WebSocket?

  # @config : JSON::Any

  @me : User?
  @mid : Int32
  @self : JSON::Any?
  @users : Users

  # @callbacks :  Hash(Slack::Event.class, Proc(Slack, Slack::Event, Nil))

  def initialize(@token : String)
    @mid = 0
    @users = Users.new
    @channels = Hash(String, Slack::Channel).new
    @endpoint = "slack.com"
    # @callbacks = Hash(Slack::Event.class,  ((Slack, Slack::Event)->)).new {|h,k| h[k] = ->(session : Slack, event : Slack::Event) {} }
    @callbacks = Hash(Slack::Event.class, Proc(Slack, Slack::Event, Nil)).new
    load_config
  end

  def add_callback(t : Slack::Event.class, cb : Proc(Slack, Slack::Event, Nil))
    @callbacks[t] = cb
    pp @callbacks
  end

  def load_config
    client = HTTP::Client.new @endpoint, tls: true
    response = client.get("/api/rtm.start?token=#{@token}")
    response.status_code # => 200
    config = Slack::Hello.from_json(response.body)
    config.users.each do |user|
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
  def start
    @running = true
    while @running
      connect
    end
  end

  def connect
    puts "Connecting..."
    if wss = @wss
      @s = HTTP::WebSocket.new(wss)
      hello = %[{
        "id": #{@mid += 1}
        "type": "message",
        "channel": "C1B6MMY7L",
        "text" : "hello"
        }]
      message = "Hello #{Time.now.to_s}"
      r = Response.new(channel: "C1B6MMY7L", text: message).to_json
      @s.try do |s|
        s.send r

        s.on_close do |m|
          puts "Connection closed: #{m}"
        end

        s.on_message do |j|
          x = JSON.parse(j)
          Slack::Event.get_event(x) do |event|
            if event
              puts event.class
              if cb = @callbacks[event.class]?
                cb.call(self, event)
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
