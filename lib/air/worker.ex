defmodule Air.Worker do
  use GenServer

  alias Air.Db.Series, as: DbSeries

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(state) do
    :ok = Circuits.UART.open(:uart, "/dev/serial0", speed: 9600, active: true, framing: Air.Circuits.Framing)

    {:ok, state}
  end

  @impl true
  def handle_info({:circuits_uart, _, msg}, state) do
    timestamp = DateTime.utc_now()
    [pm25, pm10] = pm(msg)

    write_to_file(timestamp, msg, pm25, pm10)
    write_to_db(timestamp, pm25, pm10)

    {:noreply, state}
  end

  defp pm(<<170, 192, pm25::binary-size(2), pm10::binary-size(2), _::binary-size(3), 171>>) do
    [pm25, pm10]
    |> Enum.map(fn bin ->
      :binary.decode_unsigned(bin, :little)
      |> Kernel./(10)
    end)
  end

  defp pm(_), do: [nil, nil]

  defp write_to_file(timestamp, msg, pm25, pm10) do
    pm25 = Float.to_string(pm25)
    pm10 = Float.to_string(pm10)
    File.write!("data/measurements.csv", csv_line(timestamp, msg, pm25, pm10), [:append])
  end

  defp csv_line(timestamp, msg, pm25, pm10) do
    "#{DateTime.to_string(timestamp)},#{Base.encode16(msg)},#{pm25},#{pm10}\r\n"
  end

  def write_to_db(timestamp, pm25, pm10) do
    :ok =
      Air.Db.Connection.write(%DbSeries.Pollution{
        fields: %DbSeries.Pollution.Fields{
          pm25: pm25,
          pm10: pm10
        },
        timestamp: DateTime.to_unix(timestamp, :nanosecond)
      })
  end
end
