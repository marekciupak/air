defmodule Air.Airly do
  use GenServer

  alias Air.Db.Series, as: DbSeries

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_) do
    config = %{
      api_key: Application.fetch_env!(:air, :airly_api_key),
      lat: Application.fetch_env!(:air, :lat) |> String.to_float(),
      lng: Application.fetch_env!(:air, :lng) |> String.to_float()
    }

    schedule_measurement()

    {:ok, config}
  end

  defp schedule_measurement do
    Process.send_after(self(), :measure, :timer.minutes(15))
  end

  @impl true
  def handle_info(:measure, config = %{api_key: api_key, lat: lat, lng: lng}) do
    Airly.get_current_measurements(api_key: api_key, lat: lat, lng: lng)
    |> process_measurement()

    schedule_measurement()

    {:noreply, config}
  end

  defp process_measurement(measurement) do
    from_date_time = Map.fetch!(measurement, :from_date_time)
    till_date_time = Map.fetch!(measurement, :till_date_time)
    data = Map.fetch!(measurement, :values)

    write_to_file(from_date_time, till_date_time, data)
    write_to_db(from_date_time, till_date_time, data)
  end

  defp write_to_file(from_date_time, till_date_time, data) do
    from_date_time = DateTime.to_string(from_date_time)
    till_date_time = DateTime.to_string(till_date_time)

    data =
      [
        Map.fetch!(data, :pm1),
        Map.fetch!(data, :pm25),
        Map.fetch!(data, :pm10),
        Map.fetch!(data, :pressure),
        Map.fetch!(data, :humidity),
        Map.fetch!(data, :temperature),
        Map.fetch!(data, :wind_speed),
        Map.fetch!(data, :wind_bearing)
      ]
      |> Enum.join(",")

    File.write!("data/airly.csv", "#{from_date_time},#{till_date_time},#{data}\r\n", [:append])
  end

  def write_to_db(from_date_time, till_date_time, data) do
    period = DateTime.diff(till_date_time, from_date_time)
    timestamp = DateTime.add(from_date_time, trunc(period / 2), :second)

    :ok =
      Air.Db.Connection.write(%DbSeries.Weather{
        fields: %DbSeries.Weather.Fields{
          from_date_time: DateTime.to_unix(from_date_time, :nanosecond),
          till_date_time: DateTime.to_unix(till_date_time, :nanosecond),
          pm1: Map.fetch!(data, :pm1),
          pm25: Map.fetch!(data, :pm25),
          pm10: Map.fetch!(data, :pm10),
          pressure: Map.fetch!(data, :pressure),
          humidity: Map.fetch!(data, :humidity),
          temperature: Map.fetch!(data, :temperature),
          wind_speed: Map.fetch!(data, :wind_speed),
          wind_bearing: Map.fetch!(data, :wind_bearing)
        },
        timestamp: DateTime.to_unix(timestamp, :nanosecond)
      })
  end
end
