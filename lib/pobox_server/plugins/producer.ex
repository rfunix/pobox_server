defmodule PoboxServer.Plugins.Producer do
  @callback send_message(String.t(), String.t()) :: {:ok, term} | {:error, term}
end
