defmodule PoboxServer.Server.ConnectionWorker do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init({socket} = _args) do
    serve_poller()
    {:ok, socket}
  end

  defp serve_poller() do
    send(self(), :pool)
  end

  @impl true
  def handle_info(:pool, socket) do
    msg =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- PoboxServer.Server.Command.parse(data),
           do: run_command(command)

    write_line(socket, msg)
    serve_poller()
    {:noreply, socket}
  end

  defp run_command(command) do
    IO.inspect(command)
    {:ok, "not implemented"}
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
