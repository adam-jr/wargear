defmodule Wargear.Endpoint do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json, Absinthe.Plug.Parser], json_decoder: Poison
  plug :match
  plug :dispatch
  
  plug Absinthe.Plug,
    schema: Wargear.Schema

  def init(options) do
    options
  end

  def start_link do
    # NOTE: This starts Cowboy listening on the default port of 4000
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: 8080)
  end

  forward "/api", to: Absinthe.Plug,
    schema: Wargear.Schema
  
  if Mix.env == :dev do
    forward "/graphiql", to: Absinthe.Plug.GraphiQL, schema: Wargear.Schema
    get "/ping", do: send_resp(conn, 200, "pong!")
  end
end