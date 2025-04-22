defmodule AuthorizeDomain do
  @moduledoc """
  Represents the validated OAuth2 authorization request domain.

  ## Author
  Daniel Byomujuni <danielbyomujuni@nekosyndicate.com>
  """

  defstruct [
    :response_type,
    :client_id,
    :redirect_uri,
    :scope,
    :state,
    :nonce,
    :code_challenge,
    :code_challenge_method
  ]

  alias DomainValidator
  alias Result

  @doc """
  Constructs an `AuthorizeDomain` struct from a raw map of params with validation.
  """
  def from_object(params) when is_map(params) do
    with true <- DomainValidator.new(params["response_type"]) |> DomainValidator.validate(nullable: false, exists_in: ["code"]),
         true <- DomainValidator.new(to_number(params["client_id"])) |> DomainValidator.validate(nullable: false, is_number: true),
         true <- DomainValidator.new(params["redirect_uri"]) |> DomainValidator.validate(nullable: false, valid_url: true),
         true <- DomainValidator.new(params["scope"]) |> DomainValidator.validate(nullable: false),
         true <- DomainValidator.new(params["state"]) |> DomainValidator.validate(nullable: true),
         true <- DomainValidator.new(params["nonce"]) |> DomainValidator.validate(nullable: true),
         true <- DomainValidator.new(params["code_challenge"]) |> DomainValidator.validate(nullable: true),
         true <- DomainValidator.new(params["code_challenge_method"]) |> DomainValidator.validate(nullable: true, exists_in: ["plain", "S256"]),
         true <- (Map.has_key?(params, "code_challenge") == Map.has_key?(params, "code_challenge_method")) do
      Result.from(%__MODULE__{
        response_type: params["response_type"],
        client_id: to_number(params["client_id"]),
        redirect_uri: params["redirect_uri"],
        scope: params["scope"],
        state: params["state"],
        nonce: params["nonce"],
        code_challenge: params["code_challenge"],
        code_challenge_method: params["code_challenge_method"]
      })
    else
      false -> Result.err("GENERIC ERROR")
      value when is_boolean(value) -> Result.err("Invalid parameters")
    end
  end

  @doc """
  Parses a `URI.query` string into an `AuthorizeDomain` via `from_object/1`.
  """
  def from_query_string(query_string) do
    query_string
    |> URI.decode_query()
    |> from_object()
  end

  @doc """
  Converts the struct into a query param map.
  """
  def to_query_params(%__MODULE__{} = auth) do
    %{}
    |> Map.put("response_type", auth.response_type)
    |> Map.put("client_id", Integer.to_string(auth.client_id))
    |> Map.put("redirect_uri", auth.redirect_uri)
    |> Map.put("scope", auth.scope)
    |> maybe_put("state", auth.state)
    |> maybe_put("nonce", auth.nonce)
    |> maybe_put("code_challenge", auth.code_challenge)
    |> maybe_put("code_challenge_method", auth.code_challenge_method)
  end

  @doc """
  Creates a full URL using a base and the struct’s query parameters.
  """
  def create_url(%__MODULE__{} = auth, base_url) do
    %URI{URI.parse(base_url) | query: URI.encode_query(to_query_params(auth))}
    |> URI.to_string()
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, val), do: Map.put(map, key, val)

  defp to_number(nil), do: nil
  defp to_number(str) when is_binary(str) do
    case Integer.parse(str) do
      {num, ""} -> num
      _ -> str
    end
  end
  defp to_number(val), do: val
end
