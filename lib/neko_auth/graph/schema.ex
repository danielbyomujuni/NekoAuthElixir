defmodule NekoAuthWeb.Schema do
  use Absinthe.Schema
  import_types NekoAuthWeb.Schema.ContentTypes

  alias NekoAuth.Graph.Resolver

  query do

    @desc "Get all users"
    field :users, list_of(:user) do
      resolve &Resolver.list_users/3
    end

  end

end
