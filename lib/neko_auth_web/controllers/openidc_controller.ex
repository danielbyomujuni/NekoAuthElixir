defmodule NekoAuthWeb.OpenidcController do
  use Phoenix.Controller, formats: [:json]

  def jwks(conn, %{} = query_params) do
    # Read the public key file
    public_key_path = Path.join(:code.priv_dir(:neko_auth), "keys/public_key.pem")
    pem_content = File.read!(public_key_path)

    # Parse PEM to extract RSA components
    [rsa_entry] = :public_key.pem_decode(pem_content)
    rsa_public_key = :public_key.pem_entry_decode(rsa_entry)

    # Extract n and e from RSA public key and encode as base64url
    n = rsa_public_key |> elem(1) |> Base.url_encode64(padding: false)
    e = rsa_public_key |> elem(2) |> Base.url_encode64(padding: false)

    # Build JWKS response
    jwks = %{
      keys: [
        %{
          kty: "RSA",
          use: "sig",
          kid: "rsa1",
          alg: "RS256",
          n: n,
          e: e
        }
      ]
    }

    conn
    |> put_resp_content_type("application/json")
    |> json(jwks)
  end

  def config(conn, %{} = query_params) do
    host_name = System.get_env("HOST_NAME")

    config = %{
      issuer: host_name,
      authorization_endpoint: "#{host_name}/api/v2/authorize",
      token_endpoint: "#{host_name}/api/v2/token",
      userinfo_endpoint: "#{host_name}/api/v2/user",
      jwks_uri: "#{host_name}/.well-known/jwks.json",
      response_types_supported: ["code"],
      subject_types_supported: ["public"],
      id_token_signing_alg_values_supported: ["RS256"],
      scopes_supported: ["user.email", "user.identity", "user.avatar"],
      token_endpoint_auth_methods_supported: ["RS256"],
      claims_supported: ["email"],
      code_challenge_methods_supported: [],
      grant_types_supported: [
        "authorization_code",
        "refresh_token"
      ]
    }

    conn
    |> put_resp_content_type("application/json")
    |> put_status(200)
    |> json(config)
  end
end
