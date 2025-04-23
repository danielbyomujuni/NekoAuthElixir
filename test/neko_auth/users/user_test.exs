defmodule NekoAuth.Users.UserTest do
  use NekoAuth.DataCase, async: true

  alias NekoAuth.Users.User

  @valid_attrs %{
    email: "user@example.com",
    display_name: "Test User",
    user_name: "testuser",
    descriminator: 1234,
    password_hash: "hashed_password",
    date_of_birth: ~D[2000-01-01],
    email_verified: false
  }

  test "changeset with valid data is valid" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset missing required fields is invalid" do
    required_fields = ~w(email display_name user_name descriminator password_hash date_of_birth)a

    for field <- required_fields do
      attrs = Map.delete(@valid_attrs, field)
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert Enum.any?(errors_on(changeset), fn {f, _} -> f == field end)
    end
  end

  test "changeset casts only permitted fields" do
    attrs = Map.put(@valid_attrs, :admin, true)
    changeset = User.changeset(%User{}, attrs)

    assert Map.has_key?(changeset.changes, :email)
    refute Map.has_key?(changeset.changes, :admin)
  end
end
