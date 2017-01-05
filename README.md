#  Slack Real Time API client written in Crystal

Client to Slack's [Real Time API](https://api.slack.com/rtm) written in Crystal and using WebSockets.

Still early in development.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  slack:
    github: DougEverly/slack.cr
```


## Usage

```crystal
require "slack"
```
## Samples

Look in `samples` directory for example usage.

## Example

```crystal
require "../src/slack.cr"
slack = Slack.new(token: ENV["SLACK_TOKEN"])

slack.on(Slack::Event::Message) do |session, event|
  if event = event.as?(Slack::Event::Message)
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
end

slack.on(Slack::Event::UserTyping) do |session, event|
  puts "someone is typing"
end

slack.on(Slack::Event::StarAdded) do |session, event|
  puts "starred"
end

slack.on(Slack::Event::PinAdded) do |session, event|
  puts "pin added"
end

slack.on(Slack::Reconnect) do |session, event|
  puts "pin added"
end

slack.start

```

## Contributing

1. Fork it ( https://github.com/DougEverly/slack/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [DougEverly](https://github.com/DougEverly) - creator, maintainer
