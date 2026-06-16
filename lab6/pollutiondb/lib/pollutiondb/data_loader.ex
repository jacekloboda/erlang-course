defmodule Pollutiondb.DataLoader do
  def load_data(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
    |> Enum.each(&insert_record/1)
  end

  defp parse_line(line) do
    [datetime, type, val, id, name, coords] =
      line
      |> String.trim()
      |> String.split(";")

    %{
      datetime:
        datetime
        |> NaiveDateTime.from_iso8601!()
        |> NaiveDateTime.to_erl(),
      name: "#{id} #{name}",
      type: type,
      value: val |> String.to_float(),
      location:
        coords
        |> String.split(",")
        |> Enum.map(&String.to_float(&1))
        |> List.to_tuple()
    }
  end

  defp insert_record(parsed_data) do
    %{
      datetime: {{year, month, day}, {hour, minute, second}},
      name: name,
      type: type,
      value: value,
      location: {lon, lat}
    } = parsed_data

    {:ok, date} = Date.new(year, month, day)
    {:ok, time} = Time.new(hour, minute, second)

    station = case Pollutiondb.Station.find_by_name(name) do
      [existing] -> existing
      [] ->
        {:ok, new_station} = Pollutiondb.Station.add(name, lon, lat)
        new_station
    end

    case Pollutiondb.Reading.add(station, date, time, type, value) do
      {:ok, _reading} -> :ok
      {:error, _changeset} -> :error
    end
  end
end