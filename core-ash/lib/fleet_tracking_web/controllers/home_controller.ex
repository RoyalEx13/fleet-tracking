defmodule FleetTrackingWeb.HomeController do
  use FleetTrackingWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/admin")
  end
end
