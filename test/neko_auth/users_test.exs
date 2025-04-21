defmodule NekoAuth.UsersTest do
  use NekoAuth.DataCase

  alias NekoAuth.Users

  describe "user" do
    alias NekoAuth.Users.User

    import NekoAuth.UsersFixtures

    @invalid_attrs %{email: nil, display_name: nil, user_name: nil, descriminator: nil, password_hash: nil, date_of_birth: nil, email_verified: nil}

    test "list_user/0 returns all user" do
      user = user_fixture()
      assert Users.list_user() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some email", display_name: "some display_name", user_name: "some user_name", descriminator: 42, password_hash: "some password_hash", date_of_birth: ~U[2025-04-20 15:12:00Z], email_verified: true}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.display_name == "some display_name"
      assert user.user_name == "some user_name"
      assert user.descriminator == 42
      assert user.password_hash == "some password_hash"
      assert user.date_of_birth == ~U[2025-04-20 15:12:00Z]
      assert user.email_verified == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some updated email", display_name: "some updated display_name", user_name: "some updated user_name", descriminator: 43, password_hash: "some updated password_hash", date_of_birth: ~U[2025-04-21 15:12:00Z], email_verified: false}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.display_name == "some updated display_name"
      assert user.user_name == "some updated user_name"
      assert user.descriminator == 43
      assert user.password_hash == "some updated password_hash"
      assert user.date_of_birth == ~U[2025-04-21 15:12:00Z]
      assert user.email_verified == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
