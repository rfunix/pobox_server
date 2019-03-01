defmodule PoboxServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      %{
      	id: PoboxServer,
        start: {PoboxServer.Server.TCPServer, :start_link, [{port}]}
      }
    ]

    opts = [strategy: :one_for_one, name: PoboxServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
