defmodule FleetTrackingWeb.DashboardLive do
  use FleetTrackingWeb, :live_view
  alias FleetTracking.Fleet

  def mount(_params, _session, socket) do
    case Ash.read(FleetTracking.Fleet.LocationLog) do
      {:ok, logs} ->
        {:ok, assign(socket, :logs, logs)}
      _ ->
        {:ok, assign(socket, :logs, [])}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <h1 class="text-2xl font-bold mb-6">Real-time Dashboard</h1>
      <table class="w-full border-collapse">
        <thead class="bg-gray-100">
          <tr>
            <th class="p-3 text-left">Vehicle ID</th>
            <th class="p-3 text-right">Lat</th>
            <th class="p-3 text-right">Long</th>
            <th class="p-3 text-right">Speed</th>
          </tr>
        </thead>
        <tbody>
          <%= for log <- @logs do %>
            <tr class="border-b">
              <td class="p-3 font-mono text-sm"><%= log.vehicle_id %></td>
              <td class="p-3 text-right"><%= log.latitude %></td>
              <td class="p-3 text-right"><%= log.longitude %></td>
              <td class="p-3 text-right"><%= log.speed %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
