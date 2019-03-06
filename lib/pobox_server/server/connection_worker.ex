defmodule PoboxServer.Server.ConnectionWorker do
  use GenServer
  require Logger

  @impl true
  def init({socket} = _args) do
    serve_poller()
    {:ok, socket}
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

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  defp serve_poller() do
    Process.send_after(self(), :pool, 100)
  end

  defp run_command({:send_to_sqs, queue, message}) do
    task = Task.async(fn -> PoboxServer.Plugins.SQS.send_message(queue, message) end)

    case Task.await(task) do
      {:ok, _result} ->
        {:ok, 'sqs message published\r\n'}

      {:error, {:http_error, _, %{message: error_message}}} ->
        {:error, 'problem to send_sqs message #{error_message}\r\n'}

      _ ->
        {:error, 'ops, unknown problem to send_sqs message\r\n'}
    end
  end

  defp run_command(command) do
    IO.inspect(command)
    {:ok, "not implemented\r\n"}
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
    :gen_tcp.send(socket, error)
    #:gen_tcp.close(socket)
    #exit(error)
  end
end
