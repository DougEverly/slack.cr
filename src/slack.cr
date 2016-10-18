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
  property users : Slack::Users
  property prefs : JSON::Any?
  property channels : Hash(String, Slack::Channel)
  property s : HTTP::WebSocket?

  property debug = true

  # @config : JSON::Any

  @me : User?
  @mid : Int32
  @self : JSON::Any?

  def initialize(@token : String)
    @mid = 0
    @users = Slack::Users.new
    @channels = Hash(String, Slack::Channel).new
    @endpoint = "slack.com"
    @callbacks = Hash(Slack::Event.class, Array(Proc(Slack, Slack::Event, Nil))).new { |h, k| h[k] = Array(Proc(Slack, Slack::Event, Nil)).new }
    load_config

  end

  def on(event : Slack::Event.class, &cb : Slack, Slack::Event ->)
    @callbacks[event] << cb
  end

  def add_callback(t : Slack::Event.class, cb : Proc(Slack, Slack::Event, Nil))
    @callbacks[t] << cb
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

  def run
    @running = true

    on(Slack::Event::ReconnectUrl) do |session, event|
      if e = event.as?(Slack::Event::ReconnectUrl)
        if url = e.url
          puts "Setting url to #{url}"
          session.wss = url
          session.close
        end
      end
    end

    while @running
      puts "Connecting..."
      connect
    end
    puts "Disconnected"
  end

  def run(&block : Slack ->)
    @running = true
    connect
    while @running
      connect
    end
  end

  def close
    # if @running && (s = @s)
    #     s.close
    # end
  end

  def connect
    begin
      puts "Connecting..." if @debug
      if wss = @wss
        @s = HTTP::WebSocket.new(wss)
        @s.try do |s|
          s.on_close do |m|
            puts "Connection closed: #{m}"
          end

          s.on_message do |j|
            puts "Got event: #{j}" if debug
            x = JSON.parse(j)
            begin
              event = Slack::Event.get_event(x)
              if event
                if cbs = @callbacks[event.class]?
                  cbs.each do |cb|
                    cb.call(self, event)
                  end
                end
              elsif reply = Slack::ReplyTo.get_reply(j)
                pp reply
              end
            rescue ex
              puts "Cannot process event: #{ex.message} for event type '#{x["type"]}'"
            end
          end

          s.run
          puts "disconnected after run"
        end
      end
    rescue ex
      puts ex.message
    end
  end
end
