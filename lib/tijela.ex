defmodule Tijela do
  use Application

  @impl Application
  def start(_, _) do
    children = [
      Tijela.Repo
    ]

    Supervisor.start_link(children, name: Tijela.Supervisor, strategy: :one_for_one)
  end
end
