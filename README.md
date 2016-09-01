#  Slack Real Time API client written in Crystal

Super primordial client to Slack's Real Time API written in Crystal and using WebSockets.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  slack:
    github: DougEverly/slack
```


## Usage


```crystal
require "slack"
```


TODO: Write usage instructions here

## Development

```crystal
require "../src/slack.cr"
slack = Slack.new(token: ENV["SLACK_TOKEN"])

slack.add_callback(Slack::Event::Message, Proc(Slack, Slack::Event, Nil).new do |session, event|
  if event = event.as?(Slack::Event::Message) # weird casting here.. can i put it in slack?
    if session.me.as?(User)
      puts "Here as User! #{event.class.to_s} #{event.test}"
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
end)

slack.add_callback(Slack::Event::UserTyping, Proc(Slack, Slack::Event, Nil).new do |session, event|
  puts "someone is typing"
end
)

slack.add_callback(Slack::Event::StarAdded, Proc(Slack, Slack::Event, Nil).new do |session, event|
  puts "starred"
end
)
slack.add_callback(Slack::Event::PinAdded, Proc(Slack, Slack::Event, Nil).new do |session, event|
  puts "pin added"
end
)

slack.add_callback(Slack::Reconnect, Proc(Slack, Slack::Event, Nil).new do |session, event|
  puts "pin added"
end
)

slack.start

```

## Contributing

1. Fork it ( https://github.com/[your-github-name]/slack/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) Doug Everly - creator, maintainer