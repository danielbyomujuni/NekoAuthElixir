defmodule NekoAuthWeb.OAuthControllerTest do
  use NekoAuthWeb.ConnCase, async: true

  import Phoenix.ConnTest
  alias NekoAuth.Domains.UserDomain
  alias NekoAuth.User.UserManager


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

      {:ok, user} = UserDomain.get_user_by_email("user_auth@example.com")
      #IO.inspect(user, label: "User for testing")
      {:ok, conn: build_conn(), user: user}
    end

    test "returns tokens for valid authorization_code", %{conn: conn, user: user} do
      code = UserManager.generate_auth_code(user, %AuthorizeDomain{})

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

    test "returns{:ok, error for missing code in authorization_code grant", %{conn: conn} do
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


test "authorization_code: returns error for missing code_verifier", %{conn: conn, user: user} do
  code =
    UserManager.generate_auth_code(user, %AuthorizeDomain{
      code_challenge: "whatever",
      code_challenge_method: "plain"
    })

  conn =
    post(conn, "/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code
    })

  assert json_response(conn, 400)["error"] == "invalid_request"
end

test "authorization_code (plain PKCE): returns tokens when code_verifier matches", %{
  conn: conn,
  user: user
} do
  code_verifier = "my-verifier"

  code =
    UserManager.generate_auth_code(user, %AuthorizeDomain{
      code_challenge: code_verifier,
      code_challenge_method: "plain"
    })

  conn =
    post(conn, "/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code,
      "code_verifier" => code_verifier
    })

  assert json = json_response(conn, 200)
  assert json["access_token"]
  assert json["id_token"]
  assert json["refresh_token"]
  assert json["token_type"] == "Bearer"
  assert json["expires_in"]
end

test "authorization_code (plain PKCE): returns error when code_verifier mismatches", %{
  conn: conn,
  user: user
} do
  code =
    UserManager.generate_auth_code(user, %AuthorizeDomain{
      code_challenge: "expected",
      code_challenge_method: "plain"
    })

  conn =
    post(conn, "/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code,
      "code_verifier" => "actual"
    })

  assert json = json_response(conn, 400)
  assert json["error_description"] =~ "[T104]"
  assert json["error_description"] =~ "challenge_failed"
end

test "authorization_code (S256 PKCE): returns tokens when code_verifier matches", %{
  conn: conn,
  user: user
} do
  code_verifier = "verifier-value"

  code_challenge =
    :crypto.hash(:sha256, code_verifier)
    |> Base.url_encode64(padding: false)

  code =
    UserManager.generate_auth_code(user, %AuthorizeDomain{
      code_challenge: code_challenge,
      code_challenge_method: "S256"
    })

  conn =
    post(conn, "/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code,
      "code_verifier" => code_verifier
    })

  assert json = json_response(conn, 200)
  assert json["access_token"]
  assert json["id_token"]
  assert json["refresh_token"]
  assert json["token_type"] == "Bearer"
  assert json["expires_in"]
end

test "authorization_code (S256 PKCE): returns error when code_verifier mismatches", %{
  conn: conn,
  user: user
} do
  code =
    UserManager.generate_auth_code(user, %AuthorizeDomain{
      code_challenge: "not-the-hash",
      code_challenge_method: "S256"
    })

  conn =
    post(conn, "/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code,
      "code_verifier" => "verifier-value"
    })

  assert json = json_response(conn, 400)
  assert json["error_description"] =~ "[T104]"
  assert json["error_description"] =~ "challenge_failed"
end

test "authorization_code: cannot reuse same code (second attempt fails)", %{
  conn: conn,
  user: user
} do
  code_verifier = "my-verifier"

  code =
    UserManager.generate_auth_code(user, %AuthorizeDomain{
      code_challenge: code_verifier,
      code_challenge_method: "plain"
    })

  conn1 =
    post(conn, "/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code,
      "code_verifier" => code_verifier
    })

  assert json_response(conn1, 200)

  conn2 =
    build_conn()
    |> post("/api/v1/oauth/token", %{
      "grant_type" => "authorization_code",
      "code" => code,
      "code_verifier" => code_verifier
    })

  assert json = json_response(conn2, 400)
  assert json["error_description"] =~ "[T104]"
  assert json["error_description"] =~ "invalid_session"
end
  end
end
