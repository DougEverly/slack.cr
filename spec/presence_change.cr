require "./spec_helper"

private def event
  json = %q[{"type":"presence_change","presence":"active","user":"U1B6P071Q"}]
  event = Slack::Event.get_event(json)
  event.as(Slack::Event::PresenceChange)
end

describe Slack::Event::PresenceChange do
  it "is a message" do
    event.class.should eq(Slack::Event::PresenceChange)
  end

  it "has fields" do
    event.user.should eq("U1B6P071Q")
    event.presence.should eq("active")
  end
end
