defmodule WebTerminal.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    dispatch = :cowboy_router.compile([
        {:_, [{"/websocket", WebTerminal.Handler, []},
              {"/", :cowboy_static, {:priv_file, :web_terminal, "static/index.html"}},
              {"/static/[...]", :cowboy_static, {:priv_dir, :web_terminal, "static"}}]}
    ])
    {:ok, _} = :cowboy.start_clear(:web_terminal_http_listener,
                                   100,
                                   [{:port, 8080}],
                                   %{env: %{dispatch: dispatch}})

    children = [
    ]

    opts = [strategy: :one_for_one, name: WebTerminal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
