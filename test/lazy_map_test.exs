defmodule LazyMapTest do
  use ExUnit.Case

  test "create an empty map" do
    lm = LazyMap.new()
    assert Enum.empty?(lm)
  end

  test "create a lazy map with two elements" do
    lm = LazyMap.new(%{first: "hello", second: "world"})
    assert 2 == Enum.count(lm)
  end
end
