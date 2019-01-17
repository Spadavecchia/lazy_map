defmodule Test.Support.WebServerMock do
  @moduledoc false
  use Plug.Router
  alias Test.Support.DBMock

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  get("/providers") do
    product_name = conn.params["product_name"]
    Plug.Conn.send_resp(conn, 200, Poison.encode!(DBMock.providers(product_name)))
  end
end
