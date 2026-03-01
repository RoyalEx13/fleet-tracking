defmodule FleetTracking.Fleet.Driver do
  use Ash.Resource,
    domain: FleetTracking.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshAdmin.Resource]

  postgres do
    table "drivers"
    repo FleetTracking.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :full_name, :string, allow_nil?: false
    attribute :phone_number, :string
    attribute :license_number, :string
    timestamps()
  end

  relationships do
    has_many :vehicles, FleetTracking.Fleet.Vehicle
  end

  actions do
    defaults [:read, :destroy, :create, :update]
  end
end
