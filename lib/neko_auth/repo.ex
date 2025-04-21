defmodule NekoAuth.Repo do
  use Ecto.Repo,
    otp_app: :neko_auth,
    adapter: Ecto.Adapters.Postgres
end
