defmodule Test.Support.SerializeLazy do
  @moduledoc false
  def generate_lazy do
    LazyMap.new(%{
      providers: fn ->
        {:ok, %{body: json}} =
          HTTPoison.get("http://localhost:4004/providers?product_name=Chocolate")

        Poison.decode!(json)
      end
    })
  end
end
