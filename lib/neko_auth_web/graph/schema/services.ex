defmodule NekoAuthWeb.Schema.Services do
  use Absinthe.Schema.Notation

  alias NekoAuthWeb.Graph.Resolvers.ServiceResolver

  scalar :date_time do
    parse(fn input ->
      case DateTime.from_iso8601(input.value) do
        {:ok, datetime, _} -> {:ok, datetime}
        _ -> :error
      end
    end)

    serialize(fn date ->
      DateTime.to_iso8601(date)
    end)
  end

  input_object :create_service_input do
    field :name, non_null(:string)
    field :description, non_null(:string)
    field :url, non_null(:string)
    field :icon_url, :string
    field :redirect_uris, non_null(list_of(non_null(:string)))
    field :scopes, non_null(list_of(non_null(:string)))
    field :application_type, non_null(:string)
    field :status, non_null(:boolean)
    field :email_restriction_type, non_null(:string)
    field :restricted_emails, non_null(list_of(non_null(:string)))
  end

  object :service do
    field :id, :id
    field :name, :string
    field :description, :string
    field :url, :string
    field :icon_url, :string
    field :created_at, :date_time
    field :updated_at, :date_time
    field :client_secret, :string
    field :redirect_uris, list_of(:string)
    field :scopes, list_of(:string)
    field :application_type, :string
    field :status, :boolean
    field :email_restriction_type, :string
    field :restricted_emails, list_of(:string)
    field :owner_email, :string
  end


  object :create_service_mutations do
    field :create_service, type: :service do
      arg :input, non_null(:create_service_input)
      resolve &ServiceResolver.create_service/3
    end
  end

end
