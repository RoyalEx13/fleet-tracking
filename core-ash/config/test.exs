import Config
config :fleet_tracking, Oban, testing: :manual
config :fleet_tracking, token_signing_secret: System.get_env("TOKEN_SIGNING_SECRET") || "32_RANDOM_CHARS_MINIMUM_FOR_SIGNING_SECRET_TEST"
config :bcrypt_elixir, log_rounds: 1
config :ash, policies: [show_policy_breakdowns?: true], disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
if url = System.get_env("DATABASE_URL") do
  config :fleet_tracking, FleetTracking.Repo,
    url: url,
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: System.schedulers_online() * 2
else
  config :fleet_tracking, FleetTracking.Repo,
    username: System.get_env("DATABASE_USER") || "postgres",
    password: System.get_env("DATABASE_PASSWORD") || "postgres",
    hostname: System.get_env("DATABASE_HOST") || "localhost",
    database: "fleet_tracking_test#{System.get_env("MIX_TEST_PARTITION")}",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: System.schedulers_online() * 2
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fleet_tracking, FleetTrackingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "64_RANDOM_CHARS_MINIMUM_FOR_SIGNING_SECRET_TEST_64_RANDOM_CHARS_MINIMUM_FOR_SIGNING_SECRET_TEST",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
