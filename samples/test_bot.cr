require "../src/slack.cr"

# create slack session
slack = Slack.new(token: ENV["SLACK_TOKEN"])

slack.on(Slack::Event::Message) do |session, event|
  if event = event.as?(Slack::Event::Message) # weird casting here.. can i put it in slack.cr?
    if event.from(session.me)
      # This message is from me, dont reply to me
      next
    end
    if session.me.as?(Slack::User)
      if event.mentions(session.me)
        x = event.reply(text: "oh hi there")
        session.send x
      end

      if event.mentions("good morning", "good evening")
        if event.mentions(session.me)
          x = event.reply(text: "<@#{event.user}>: to you too!")
        else
          x = event.reply(text: "thank you!")
        end
        session.send x
      end
    end
  end
end

slack.on(Slack::Event::UserTyping) do |session, event|
  pp event
  puts "someone is typing 1"
end

# stack another action on Slack::Event::UserTyping
slack.on(Slack::Event::UserTyping) do |session, event|
  puts "someone is typing 2"
end

slack.on(Slack::Event::UserTyping) do |session, event|
  puts "Someone is typing"
end

slack.on(Slack::Event::UserChange) do |session, event|
  pp event
  e = event.as(Slack::Event::UserChange)
  puts "Here is my event"
  pp e.get_profile
  if user = session.users.by_id[e.user]?
    puts "Here is my user"
    pp user
    user.profile = e.get_profile
    pp user
  end
end

slack.on(Slack::Event::StarAdded) do |session, event|
  puts "starred"
end

slack.on(Slack::Event::PinAdded) do |session, event|
  puts "pin added"
end

# send welcome Message
slack.on(Slack::Event::Hello) do |session, event|
  message = "Hello #{Time.now.to_s}"
  r = Slack::Message.new(channel: session.channels["#general"].id, text: message)
  slack.send r
end

slack.on(Slack::Event::ReconnectUrl) do |session, event|
  puts "uh oh should reconnect!"
end

spawn {
  slack.run
}

spawn {
  sleep(1)
  slack.send("Hello from sleeper", to: "general")
}

sleep
