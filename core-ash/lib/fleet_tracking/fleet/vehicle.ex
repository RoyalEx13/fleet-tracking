defmodule FleetTracking.Fleet.Vehicle do
  use Ash.Resource,
    domain: FleetTracking.Fleet,
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
    timestamps()
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:license_plate, :model, :status]
    end

    update :update do
      accept [:license_plate, :model, :status]
    end
  end
end
