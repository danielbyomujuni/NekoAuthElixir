defmodule NekoAuthWeb.OAuthControllerTest do
  use NekoAuthWeb.ConnCase, async: true

  import Phoenix.ConnTest
  alias NekoAuth.User.UserManager
  alias NekoAuth.Users.User


  @valid_params %{
    "response_type" => "code",
    "client_id" => "123",
    "redirect_uri" => "https://example.com/callback",
    "scope" => "openid profile",
    "state" => "abc",
    "nonce" => "xyz",
    "code_challenge" => "abc123",
    "code_challenge_method" => "S256"
  }

  describe "GET /api/v1/oauth/authorize" do
    test "redirects to login URL on valid parameters", %{conn: conn} do
      System.put_env("HOST_NAME", "https://auth.test")

      conn = get(conn, "/api/v1/oauth/authorize", @valid_params)

      assert conn.status == 302
      assert get_resp_header(conn, "location") != []
      assert get_resp_header(conn, "location") |> hd() =~ "https://auth.test/login?"
      assert response(conn, 302) =~ "Redirecting to authorization page..."
    end

    test "returns 400 on missing required parameters", %{conn: conn} do
      conn = get(conn, "/api/v1/oauth/authorize", %{})

      assert conn.status == 400
      assert json_response(conn, 400) == %{"error" => "Missing required parameters"}
    end

    test "returns 400 on invalid parameters", %{conn: conn} do
      bad_params = Map.put(@valid_params, "response_type", "invalid")

      conn = get(conn, "/api/v1/oauth/authorize", bad_params)

      assert conn.status == 400
      assert json_response(conn, 400) == %{"error" => "Invalid request"}
    end

    test "returns 400 when only code_challenge is provided", %{conn: conn} do
      incomplete = Map.drop(@valid_params, ["code_challenge_method"])
      conn = get(conn, "/api/v1/oauth/authorize", incomplete)

      assert conn.status == 400
      assert json_response(conn, 400) == %{"error" => "Invalid request"}
    end
  end

  describe "POST /api/v1/oauth/token" do
    setup do

      {:ok, _} = UserManager.register_new_user(%RegistrationStruct{
        email: "user_auth@example.com",
        display_name: "Test2",
        user_name: "testuser2",
        password: "P@ssword123",
        password_confirmation: "P@ssword123",
        date_of_birth: Date.from_iso8601!("2000-01-01")
      })

      user = NekoAuth.Repo.get(User, "user_auth@example.com")
      #IO.inspect(user, label: "User for testing")
      {:ok, conn: build_conn(), user: user}
    end

    test "returns tokens for valid authorization_code", %{conn: conn, user: user} do
      code = UserManager.generate_auth_code(user)

      conn =
        conn
        |> post("/api/v1/oauth/token", %{
          "grant_type" => "authorization_code",
          "code" => code
        })

      assert json = json_response(conn, 200)
      assert json["access_token"]
      assert json["id_token"]
      assert json["refresh_token"]
      assert json["token_type"] == "Bearer"
      assert json["expires_in"]
    end

    test "returns error for invalid grant_type", %{conn: conn} do
      conn =
        conn
        |> post("/api/v1/oauth/token", %{"grant_type" => "invalid_type"})

      assert json_response(conn, 400)["error"] == "invalid_request"
    end

    test "returns error for missing code in authorization_code grant", %{conn: conn} do
      conn =
        conn
        |> post("/api/v1/oauth/token", %{"grant_type" => "authorization_code"})

      assert json_response(conn, 400)["error"] == "invalid_request"
    end

    test "returns error for missing refresh_token", %{conn: conn} do
      conn =
        conn
        |> post("/api/v1/oauth/token", %{"grant_type" => "refresh_token"})

      assert json_response(conn, 400)["error_description"] =~ "[T101]"
    end
    test "returns token for valid refresh_token", %{conn: conn, user: user} do
      refresh_token = UserManager.create_refresh_token(user)

      conn =
        conn
        |> put_req_cookie("local_refresh_token", refresh_token)
        |> post("/api/v1/oauth/token", %{
          "grant_type" => "refresh_token",
          "refresh_token" => refresh_token
        })

      assert json = json_response(conn, 200)
      assert json["access_token"]
      assert json["refresh_token"] == refresh_token
      assert json["token_type"] == "Bearer"
      assert json["expires_in"]
    end

    test "returns error for invalid refresh_token", %{conn: conn} do
      conn =
        conn
        |> post("/api/v1/oauth/token", %{
          "grant_type" => "refresh_token",
          "refresh_token" => "invalid.token.value"
        })

      assert json_response(conn, 400)["error_description"] =~ "[T104] Invalid Token"
    end
  end
end
