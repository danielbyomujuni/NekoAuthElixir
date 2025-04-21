defmodule NekoAuthWeb.OAuthControllerTest do
  use NekoAuthWeb.ConnCase, async: true

  import Phoenix.ConnTest
  alias NekoAuthWeb.Router.Helpers, as: Routes

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

  describe "GET /api/v2/authorize" do
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
end
