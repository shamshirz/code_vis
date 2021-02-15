defmodule CodeVis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: CodeVis.Plug.Visualize, options: [port: 1337]}
    ]

    opts = [strategy: :one_for_one, name: CodeVis.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
