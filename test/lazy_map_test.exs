defmodule LazyMapTest do
  use ExUnit.Case
  alias Test.Support.{DBMock, ServerMock}

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

    lm = LazyMap.new(%{"first" => "hello", "second" => "world"})
    assert "hello" == lm["first"]
  end

  test "lazy values can be retrieved with the `map[key]` syntax" do
    lm = LazyMap.new(%{first: fn -> "hello" end})
    assert "hello" == lm[:first]
    assert nil == lm[:non_exists]

    lm = LazyMap.new(%{"first" => fn -> "hello" end})
    assert "hello" == lm["first"]
  end

  test "get the data calling a function declared in an external module" do
    lm = LazyMap.new(%{providers: fn -> DBMock.providers("Chocolate") end})

    assert %{
             "providers" => [
               %{"name" => "Best Chocolate"},
               %{"name" => "Better Chocolate"}
             ]
           } == lm[:providers]
  end

  test "get the data calling a function running a GenServer" do
    lm = LazyMap.new(%{providers: fn -> ServerMock.providers("Chocolate") end})

    assert %{
             "providers" => [
               %{"name" => "Best Chocolate"},
               %{"name" => "Better Chocolate"}
             ]
           } == lm[:providers]
  end

  test "get the data calling a web server" do
    lm =
      LazyMap.new(%{
        providers: fn ->
          {:ok, %{body: json}} =
            HTTPoison.get("http://localhost:4004/providers?product_name=Chocolate")

          Poison.decode!(json)
        end
      })

    assert %{
             "providers" => [
               %{"name" => "Best Chocolate"},
               %{"name" => "Better Chocolate"}
             ]
           } == lm[:providers]
  end
end
