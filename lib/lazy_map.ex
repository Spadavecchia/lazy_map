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
    Map.fetch(map, key)
  end

  defimpl Enumerable do
    def count(lazy_map) do
      {:ok, LazyMap.size(lazy_map)}
    end

    # def member?(lazy_map, val) do
    # end

    def slice(lazy_map) do
      {:ok, LazyMap.size(lazy_map), &Enumerable.List.slice(LazyMap.to_list(lazy_map), &1, &2)}
    end

    # def reduce(lazy_map, acc, fun) do
    #   lazy_map
    # end
  end
end
