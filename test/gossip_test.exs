defmodule GossipMainTest do
  use ExUnit.Case
  doctest GossipMain

  test "greets the world" do
    assert GossipMain.hello() == :world
  end
end
