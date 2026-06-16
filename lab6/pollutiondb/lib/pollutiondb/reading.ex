defmodule Pollutiondb.Reading do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float

    belongs_to :station, Pollutiondb.Station
  end

  defp changeset(reading, changesmap) do
    reading
    |> cast(changesmap, [:date, :time, :type, :value, :station_id])
    |> validate_required([:date, :time, :type, :value, :station_id])
    |> unique_constraint([:station_id, :date, :time, :type], name: :readings_station_id_date_time_type_index)
  end

  def add(station, date, time, type, value) do
    Ecto.build_assoc(station, :readings)
    |> changeset(%{
      date: date,
      time: time,
      type: type,
      value: value
    })
    |> Pollutiondb.Repo.insert()
  end

  def add_now(station, type, value) do
    Ecto.build_assoc(station, :readings)
    |> changeset(%{
      date: Date.utc_today(),
      time: Time.utc_now() |> Time.truncate(:second),
      type: type,
      value: value
    })
    |> Pollutiondb.Repo.insert()
  end

  def find_by_date(date) do
    Ecto.Query.from(r in Pollutiondb.Reading, where: r.date == ^date)
    |> Pollutiondb.Repo.all()
  end
end