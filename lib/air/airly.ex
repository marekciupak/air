defmodule Air.Airly do
  use GenServer

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
end
