# LazyMap

Data structure with the same public interface of a [Map](https://hexdocs.pm/elixir/Map.html) implementing the 
[Access](https://hexdocs.pm/elixir/Access.html) behaviour and the [Enumerable](https://hexdocs.pm/elixir/Enumerable.html)
protocol.

Difference with normal `map` is that their values are computed and cached when they are requested.
