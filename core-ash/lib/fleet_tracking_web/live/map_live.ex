defmodule FleetTrackingWeb.MapLive do
  use FleetTrackingWeb, :live_view
  alias FleetTracking.Fleet

  def mount(_params, _session, socket) do
    case Ash.read(Fleet.LocationLog) do
      {:ok, logs} ->
        locations = Enum.map(logs, fn log ->
          %{id: log.vehicle_id, lat: log.latitude, lng: log.longitude}
        end)
        {:ok, assign(socket, locations: locations)}
      _ ->
        {:ok, assign(socket, locations: [])}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 bg-gray-100 min-h-screen">
      <div class="max-w-7xl mx-auto bg-white rounded-xl shadow-lg p-4 overflow-hidden">
        <h1 class="text-2xl font-bold text-gray-800 mb-4 border-b pb-2">
          Fleet Live Tracking
        </h1>

        <div
          id="map-container"
          phx-update="ignore"
          phx-hook="LeafletMap"
          class="w-full rounded-lg border-2 border-gray-200"
          style="height: 600px; min-height: 600px;"
          data-locations={Jason.encode!(@locations)}>
        </div>
      </div>
    </div>
    """
  end
end
