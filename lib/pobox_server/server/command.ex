defmodule PoboxServer.Server.Command do
  def parse(line) do
    case String.split(line) do
      ["send_sqs", message] -> {:ok, {:send_sqs, message}}
      _ -> {:error, :unknown_command}
    end
  end
end
