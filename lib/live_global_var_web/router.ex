defmodule LiveGlobalVarWeb.Router do
  use LiveGlobalVarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, {LiveGlobalVarWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :put_global_var
  end

  scope "/", LiveGlobalVarWeb do
    pipe_through :browser

    live_session :global_var, on_mount: [{__MODULE__, :mount_global_var}] do
      live "/", HomeLive
      live "/view1", View1Live
      live "/view2", View2Live
    end
  end

  # Plug to persist the value from them params if exists
  def put_global_var(%{params: %{"global_var" => value}} = conn, _) do
    put_session(conn, :global_var, value)
  end

  def put_global_var(conn, _), do: conn

  # On mount to build the select options and assign the value from the session
  def on_mount(:mount_global_var, _params, session, socket) do
    global_var = Map.get(session, "global_var", nil)

    socket =
      socket
      |> Phoenix.Component.assign_new(:options, fn ->
        [{"", nil}, {"Opt1", "1"}, {"Opt2", "2"}, {"Opt3", "3"}]
      end)
      |> Phoenix.Component.assign_new(:global_var, fn -> global_var end)

    {:cont, socket}
  end
end
