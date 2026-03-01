defmodule FleetTracking.Fleet do
  use Ash.Domain

  resources do
    resource FleetTracking.Fleet.Vehicle
    resource FleetTracking.Fleet.Driver
    resource FleetTracking.Fleet.LocationLog
  end
end
