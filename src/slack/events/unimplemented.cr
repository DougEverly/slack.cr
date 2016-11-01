%w(accounts_changed
  bot_added
  bot_changed
  channel_archive
  channel_created
  channel_deleted
  channel_history_changed
  channel_joined
  channel_left
  channel_marked
  channel_rename
  channel_unarchive
  commands_changed
  dnd_updated
  dnd_updated_user
  email_domain_changed
  emoji_changed
  file_change
  file_comment_added
  file_comment_deleted
  file_comment_edited
  file_created
  file_deleted
  file_private
  file_public
  file_shared
  file_unshared
  group_archive
  group_close
  group_history_changed
  group_joined
  group_left
  group_marked
  group_open
  group_rename
  group_unarchive
  im_close
  im_created
  im_history_changed
  im_marked
  im_open
  manual_presence_change
  pin_removed
  pref_change
  reaction_removed
  star_added
  star_removed
  subteam_created
  subteam_self_added
  subteam_self_removed
  subteam_updated
  team_domain_change
  team_join
  team_migration_started
  team_plan_change
  team_pref_change
  team_profile_change
  team_profile_delete
  team_profile_reorder
  team_rename
).each do |event_type|
  Slack::Event.register(Slack::Event::Unimplemented, event_type)
end

class Slack
  class Event
    # Placeholder for unimplemented Slack events https://api.slack.com/events
    class Unimplemented < Slack::Event
    end
  end
end
