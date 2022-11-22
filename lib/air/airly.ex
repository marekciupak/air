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

    measure(config)
    {:ok, config}
  end

  @impl true
  def handle_info(:measure, config) do
    measure(config)

    {:noreply, config}
  end

  defp schedule_measurement do
    Process.send_after(self(), :measure, :timer.minutes(15))
  end

  defp measure(%{api_key: api_key, lat: lat, lng: lng}) do
    Airly.get_current_measurements(api_key: api_key, lat: lat, lng: lng)
    |> process_measurement()

    schedule_measurement()
  end

  defp process_measurement(measurement) do
    data =
      [
        measurement |> Map.fetch!(:from_date_time) |> DateTime.to_string(),
        measurement |> Map.fetch!(:till_date_time) |> DateTime.to_string(),
        measurement |> Map.fetch!(:values) |> Map.fetch!(:pm1),
        measurement |> Map.fetch!(:values) |> Map.fetch!(:pm25),
        measurement |> Map.fetch!(:values) |> Map.fetch!(:pm10),
        measurement |> Map.fetch!(:values) |> Map.fetch!(:pressure),
        measurement |> Map.fetch!(:values) |> Map.fetch!(:humidity),
        measurement |> Map.fetch!(:values) |> Map.fetch!(:temperature)
      ]
      |> Enum.join(",")

    File.write!("data/airly.csv", "#{data}\r\n", [:append])
  end
end
