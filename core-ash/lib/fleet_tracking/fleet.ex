defmodule FleetTracking.Fleet do
  use Ash.Domain,extensions: [AshAdmin.Domain,AshJsonApi.Domain]

  admin do
    show? true
  end

  json_api do
    routes do
      base_route "/location_logs", FleetTracking.Fleet.LocationLog do
        index :read
        post :create
      end
    end
  end

  resources do
    resource FleetTracking.Fleet.Vehicle
    resource FleetTracking.Fleet.Driver
    resource FleetTracking.Fleet.LocationLog
  end
end
