defmodule Air.TempHum do
  use GenServer

  alias Circuits.I2C

  @factor Float.pow(2.0, -20)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_state) do
    case I2C.open("i2c-1") do
      {:ok, ref} ->
        schedule_measurement()
        {:ok, ref}

      {:error, _} ->
        {:ok, nil}
    end
  end

  @impl true
  def handle_info(:measure, ref) do
    case trigger_measurement(ref) do
      :ok -> schedule_reading()
      {:error, _error} -> nil
    end

    schedule_measurement()

    {:noreply, ref}
  end

  @impl true
  def handle_info(:read, ref) do
    case read_measurement(ref) do
      {:ok, data} -> process_data(data)
      {:error, _error} -> nil
    end

    {:noreply, ref}
  end

  defp schedule_measurement do
    Process.send_after(self(), :measure, :timer.minutes(1))
  end

  defp schedule_reading do
    Process.send_after(self(), :read, :timer.seconds(1))
  end

  defp trigger_measurement(ref) do
    I2C.write(ref, 0x38, <<0xAC, 0x33, 0x00>>)
  end

  defp read_measurement(ref) do
    I2C.read(ref, 0x38, 7)
  end

  defp process_data(<<0::size(1), _::size(3), 1::size(1), _::size(3), data::bits-size(40), _crc::bits-size(8)>>) do
    process_measurement(data)
  end

  defp process_data(_), do: nil

  defp process_measurement(<<hum::size(20), temp::size(20)>>) do
    process_measurement(hum * @factor * 100, temp * @factor * 200 - 50)
  end

  defp process_measurement(hum, temp) when is_float(hum) and is_float(temp) do
    File.write!("data/temp_hum.csv", "#{timestamp()},#{hum},#{temp}\r\n", [:append])
  end

  defp timestamp do
    DateTime.utc_now() |> DateTime.to_string()
  end
end
