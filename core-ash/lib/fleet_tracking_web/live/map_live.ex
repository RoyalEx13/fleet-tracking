defmodule FleetTrackingWeb.MapLive do
  use FleetTrackingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    locations_list = get_latest_locations()
    locations_map = Map.new(locations_list, fn loc -> {loc.gps_id, loc} end)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(FleetTracking.PubSub, "vehicles")
      Process.send_after(self(), :flush_buffer, 1000)
    end

    {:ok,
     socket
     |> assign(
       all_locations: locations_map,
       search_query: "",
       buffer: %{}
     )
     |> stream(:vehicles, locations_list)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    query = String.downcase(query)
    filtered = filter_locations(socket.assigns.all_locations, query)

    {:noreply,
     socket
     |> assign(search_query: query)
     |> push_event("update_vehicle_positions", %{locations: filtered})
     |> stream(:vehicles, filtered, reset: true)}
  end

  @impl true
  def handle_event("focus_vehicle", %{"id" => gps_id}, socket) do
    case socket.assigns.all_locations[gps_id] do
      nil -> {:noreply, socket}
      vehicle -> {:noreply, push_event(socket, "fly_to_vehicle", vehicle)}
    end
  end

  @impl true
  def handle_info({:update_location, data}, socket) do
    gps_id = data.gps_id
    existing_vehicle = socket.assigns.all_locations[gps_id]

    license_plate =
      cond do
        existing_vehicle -> existing_vehicle.license_plate
        data[:vehicle] -> data.vehicle.license_plate
        true -> "Unknown"
      end

    clean_data = %{
      id: gps_id,
      gps_id: gps_id,
      license_plate: license_plate,
      lat: if(is_struct(data.latitude), do: Decimal.to_float(data.latitude), else: data.latitude),
      lng:
        if(is_struct(data.longitude), do: Decimal.to_float(data.longitude), else: data.longitude),
      speed: if(is_struct(data.speed), do: Decimal.to_float(data.speed), else: data.speed || 0.0),
      updated_at: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    new_all_locations = Map.put(socket.assigns.all_locations, gps_id, clean_data)
    new_buffer = Map.put(socket.assigns.buffer, gps_id, clean_data)

    socket =
      if matches_search?(clean_data, socket.assigns.search_query) do
        stream_insert(socket, :vehicles, clean_data, at: 0)
      else
        stream_delete(socket, :vehicles, clean_data)
      end

    {:noreply, assign(socket, all_locations: new_all_locations, buffer: new_buffer)}
  end

  @impl true
  def handle_info(:flush_buffer, socket) do
    buffer = socket.assigns.buffer

    socket =
      if map_size(buffer) > 0 do
        push_event(socket, "update_vehicle_positions", %{locations: Map.values(buffer)})
      else
        socket
      end

    Process.send_after(self(), :flush_buffer, 1000)
    {:noreply, assign(socket, buffer: %{})}
  end

  defp matches_search?(vehicle, query) do
    query = String.downcase(query)
    String.contains?(String.downcase(vehicle.gps_id), query) or
      String.contains?(String.downcase(vehicle.license_plate || ""), query)
  end

  defp filter_locations(locations_map, query) do
    locations_map
    |> Map.values()
    |> Enum.filter(&matches_search?(&1, query))
  end

  defp get_latest_locations do
    FleetTracking.Fleet.LocationLog
    |> Ash.Query.for_read(:read)
    |> Ash.Query.load([:vehicle])
    |> Ash.read!()
    |> Enum.reject(&is_nil(&1.vehicle))
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    |> Enum.uniq_by(& &1.vehicle_id)
    |> Enum.map(fn log ->
      %{
        id: log.vehicle.gps_id,
        gps_id: log.vehicle.gps_id,
        license_plate: log.vehicle.license_plate,
        lat: if(is_struct(log.latitude), do: Decimal.to_float(log.latitude), else: log.latitude),
        lng: if(is_struct(log.longitude), do: Decimal.to_float(log.longitude), else: log.longitude),
        speed: if(is_struct(log.speed), do: Decimal.to_float(log.speed), else: log.speed || 0.0),
        updated_at: (log.inserted_at || DateTime.utc_now()) |> DateTime.to_iso8601()
      }
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-[100dvh] w-full bg-gray-100 font-sans overflow-hidden fixed inset-0">

      <aside class="w-80 bg-slate-900 shadow-2xl z-20 flex flex-col h-full flex-shrink-0">
        <div class="p-6 bg-slate-800 flex-shrink-0">
          <h1 class="text-white text-xl font-bold tracking-wider">FLEET CORE</h1>
          <p class="text-slate-400 text-xs">Real-time Tracking System</p>
        </div>

        <div class="p-4 border-b border-slate-700 flex-shrink-0">
          <form phx-change="search" onsubmit="return false;">
            <div class="relative">
              <input type="text" name="query" value={@search_query}
                placeholder="ค้นหารถ..."
                class="w-full bg-slate-800 text-slate-200 border-none rounded-lg pl-10 pr-4 py-2 focus:ring-2 focus:ring-blue-500 text-sm" />
            </div>
          </form>
        </div>

        <nav id="vehicle-list" phx-update="stream" class="flex-1 overflow-y-auto p-4 space-y-2 custom-scrollbar">
          <%= for {dom_id, vehicle} <- @streams.vehicles do %>
            <div id={dom_id} phx-click="focus_vehicle" phx-value-id={vehicle.id}
                class="p-3 bg-slate-800 hover:bg-slate-700 rounded-xl cursor-pointer transition-all border border-transparent hover:border-slate-600 group">
              <div class="flex items-center justify-between">
                <span class="text-slate-100 font-mono text-sm font-medium"><%= vehicle.license_plate %></span>
                <span class="h-2 w-2 rounded-full bg-green-500 animate-pulse"></span>
              </div>
              <div class="flex justify-between mt-2 text-[10px] uppercase tracking-tighter">
                <span class="text-slate-400">Lat: <%= Float.round(vehicle.lat, 4) %></span>
                <span id={"time-#{vehicle.id}"} class="text-blue-400 font-medium"
                      data-timestamp={vehicle.updated_at} phx-update="ignore">
                  กำลังคำนวณ...
                </span>
              </div>
            </div>
          <% end %>
        </nav>
      </aside>

      <main class="flex-1 flex flex-col h-full relative overflow-hidden">
        <header class="h-16 bg-white border-b border-gray-200 flex items-center px-8 justify-between z-10 flex-shrink-0">
          <div class="flex items-center space-x-4">
            <span class="text-sm font-medium text-gray-600 bg-gray-100 px-3 py-1 rounded-full">
              System Active
            </span>
          </div>
          <div class="text-sm font-bold text-slate-700 bg-blue-50 border border-blue-100 px-4 py-1.5 rounded-lg">
            Online: <%= map_size(@all_locations) %> Units
          </div>
        </header>

        <div id="map-wrapper" class="flex-1 relative w-full h-full overflow-hidden">
          <div id="map"
               phx-update="ignore"
               phx-hook="LeafletMap"
               data-locations={Jason.encode!(Map.values(@all_locations))}
               class="absolute inset-0">
          </div>
        </div>
      </main>
    </div>
    """
  end
end
