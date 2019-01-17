defmodule Test.Support.WebServerApplication do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Test.Support.WebServerMock,
        options: [port: 4004]
      )
    ]

    opts = [strategy: :one_for_one, name: Test.Support.WebServerMock]
    Supervisor.start_link(children, opts)
  end
end
