defmodule PoboxServer.Server.TCPServer do
  require Logger
  use GenServer

  ## Callbacks

  @impl true
  def init({port} = _args) do
    Logger.info("Accepting connections on port #{port}")

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    receive_poller()
    {:ok, socket}
  end

  @impl true
  def handle_info(:pool, socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    Logger.info("Client connected")

    create_connection_worker(client)

    receive_poller()
    {:noreply, socket}
  end

  @impl true
  def handle_cast({:create_connection_worker, client}, socket) do
    spawn(PoboxServer.Server.ConnectionWorker, :start_link, [{client}])

    {:noreply, socket}
  end

  # Server

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  defp receive_poller() do
    Process.send_after(self(), :pool, 100)
  end

  defp create_connection_worker(client) do
    GenServer.cast(__MODULE__, {:create_connection_worker, client})
  end
end
