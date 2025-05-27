defmodule NekoAuthWeb.Schema do
  use Absinthe.Schema
  import_types NekoAuthWeb.Schema.Services
  import_types NekoAuthWeb.Schema.ContentTypes


  alias NekoAuth.Graph.Resolver

  query do
    import_fields :service_query

    @desc "Get all users"
    field :users, list_of(:user) do
      resolve &Resolver.list_users/3
    end
  end

  mutation do
    import_fields :service_mutations

    @desc "Edit a user"
    field :update_user, type: :user do
      arg :display_name, :string
      arg :image, :binary

      resolve &Resolver.update_user/3
    end

  end

end
