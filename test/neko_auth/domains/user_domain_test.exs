defmodule NekoAuth.Domains.UserDomainTest do
  use NekoAuth.DataCase, async: true

  alias NekoAuth.Domains.UserDomain
  alias NekoAuth.Users.User

  @valid_attrs %{
    email: "test@example.com",
    display_name: "Test User",
    user_name: "testuser",
    password: "P@ssw0rd!",
    password_confirmation: "P@ssw0rd!",
    date_of_birth: ~D[2000-01-01]
  }

  describe "is_registration_valid?/1" do
    test "returns true for valid data" do
      assert {:ok, _} = UserDomain.is_registration_valid?(struct(RegistrationStruct, @valid_attrs))
    end

    test "returns false if password doesn't match confirmation" do
      attrs = Map.put(@valid_attrs, :password_confirmation, "wrong")
      assert {:error, :password_confirmation} = UserDomain.is_registration_valid?(struct(RegistrationStruct, attrs))
    end

    test "returns false if email is invalid" do
      attrs = Map.put(@valid_attrs, :email, "bad-email")
      assert {:error, :email} = UserDomain.is_registration_valid?(struct(RegistrationStruct, attrs))
    end
  end

  describe "user_exists?/1" do
    test "returns true if user exists" do
      %User{email: "test@example.com", display_name: "test", user_name: "test", descriminator: 101, password_hash: "n/a", date_of_birth: ~D[2000-01-01]} |> NekoAuth.Repo.insert!()
      assert UserDomain.user_exists?("test@example.com")
    end

    test "returns false if user does not exist" do
      refute UserDomain.user_exists?("nonexistent@example.com")
    end
  end

  describe "request_next_discriminator/1" do
    test "returns 10 if no users exist with that username" do
      assert {:ok, 10} = UserDomain.request_next_discriminator("freshuser")
    end

    test "returns error if max discriminator reached" do
      for i <- 1..9999 do
        %User{user_name: "dup", descriminator: i, email: "user#{i}@x.com", display_name: "c", date_of_birth: ~D[2000-01-01], password_hash: "n/a"} |> NekoAuth.Repo.insert!()
      end

      assert {:error, _} = UserDomain.request_next_discriminator("dup")
    end
  end

  describe "hash_password/1 and password_matches?/2" do
    setup do
      System.put_env("SALT_ROUNDS", "4")
      :ok
    end

    test "hashes and verifies password" do
      hash = UserDomain.hash_password("P@ssw0rd!")
      assert UserDomain.password_matches?(hash, "P@ssw0rd!")
      refute UserDomain.password_matches?(hash, "wrong")
    end
  end

  describe "get_user_by_email/1" do
    test "returns user if found" do
      user = %User{email: "u@x.com", display_name: "test", user_name: "test", descriminator: 100, password_hash: "n/a", date_of_birth: ~D[2000-01-01]} |> NekoAuth.Repo.insert!()
      assert {:ok, ^user} = UserDomain.get_user_by_email("u@x.com")
    end

    test "returns error if not found" do
      assert {:error, _} = UserDomain.get_user_by_email("no@x.com")
    end
  end
end
