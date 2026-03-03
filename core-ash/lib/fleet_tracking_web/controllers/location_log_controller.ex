defmodule FleetTrackingWeb.LocationLogController do
  use FleetTrackingWeb, :controller

  def create(conn, params) do
    attrs = %{
      latitude: to_float(params["latitude"] || params["lat"]),
      longitude: to_float(params["longitude"] || params["lon"]),
      speed: to_float(params["speed"]),
      gps_id: params["gps_id"] || params["id"]
    }

    case FleetTracking.Fleet.LocationLog
         |> Ash.Changeset.for_create(:create, attrs)
         |> Ash.create() do
      {:ok, _result} ->
        conn |> put_status(:created) |> json(%{status: "ok"})

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "--- FINAL DEBUG ERROR ---")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error"})
    end
  end

  defp to_float(val) when is_binary(val), do: String.to_float(val)
  defp to_float(val) when is_number(val), do: val / 1
  defp to_float(_), do: 0.0
end
