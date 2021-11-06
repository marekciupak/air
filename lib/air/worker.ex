defmodule Air.Worker do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(state) do
    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, "/dev/serial0", speed: 9600, active: true, framing: Air.Circuits.Framing)

    {:ok, state}
  end

  @impl true
  def handle_info({:circuits_uart, _, msg}, state) do
    timestamp = DateTime.to_string(DateTime.utc_now())
    msg = Base.encode16(msg)
    File.write!("data.txt", "#{timestamp} #{msg}\n", [:append])

    {:noreply, state}
  end
end
