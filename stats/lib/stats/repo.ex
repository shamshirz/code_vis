defmodule Stats.Repo do
  use Ecto.Repo,
    otp_app: :stats,
    adapter: Ecto.Adapters.Postgres
end
