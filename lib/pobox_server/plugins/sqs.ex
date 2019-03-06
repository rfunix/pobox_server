defmodule PoboxServer.Plugins.SQS do
  @behaviour PoboxServer.Plugins.Producer

  @impl true
  def send_message(queue, message) do
    aws_query = ExAws.SQS.send_message(queue, message)
    ExAws.request(aws_query)
  end
end
