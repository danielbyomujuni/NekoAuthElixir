defmodule NekoAuth.TokenSigner do
  @moduledoc false

  def load_private_key do
    Path.join(:code.priv_dir(:neko_auth), "keys/private_key.pem")
    |> File.read!()
    |> JOSE.JWK.from_pem()
  end

  def load_public_key do
    Path.join(:code.priv_dir(:neko_auth), "keys/public_key.pem")
    |> File.read!()
    |> JOSE.JWK.from_pem()
  end
end
