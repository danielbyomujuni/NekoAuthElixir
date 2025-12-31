defmodule NekoAuth.User.UserManagerTest do
alias NekoAuth.Domains.UserDomain
  use NekoAuth.DataCase, async: true

  alias NekoAuth.Users.User
  alias NekoAuth.User.UserManager
  alias NekoAuth.Repo
  alias RegistrationStruct

  setup do
    reg = %RegistrationStruct{
      email: "user_manager_test@example.com",
      display_name: "New User",
      user_name: "newuser",
      password: "P@ssword1",
      password_confirmation: "P@ssword1",
      date_of_birth: ~D[2000-01-01]
    }

  {:ok, _} = UserManager.register_new_user(reg)
  {:ok, user} = UserDomain.get_user_by_email(reg.email)

    %{user: user}
  end

  describe "register_new_user/1" do
    test "registers a valid user" do
      reg = %RegistrationStruct{
        email: "newuser@example.com",
        display_name: "New User",
        user_name: "newuser",
        password: "P@ssword1",
        password_confirmation: "P@ssword1",
        date_of_birth: ~D[2000-01-01]
      }

      assert {:ok, %User{email: "newuser@example.com"}} = UserManager.register_new_user(reg)
    end

    test "fails when user already exists", %{user: user} do
      reg = %RegistrationStruct{
        email: user.email,
        display_name: user.display_name,
        user_name: user.user_name,
        password: "P@ssword1",
        password_confirmation: "P@ssword1",
        date_of_birth: ~D[2000-01-01]
      }

      assert {:error, _} = UserManager.register_new_user(reg)
    end
  end

  describe "user_from_login/2" do
    test "authenticates with correct credentials", %{user: user} do
      assert {:ok, ^user} = UserManager.user_from_login(user.email, "P@ssword1")
    end

    test "fails with invalid password", %{user: user} do
      assert {:error, _} = UserManager.user_from_login(user.email, "WrongPassword")
    end
  end

  describe "token generation" do
    test "generates access token", %{user: user} do
      assert is_binary(UserManager.create_access_token(user))
    end

    test "generates refresh token and resolves it", %{user: user} do
      token = UserManager.create_refresh_token(user)
      assert {:ok, ^user} = UserManager.user_from_refresh_token(token)
    end

    test "generates access token and resolves it", %{user: user} do
      token = UserManager.create_access_token(user)
      assert {:ok, ^user} = UserManager.user_from_refresh_token(token)
    end

    test "generates id token", %{user: user} do
      assert is_binary(UserManager.create_id_token(user))
    end
  end

  describe "authorization code flow" do
    test "encodes and decodes user", %{user: user} do
      code = UserManager.generate_auth_code(user, %AuthorizeDomain{} )
      assert {:ok, ^user} = UserManager.user_from_auth_code(code, nil)
    end
  end
end
