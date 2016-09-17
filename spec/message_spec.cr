require "./spec_helper"

private def event
  raw = %q[{"type":"message","channel":"C1B6MMY7L","user":"U1B602ZD2","text":"hi","ts":"1473680477.000002","team":"T1B6ABQMD"}]
  msg = JSON.parse(raw)
  event = Slack::Event.get_event(msg)
  event.as(Slack::Event::Message)
end

describe Slack::Event::Message do
  it "is a message" do
    # pp event
    event.class.should eq(Slack::Event::Message)
  end

  it "has fields" do
    event.type.should eq("message")
    event.user.should eq("U1B602ZD2")
    event.text.should eq("hi")
    event.channel.should eq("C1B6MMY7L")
  end
end
