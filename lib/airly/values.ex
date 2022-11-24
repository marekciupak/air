defmodule Airly.Values do
  alias Airly.Values

  @enforce_keys [:pm1, :pm25, :pm10, :pressure, :humidity, :temperature, :wind_speed, :wind_bearing]
  defstruct [:pm1, :pm25, :pm10, :pressure, :humidity, :temperature, :wind_speed, :wind_bearing]

  def build(_values, acc \\ %{})

  def build([%{"name" => name, "value" => value} | rest], acc) do
    build(rest, Map.put(acc, name, value))
  end

  def build([], values) do
    %Values{
      pm1: Map.fetch!(values, "PM1"),
      pm25: Map.fetch!(values, "PM25"),
      pm10: Map.fetch!(values, "PM10"),
      pressure: Map.fetch!(values, "PRESSURE"),
      humidity: Map.fetch!(values, "HUMIDITY"),
      temperature: Map.fetch!(values, "TEMPERATURE"),
      wind_speed: Map.fetch!(values, "WIND_SPEED"),
      wind_bearing: Map.fetch!(values, "WIND_BEARING")
    }
  end
end
