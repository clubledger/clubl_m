defmodule ClubLMWeb.PageController do
  use ClubLMWeb, :controller

  def landing_page(conn, _params) do
    render(conn)
  end
end
