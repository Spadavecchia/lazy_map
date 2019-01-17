defmodule LazyMapTest do
  use ExUnit.Case
  alias Test.Support.ServerMock

  defmodule ExternalModule do
    def providers(product_name) do
      products = %{
        "Cheese" => %{
          "providers" => [
            %{"name" => "Best Cheese"},
            %{"name" => "Better Cheese"},
            %{"name" => "Amazing Cheese"}
          ]
        },
        "Chocolate" => %{
          "providers" => [
            %{"name" => "Best Chocolate"},
            %{"name" => "Better Chocolate"}
          ]
        }
      }

      products[product_name]
    end
  end

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
    lm = LazyMap.new(%{providers: fn -> ExternalModule.providers("Chocolate") end})

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
end
