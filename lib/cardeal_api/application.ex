defmodule CardealApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: CardealApi.Router, options: [port: 8080]},
      {CardealApi, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: CardealApi.Supervisor]
    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
end
