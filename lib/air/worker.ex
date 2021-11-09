defmodule Air.Worker do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(state) do
    Circuits.UART.open(:uart, "/dev/serial0", speed: 9600, active: true, framing: Air.Circuits.Framing)

    {:ok, state}
  end

  @impl true
  def handle_info({:circuits_uart, _, msg}, state) do
    File.write!("data.csv", csv_line(msg), [:append])

    {:noreply, state}
  end

  defp csv_line(msg) do
    timestamp = DateTime.utc_now() |> DateTime.to_string()
    "#{timestamp},#{Base.encode16(msg)},#{pm(msg)}\r\n"
  end

  defp pm(<<170, 192, pm25::binary-size(2), pm10::binary-size(2), _::binary-size(3), 171>>) do
    [pm25, pm10]
    |> Enum.map(fn bin ->
      :binary.decode_unsigned(bin, :little)
      |> Kernel./(10)
      |> Float.to_string
    end)
    |> Enum.join(",")
  end

  defp pm(_), do: ","
end
