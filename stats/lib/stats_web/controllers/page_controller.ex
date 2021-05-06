defmodule StatsWeb.PageController do
  use StatsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
