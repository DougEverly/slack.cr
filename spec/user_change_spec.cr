require "./spec_helper"

private def event
  raw = %q[{
	"type": "user_change",
	"user": {
		"id": "U1B602ZD2",
		"team_id": "T1B6ABQMD",
		"name": "doug",
		"deleted": false,
		"status": null,
		"color": "9f69e7",
		"real_name": "Doug Everly",
		"tz": "America/Indiana/Indianapolis",
		"tz_label": "Eastern Daylight Time",
		"tz_offset": -14400,
		"profile": {
			"first_name": "Doug",
			"last_name": "Everly",
			"avatar_hash": "gee1547a0e23",
			"fields": [

			],
			"title": "",
			"phone": "",
			"skype": "",
			"real_name": "Doug Everly",
			"real_name_normalized": "Doug Everly",
			"email": "Doug@Everly.org",
			"image_24": "https://secure.gravatar.com/avatar/ee1547a0e2339187a37cd06bf7032124.jpg?s=24&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0005-24.png",
			"image_32": "https://secure.gravatar.com/avatar/ee1547a0e2339187a37cd06bf7032124.jpg?s=32&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0005-32.png",
			"image_48": "https://secure.gravatar.com/avatar/ee1547a0e2339187a37cd06bf7032124.jpg?s=48&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0005-48.png",
			"image_72": "https://secure.gravatar.com/avatar/ee1547a0e2339187a37cd06bf7032124.jpg?s=72&d=https%3A%2F%2Fa.slack-edge.com%2F66f9%2Fimg%2Favatars%2Fava_0005-72.png",
			"image_192": "https://secure.gravatar.com/avatar/ee1547a0e2339187a37cd06bf7032124.jpg?s=192&d=https%3A%2F%2Fa.slack-edge.com%2F7fa9%2Fimg%2Favatars%2Fava_0005-192.png",
			"image_512": "https://secure.gravatar.com/avatar/ee1547a0e2339187a37cd06bf7032124.jpg?s=512&d=https%3A%2F%2Fa.slack-edge.com%2F7fa9%2Fimg%2Favatars%2Fava_0005-512.png"
		},
		"is_admin": true,
		"is_owner": true,
		"is_primary_owner": true,
		"is_restricted": false,
		"is_ultra_restricted": false,
		"is_bot": false
	},
	"cache_ts": 1473681903,
	"event_ts": "1473681903.449897"
}]
  msg = JSON.parse(raw)
  event = Slack::Event.get_event(msg)
  event.as(Slack::Event::UserChange)
end

describe Slack::Event::UserChange do
  it "is a message" do
    event.class.should eq(Slack::Event::UserChange)
  end

  it "has fields" do
    event.user.should eq("U1B602ZD2")
    event.team_id.should eq("T1B6ABQMD")
    event.deleted.should eq(false)
    event.real_name.should eq("Doug Everly")
    # event.profile.should be(JSON::Any)
    pp event.profile
    # event.profile.class.should eq(JSON::Any)
  end

end
