defmodule FleetTracking.Fleet.LocationLog do
  use Ash.Resource,
    domain: FleetTracking.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshAdmin.Resource]

  postgres do
    table("location_logs")
    repo(FleetTracking.Repo)
  end

  json_api do
    type("location_log")

    routes do
      post(:create)
    end
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:latitude, :float, allow_nil?: false)
    attribute(:longitude, :float, allow_nil?: false)
    attribute(:speed, :float)
    timestamps()
  end

  relationships do
    belongs_to :vehicle, FleetTracking.Fleet.Vehicle do
      allow_nil?(false)
      attribute_type(:uuid)
    end
  end

  actions do
    defaults([:read])

    create :create do
      primary?(true)
      accept([:latitude, :longitude, :speed])

      argument(:gps_id, :string, allow_nil?: false)

      change(
        manage_relationship(:gps_id, :vehicle,
          type: :append_and_remove,
          on_lookup: :relate,
          on_no_match: :error,
          use_identities: [:unique_gps_id],
          value_is_key: :gps_id
        )
      )

      change(fn changeset, _context ->
        Ash.Changeset.after_action(changeset, fn _changeset, result ->
          result = Ash.load!(result, [:vehicle])

          payload = %{
            id: result.vehicle.gps_id,
            gps_id: result.vehicle.gps_id,
            latitude: result.latitude,
            longitude: result.longitude,
            speed: if(result.speed, do: result.speed, else: 0.0),
            vehicle: result.vehicle
          }

          Phoenix.PubSub.broadcast(
            FleetTracking.PubSub,
            "vehicles",
            {:update_location, payload}
          )

          {:ok, result}
        end)
      end)
    end
  end
end
