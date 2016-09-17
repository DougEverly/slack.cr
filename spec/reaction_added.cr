require "./spec_helper"

private def event
  raw = %q[{"type":"reaction_added","user":"U1B602ZD2","item":{"type":"message","channel":"C1B6MMY7L","ts":"1474121674.000011"},"reaction":"hugging_face","item_user":"U1B6P071Q","event_ts":"1474121814.357543"}]
  msg = JSON.parse(raw)
  event = Slack::Event.get_event(msg)
  event.as(Slack::Event::ReactionAdded)
end

describe Slack::Event::ReactionAdded do
  it "is a message" do
    # pp event
    event.class.should eq(Slack::Event::ReactionAdded)
  end

  it "has fields" do
    event.user.should eq("U1B602ZD2")
  end
end
