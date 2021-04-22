use Mix.Config

config :wargear, :url,
  slack_webhook: "https://hooks.slack.com/services/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"

config :wargear, :events_poller, run: true

config :wargear, :events_handler, run: true

config :wargear, :slack_app,
  auth_token: "xoxb-54424800626-1176165372337-3SRytEBW552i71F3wyDiVg5D",
  channel: "spitegear",
  base_url: "https://slack.com/api/",
  endpoints: [
    post_message: "chat.postMessage/",
    list_channels: "conversations.list",
    read_channel: "conversations.history"
  ],
  channel_ids: [spitegear: "C014W8DN81X"],
  board_image_filename: "board.jpg"
