defmodule NekoAuthWeb.Schema.Services do
  use Absinthe.Schema
  import_types NekoAuthWeb.Schema.ContentTypes

  mutation do
    @desc "Create a Service"
    field :create_post, type: :post do
      arg :name, non_null(:string)
      arg :description, non_null(:string)
      arg :redirect_uris, list_of(:string)
      arg :scopes, list_of(:string)
      arg :application_type, non_null(:string)
      arg :email_restriction_type, :string
      arg :restricted_emails, list_of(:string)
      resolve &NekoAuthWeb.Graph.Resolvers.ServiceResolver.create_service/3
    end
  end

end
