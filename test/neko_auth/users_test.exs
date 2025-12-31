defmodule NekoAuth.UsersTest do
alias NekoAuth.Domains.UserDomain
  use NekoAuth.DataCase, async: true

  alias NekoAuth.Users
  alias NekoAuth.Users.User

  @valid_attrs %{
    email: "users_utils_test@example.com",
    display_name: "Test User",
    user_name: "testuser",
    descriminator: 1234,
    password_hash: "hashed_pw",
    date_of_birth: ~D[2000-01-01],
    email_verified: false
  }

  defp create_user_fixture(attrs \\ %{}) do
    {:ok, user} = Users.create_user(Map.merge(@valid_attrs, attrs))
    user
  end

  describe "list_user/0" do
    test "returns all users" do
      user = create_user_fixture()
      assert Users.list_user() == [user]
    end
  end

  describe "get_user!/1" do
    test "returns the user by email" do
      user = create_user_fixture()
      assert UserDomain.get_user_by_email(user.email) == {:ok, user}
    end

    test "raises if user not found" do
      assert {:error, _} = UserDomain.get_user_by_email("nonexistent@example.com")
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == @valid_attrs.email
    end

    test "with invalid data returns error changeset" do
      assert {:error, changeset} = Users.create_user(%{})
      refute changeset.valid?
    end
  end

  describe "update_user/2" do
    test "updates the user with valid data" do
      user = create_user_fixture()
      assert {:ok, updated} = Users.update_user(user, %{display_name: "Updated"})
      assert updated.display_name == "Updated"
    end

    test "returns error with invalid data" do
      user = create_user_fixture()
      assert {:error, changeset} = Users.update_user(user, %{email: nil})
      refute changeset.valid?
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = create_user_fixture()
      assert {:ok, _} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserDomain.get_user_by_email(user.email) end
    end
  end

  describe "change_user/2" do
    test "returns a valid changeset" do
      user = create_user_fixture()
      changeset = Users.change_user(user)
      assert %Ecto.Changeset{} = changeset
    end
  end
end
