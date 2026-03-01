defmodule FleetTracking.Accounts do
  use Ash.Domain, otp_app: :fleet_tracking, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource FleetTracking.Accounts.Token
    resource FleetTracking.Accounts.User
    resource FleetTracking.Accounts.ApiKey
  end
end
