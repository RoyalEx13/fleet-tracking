defmodule FleetTrackingWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [
      FleetTracking.Fleet
    ],
    open_api: "/open_api"
end
