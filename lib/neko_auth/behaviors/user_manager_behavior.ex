defmodule NekoAuth.UserManagerBehavior do
  @callback register_new_user(map()) :: {:ok, any()} | {:error, any()}
  @callback user_from_login(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  @callback create_refresh_token(any()) :: String.t()
  @callback create_access_token(any()) :: String.t()
  @callback generate_auth_code(any()) :: String.t()
end
