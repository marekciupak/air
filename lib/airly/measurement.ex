defmodule Airly.Measurement do
  alias Airly.{Measurement, Values}

  @enforce_keys [:from_date_time, :till_date_time, :values]
  defstruct [:from_date_time, :till_date_time, :values]

  def build(measurement) do
    {:ok, from_date_time, 0} = Map.fetch!(measurement, "fromDateTime") |> DateTime.from_iso8601()
    {:ok, till_date_time, 0} = Map.fetch!(measurement, "tillDateTime") |> DateTime.from_iso8601()

    %Measurement{
      from_date_time: from_date_time,
      till_date_time: till_date_time,
      values: Values.build(Map.fetch!(measurement, "values"))
    }
  end
end
