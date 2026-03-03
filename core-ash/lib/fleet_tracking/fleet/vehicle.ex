defmodule FleetTracking.Fleet.Vehicle do
  use Ash.Resource,
    domain: FleetTracking.Fleet,
    extensions: [AshJsonApi.Resource, AshAdmin.Resource],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "vehicles"
    repo FleetTracking.Repo
  end

  relationships do
    belongs_to :driver, FleetTracking.Fleet.Driver
  end

  attributes do
    uuid_primary_key :id
    attribute :license_plate, :string, allow_nil?: false
    attribute :model, :string

    attribute :status, :atom do
      constraints [one_of: [:active, :maintenance, :inactive]]
      default :active
    end

    attribute :driver_id, :uuid

    attribute :gps_id, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  identities do
    identity :unique_gps_id, [:gps_id]
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:gps_id, :license_plate, :model, :status]
    end

    update :update do
      primary? true
      accept [:gps_id, :license_plate, :model, :status]
    end
  end
end
