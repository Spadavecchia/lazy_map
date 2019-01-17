defmodule Test.Support.ServerMock do
  @moduledoc """
  Mock an OTP service
  """
  use GenServer
  alias Test.Support.DBMock

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def providers(product_name) do
    GenServer.call(__MODULE__, {:providers, product_name})
  end

  def init(_), do: {:ok, DBMock.products}

  def handle_call({:providers, product_name}, _from, products) do
    providers = products[product_name]
    {:reply, providers, products}
  end
end
