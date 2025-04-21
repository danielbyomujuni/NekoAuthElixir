defmodule Demo.Graph.Resolver do
  def random_widget(_parent, _args, _ctx) do
    {:ok, %{id: Ecto.UUID.generate()}}
  end
end
