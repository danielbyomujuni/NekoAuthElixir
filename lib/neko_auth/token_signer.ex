defmodule NekoAuth.TokenSigner do
  @moduledoc false

  def load_private_key do
    key = Path.join(:code.priv_dir(:neko_auth), "keys/private_key.pem")
    |> File.read!()
    #IO.inspect(key)
    Joken.Signer.create("RS256", %{"pem" => key})
  end

  def load_public_key do
    Path.join(:code.priv_dir(:neko_auth), "keys/public-key.pub")
    |> JOSE.JWK.from_pem_file()
  end
end
