defmodule Test.Support.WebServerMock do
  @moduledoc false
  use Plug.Router

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

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  get("/providers") do
    product_name = conn.params["product_name"]
    Plug.Conn.send_resp(conn, 200, Poison.encode!(@products[product_name]))
  end
end
