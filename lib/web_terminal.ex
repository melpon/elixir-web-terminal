defmodule WebTerminal do
end

defmodule WebTerminal.Handler do
  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(_state) do
    {:ok, pid, ospid} = :exec.run('bash', [:pty, :stdin, :stdout, :stderr, :monitor])
    state = %{pid: pid,
              ospid: ospid}
    {:ok, state}
  end

  def websocket_handle({:text, data}, state) do
    js = Poison.decode!(data)
    case js |> Map.fetch!("type") do
      "input" -> :exec.send(state.ospid, js |> Map.fetch!("data"))
      "resize" -> :exec.winsz(state.ospid, js |> Map.fetch!("row"), js |> Map.fetch!("col"))
    end
    {:ok, state}
  end
  def websocket_handle(_frame, state) do
    {:ok, state}
  end

  defp assert(condition) do
    unless condition do
      raise "assertion failed"
    end
  end

  def websocket_info({:stdout, ospid, result}, state) do
    assert(ospid == state.ospid)
    js = Poison.encode!(%{type: "output", data: result})
    {:reply, {:text, js}, state}
  end
  def websocket_info({:stderr, ospid, result}, state) do
    assert(ospid == state.ospid)
    js = Poison.encode!(%{type: "output", data: result})
    {:reply, {:text, js}, state}
  end
  def websocket_info({:"DOWN", ospid, :process, pid, {:exit_status, exit_status}}, state) do
    assert(ospid == state.ospid and pid == state.pid)
    IO.puts("Elixir got exit: #{inspect exit_status}")
    {:stop, state}
  end
  def websocket_info(message, state) do
    IO.puts("Elixir got message: #{inspect message}")
    {:ok, state}
  end
end
