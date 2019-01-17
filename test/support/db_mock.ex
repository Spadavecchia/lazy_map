defmodule Test.Support.DBMock do
  @moduledoc false
  @products %{
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

  def providers(product_name), do: @products[product_name]
  def products, do: @products
end
