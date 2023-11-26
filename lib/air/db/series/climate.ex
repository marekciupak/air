defmodule Air.Db.Series.Climate do
  use Instream.Series

  series do
    measurement("climate")

    field(:temperature)
    field(:humidity)
  end
end
