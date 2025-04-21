defmodule Demo.Graph.Schema do
  use Absinthe.Schema

  alias Demo.Graph.Resolver

  object :widget do
    field :id, :string
  end

  query do
    field :random_widget, :widget do
      resolve(&Resolver.random_widget/3)
    end
  end
end
