defmodule LazyMap do
  @moduledoc """
  Lazy implementation of Access behaviour.
  Substitutes `map` when lazy value access is needed.
  """
  defstruct map: %{}

  @doc """
  Creates a new LazyMap
  """
  def new, do: %LazyMap{}
  def new(map), do: %LazyMap{map: map}

  def size(%LazyMap{map: map}) do
    map_size(map)
  end

  def to_list(%LazyMap{map: map}) do
    Map.keys(map)
  end

  def fetch(%LazyMap{map: map}, key) do
    do_fetch(Map.fetch(map, key))
  end

  defp do_fetch({:ok, fun}) when is_function(fun) do
    {:ok, fun.()}
  end

  defp do_fetch({:ok, {module, fun, args}})
       when is_atom(module) and is_atom(fun) and is_list(args) do
    {:ok, apply(module, fun, args)}
  end

  defp do_fetch(value), do: value

  def get_and_update(%LazyMap{map: map}, key, fun) do
    {value, map} = Map.get_and_update(map, key, fun)
    {value, LazyMap.new(map)}
  end

  def pop(%LazyMap{map: map}, key) do
    {value, map} = Map.pop(map, key)
    {value, LazyMap.new(map)}
  end

  defimpl Enumerable do
    def count(lazy_map) do
      {:ok, LazyMap.size(lazy_map)}
    end

    def member?(%LazyMap{map: map}, value) do
      {:ok, match?(%{^value => _}, map)}
    end

    def slice(lazy_map) do
      {:ok, LazyMap.size(lazy_map), &Enumerable.List.slice(LazyMap.to_list(lazy_map), &1, &2)}
    end

    # def reduce(lazy_map, acc, fun) do
    #   lazy_map
    # end
  end
end
