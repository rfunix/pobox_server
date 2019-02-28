defmodule PoboxServerTest do
  use ExUnit.Case
  doctest PoboxServer

  test "greets the world" do
    assert PoboxServer.hello() == :world
  end
end
