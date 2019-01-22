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

  test "check if a value is member of a LazyMap" do
    lm = LazyMap.new(%{first: fn -> "hello" end})
    assert Enum.member?(lm, :first)
    refute Enum.member?(lm, :second)
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

  test "lazy value can be configured as {Module, Function, Arguments}" do
    lm = LazyMap.new(%{hello: {Test.Support.DBMock, :providers, ["Cheese"]}})

    assert %{
             "providers" => [
               %{"name" => "Best Cheese"},
               %{"name" => "Better Cheese"},
               %{"name" => "Amazing Cheese"}
             ]
           } = lm[:hello]
  end

  test "raises UndefinedFunctionError when invoked function doesn't exists" do
    lm = LazyMap.new(%{hello: {SampleModule, :sample_function, []}})
    assert_raise UndefinedFunctionError, fn -> lm[:hello] end
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

  test "get the data from a serialized LazyMap simulating a remote call" do
    lm = :rpc.call(:nonode@nohost, Test.Support.SerializeLazy, :generate_lazy, [])

    assert %{
             "providers" => [
               %{"name" => "Best Chocolate"},
               %{"name" => "Better Chocolate"}
             ]
           } == lm[:providers]
  end

  test "get the data from a serialized LazyMap saved in disk" do
    file_name = "./db/saved_lazy_map"
    lm = :rpc.call(:nonode@nohost, Test.Support.SerializeLazy, :generate_lazy, [])
    File.write!(file_name, :erlang.term_to_binary(lm))

    lm_from_disk = file_name |> File.read!() |> :erlang.binary_to_term()

    assert %{
             "providers" => [
               %{"name" => "Best Chocolate"},
               %{"name" => "Better Chocolate"}
             ]
           } == lm_from_disk[:providers]
  end

  test "get the data from a serialized LazyMap saved in ets" do
    table = :ets.new(:lazy_maps, [:set, :private])
    lm = :rpc.call(:nonode@nohost, Test.Support.SerializeLazy, :generate_lazy, [])
    :ets.insert(table, {:lm, lm})

    [lm: lm_from_ets] = :ets.lookup(table, :lm)

    assert %{
             "providers" => [
               %{"name" => "Best Chocolate"},
               %{"name" => "Better Chocolate"}
             ]
           } == lm_from_ets[:providers]
  end

  test "can be accessed using kernel.get_in/2" do
    lm = LazyMap.new(%{hello: :world})
    assert :world = get_in(lm, [:hello])
  end

  test "can be accessed to deep level using kernel.get_in/2" do
    lm = LazyMap.new(%{hello: fn -> LazyMap.new(%{my: fn -> %{friend: :world} end}) end})
    assert :world = get_in(lm, [:hello, :my, :friend])
  end

  test "can be updated using kernel.put_in/3" do
    lm = LazyMap.new(%{hello: :world})
    assert %LazyMap{map: %{hello: :nothing}} = put_in(lm, [:hello], :nothing)
  end

  test "can be updated to deep complex level using kernel.put_in/3" do
    lm = LazyMap.new(%{hello: LazyMap.new(%{my: %{friend: :world}})})

    assert %LazyMap{map: %{hello: %LazyMap{map: %{my: %{friend: :nothing}}}}} =
             put_in(lm, [:hello, :my, :friend], :nothing)
  end

  test "can be updated using kernel.update_in/3" do
    lm = LazyMap.new(%{hello: LazyMap.new(%{my: %{friend: :world}})})

    assert %LazyMap{map: %{hello: %LazyMap{map: %{my: %{friend: :nothing}}}}} =
             update_in(lm, [:hello, :my, :friend], fn _ -> :nothing end)
  end

  test "can be called with Kernel.pop_in/2" do
    lm = LazyMap.new(%{hello: LazyMap.new(%{my: %{friend: :world}})})

    assert {:world, %LazyMap{map: %{hello: %LazyMap{map: %{my: %{}}}}}} =
             pop_in(lm, [:hello, :my, :friend])
  end

  test "can be accessed using kernel.get_and_update_in/2" do
    lm = LazyMap.new(%{hello: :world})

    assert {:world, %LazyMap{map: %{hello: :nothing}}} =
             get_and_update_in(lm, [:hello], fn value -> {value, :nothing} end)
  end

  test "can be called with Kernel.get_and_update_in/3" do
    lm = LazyMap.new(%{hello: LazyMap.new(%{my: %{friend: :world}})})

    assert {:world, %LazyMap{map: %{hello: %LazyMap{map: %{my: %{friend: :nothing}}}}}} =
             get_and_update_in(lm, [:hello, :my, :friend], fn value -> {value, :nothing} end)
  end
end
