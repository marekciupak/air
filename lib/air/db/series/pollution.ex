defmodule Air.Db.Series.Pollution do
  use Instream.Series

  series do
    measurement("pollution")

    field(:pm25)
    field(:pm10)
  end
end
