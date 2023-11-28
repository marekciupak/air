defmodule Air.Db.Series.Weather do
  use Instream.Series

  series do
    measurement("weather")

    field(:from_date_time)
    field(:till_date_time)
    field(:pm1)
    field(:pm25)
    field(:pm10)
    field(:pressure)
    field(:humidity)
    field(:temperature)
    field(:wind_speed)
    field(:wind_bearing)
  end
end
