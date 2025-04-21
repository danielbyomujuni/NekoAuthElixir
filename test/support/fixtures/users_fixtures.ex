defmodule NekoAuth.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NekoAuth.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        date_of_birth: ~U[2025-04-20 15:12:00Z],
        descriminator: 42,
        display_name: "some display_name",
        email: "some email",
        email_verified: true,
        password_hash: "some password_hash",
        user_name: "some user_name"
      })
      |> NekoAuth.Users.create_user()

    user
  end
end
