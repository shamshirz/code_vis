# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stats,
  ecto_repos: [Stats.Repo]

config :stats, Stats.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

config :stats, :generators,
  migration: true,
  binary_id: true,
  sample_binary_id: "11111111-1111-1111-1111-111111111111"

# Configures the endpoint
config :stats, StatsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ut8asvccAuDJozjz6szmYuVZOvDrkWFFg7y+Gj4bt1VioLoynow/0Jbi7jtgzsPJ",
  render_errors: [view: StatsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Stats.PubSub,
  live_view: [signing_salt: "h4POtuQL"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
