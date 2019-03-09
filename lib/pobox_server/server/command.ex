defmodule PoboxServer.Server.Command do
  @doc ~S"""
  Parses the given socket reader `line` into a command.

  ## Examples

    iex> PoboxServer.Server.Command.parse("send_to_sqs queue_test {\"id\": \"xx\", \"name\": \"test\", \"nested\": {\"date\": \"2018-01-01\"}}\nend_command")
    {:ok, {:send_to_sqs, "queue_test", "{\"id\": \"xx\", \"name\": \"test\", \"nested\": {\"date\": \"2018-01-01\"}}"}}

  """
  def parse(line) do
    case hd(String.split(line)) do
      "send_to_sqs" -> parse_send_to_sqs_command(line)
      _ -> {:error, :unknown_command}
    end
  end

  defp parse_send_to_sqs_command(data) do
    case Regex.named_captures(
           ~r/(?ms)(?<command>[a-z_]+?)\s(?<queue>.+?)\s(?<payload>.+?)\nend_command/,
           data
         ) do
      %{"command" => "send_to_sqs", "queue" => queue, "payload" => payload} ->
        {:ok, {:send_to_sqs, queue, payload}}

      _ ->
        {:error, "Invalid send_to_sqs_command"}
    end
  end
end
