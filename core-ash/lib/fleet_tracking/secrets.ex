defmodule FleetTracking.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        FleetTracking.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:fleet_tracking, :token_signing_secret)
  end
end
