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

  test "values can be retrieved with the `map[key]` syntax" do
    lm = LazyMap.new(%{first: "hello", second: "world"})
    assert "hello" == lm[:first]
    assert nil == lm[:non_exists]
  end

  test "lazy values can be retrieved with the `map[key]` syntax" do
    lm = LazyMap.new(%{first: fn -> "hello" end})
    assert "hello" == lm[:first]
    assert nil == lm[:non_exists]
  end
end
