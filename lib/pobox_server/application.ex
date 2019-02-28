defmodule PoboxServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: PoboxServer.Server.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> PoboxServer.Server.accept(port) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: PoboxServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
