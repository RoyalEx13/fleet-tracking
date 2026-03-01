defmodule FleetTracking.Fleet.LocationLog do
  use Ash.Resource,
    domain: FleetTracking.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshAdmin.Resource]

  postgres do
    table "location_logs"
    repo FleetTracking.Repo
  end

  json_api do
    type "location_log"
    routes do
      post :create
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :latitude, :float, allow_nil?: false
    attribute :longitude, :float, allow_nil?: false
    attribute :speed, :float
    timestamps()
  end

  relationships do
    belongs_to :vehicle, FleetTracking.Fleet.Vehicle do
      allow_nil? false
      attribute_type :uuid
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:latitude, :longitude, :speed, :vehicle_id]
    end
  end
end
