defmodule NekoAuth.User.UserManagerTest do
alias NekoAuth.Domains.UserDomain
  use NekoAuth.DataCase, async: true

  alias NekoAuth.Users.User
  alias NekoAuth.User.UserManager
  alias RegistrationStruct
  alias NekoAuth.Users.Sessions

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
    test "generate_auth_code/2 inserts a session and returns the code", %{user: user} do
      auth_domain = %AuthorizeDomain{
        code_challenge: "challenge",
        code_challenge_method: "plain"
      }

      code = UserManager.generate_auth_code(user, auth_domain)

      assert is_binary(code)
      assert byte_size(code) > 0

      session =
        Repo.one!(
          from s in Sessions,
            where: s.code == ^code
        )

      assert session.user_id == user.id
      assert session.code == code
      assert session.code_challenge == "challenge"
      assert session.code_method == "plain"
      assert session.code_used_at == nil
    end

    test "user_from_auth_code/2 returns {:ok, user} and marks code as used (no PKCE)", %{
      user: user
    } do
      code =
        UserManager.generate_auth_code(user, %AuthorizeDomain{
          code_challenge: nil,
          code_challenge_method: nil
        })

      user_id = user.id

      assert {:ok, %User{id: ^user_id}} = UserManager.user_from_auth_code(code, nil)

      session =
        Repo.one!(
          from s in Sessions,
            where: s.code == ^code
        )

      assert session.code_used_at != nil
    end

    test "user_from_auth_code/2 returns {:ok, user} and marks code as used (PKCE plain)",
         %{user: user} do
      verifier = "my-verifier-123"

      code =
        UserManager.generate_auth_code(user, %AuthorizeDomain{
          code_challenge: verifier,
          code_challenge_method: "plain"
        })

       user_id = user.id

      assert {:ok, %User{id: ^user_id}} = UserManager.user_from_auth_code(code, verifier)

      session =
        Repo.one!(
          from s in Sessions,
            where: s.code == ^code
        )

      assert session.code_used_at != nil
    end

    test "user_from_auth_code/2 returns {:error, :challenge_failed} for PKCE plain mismatch",
         %{user: user} do
      code =
        UserManager.generate_auth_code(user, %AuthorizeDomain{
          code_challenge: "expected",
          code_challenge_method: "plain"
        })

      assert {:error, :challenge_failed} =
               UserManager.user_from_auth_code(code, "actual")

      session =
        Repo.one!(
          from s in Sessions,
            where: s.code == ^code
        )

      assert session.code_used_at == nil
    end

    test "user_from_auth_code/2 returns {:ok, user} and marks code as used (PKCE S256)",
         %{user: user} do
      verifier = "verifier-value"

      challenge =
        :crypto.hash(:sha256, verifier)
        |> Base.url_encode64(padding: false)

      code =
        UserManager.generate_auth_code(user, %AuthorizeDomain{
          code_challenge: challenge,
          code_challenge_method: "S256"
        })

               user_id = user.id


      assert {:ok, %User{id: ^user_id}} = UserManager.user_from_auth_code(code, verifier)

      session =
        Repo.one!(
          from s in Sessions,
            where: s.code == ^code
        )

      assert session.code_used_at != nil
    end

    test "user_from_auth_code/2 returns {:error, :challenge_failed} for PKCE S256 mismatch",
         %{user: user} do
      code =
        UserManager.generate_auth_code(user, %AuthorizeDomain{
          code_challenge: "not-the-hash",
          code_challenge_method: "S256"
        })

      assert {:error, :challenge_failed} =
               UserManager.user_from_auth_code(code, "verifier")

      session =
        Repo.one!(
          from s in Sessions,
            where: s.code == ^code
        )

      assert session.code_used_at == nil
    end

    test "user_from_auth_code/2 returns {:error, :invalid_session} for unknown code" do
      assert {:error, :invalid_session} =
               UserManager.user_from_auth_code("does-not-exist", nil)
    end

    test "user_from_auth_code/2 returns {:error, :invalid_session} when code already used",
         %{user: user} do
      code =
        UserManager.generate_auth_code(user, %AuthorizeDomain{
          code_challenge: nil,
          code_challenge_method: nil
        })

      assert {:ok, _user} = UserManager.user_from_auth_code(code, nil)

      assert {:error, :invalid_session} = UserManager.user_from_auth_code(code, nil)
    end
  end
end
