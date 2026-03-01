defmodule FleetTracking.Fleet.LocationLog do
  use Ash.Resource,
    domain: FleetTracking.Fleet,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "location_logs"
    repo FleetTracking.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :latitude, :float, allow_nil?: false
    attribute :longitude, :float, allow_nil?: false
    attribute :speed, :float
    timestamps()
  end

  relationships do
    belongs_to :vehicle, FleetTracking.Fleet.Vehicle, allow_nil?: false
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:latitude, :longitude, :speed, :vehicle_id]
    end
  end
end
