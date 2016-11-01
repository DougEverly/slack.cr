require "http/client"
require "http/web_socket"
require "json"
require "./slack/**"

# Handles connecting and starting Slack websocket session and delegates slack events.
# ```
# require "../src/slack.cr"
# slack = Slack.new(token: ENV["SLACK_TOKEN"])
#
# slack.on(Slack::Event::UserTyping) do |session, event|
#   puts "someone is typing 2"
# end
#
# slack.run
# ```
class Slack
  property wss : String | Nil
  property config
  # Returns me, as the current slack user.
  property me : User?
  # List of users in current Slack.
  property users : Slack::Users
  # Preferences
  property prefs : JSON::Any?
  # Channels in current Slack session.
  property channels : Hash(String, Slack::Channel)
  # Websocket connection.
  property socket : HTTP::WebSocket?

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
    start
  end

  # Binds a callback to event.
  # Allows multiple bindings to event, and will be called in order of binding
  def on(event : Slack::Event.class, &cb : Slack, Slack::Event ->)
    @callbacks[event] << cb
  end

  # Calls Slack rtm.start method to get initial websocket connection parameters
  private def start
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

  # Send a message to slack
  def send(msg : Slack::Message)
    @socket.try do |socket|
      socket.send(msg.to_json)
    end
  end

  # Send a message to slack
  def send(msg : String, to channel : String)
    send(Slack::Message.new(channel, msg))
  end

  # Start Slack RTM event loop
  def run
    @running = true

    # If a recconnect url is provided
    # * Save new url
    # * Close current connection
    on(Slack::Event::ReconnectUrl) do |session, event|
      if e = event.as?(Slack::Event::ReconnectUrl)
        if url = e.url
          puts "Setting url to #{url}"
          session.wss = url
          session.close
        end
      end
    end

    # Connect loop
    while @running
      puts "Connecting..."
      connect
    end
    puts "Disconnected"
  end

  # Close the websocket connection
  def close
  end

  # connect and run event loop
  private def connect
    begin
      puts "Connecting..." if @debug
      if wss = @wss
        @socket = HTTP::WebSocket.new(wss)
        @socket.try do |socket|
          socket.on_close do |m|
            puts "Connection closed: #{m}"
          end

          socket.on_message do |j|
            puts "Got event: #{j}" if debug
            x = JSON.parse(j)
            pp x
            begin
              event = Slack::Event.get_event(x)
              if event
                pp event
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

          socket.run
          puts "disconnected after run"
        end
      end
    rescue ex
      puts ex.message
    end
  end
end
