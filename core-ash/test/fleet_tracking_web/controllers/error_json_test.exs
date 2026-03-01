defmodule FleetTrackingWeb.ErrorJSONTest do
  use FleetTrackingWeb.ConnCase, async: true

  test "renders 404" do
    assert FleetTrackingWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert FleetTrackingWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
