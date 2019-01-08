defmodule LazyMapTest do
  use ExUnit.Case

  test "create an empty map" do
    lm = LazyMap.new()
    assert Enum.empty?(lm)
  end
end
