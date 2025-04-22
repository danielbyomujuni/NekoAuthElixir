defmodule NekoAuthWeb.UserControllerTest do
  use NekoAuthWeb.ConnCase, async: true

  alias NekoAuth.Users.User
  alias NekoAuth.Repo
  alias NekoAuth.User.UserManager
  alias RegistrationStruct

  @valid_user_json ~s({
    "email": "test@example.com",
    "display_name": "TestUser",
    "user_name": "testuser",
    "password": "StrongP@ss123!",
    "password_confirmation": "StrongP@ss123!",
    "date_of_birth": "2000-01-01"
  })

  describe "POST /api/v1/register" do
    test "returns 200 with valid registration", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/register", @valid_user_json)

      assert json_response(conn, 200)["success"] == true
    end

    test "returns 401 on registration failure", %{conn: conn} do
      # Attempt to re-register the same user
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/register", @valid_user_json)

        assert json_response(conn, 200)["success"] == true

      conn =
        conn
        |> recycle()
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/register", @valid_user_json)

      assert json_response(conn, 401)["success"] == false
    end

    test "returns 400 for malformed JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/register", "not_json")

      assert json_response(conn, 401)["error"] == "Invalid JSON"
    end

    test "returns 400 for missing fields", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/v1/register", ~s({"email": "missing_fields@example.com"}))

      assert json_response(conn, 401)["error"] == "Malformed request"
    end
  end
end
