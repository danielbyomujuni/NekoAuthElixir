defmodule NekoAuthWeb.UserController do
  use Phoenix.Controller, formats: [:json]

  alias NekoAuth.User.UserManager
  alias RegistrationStruct
  alias Result

  @doc """
  Handles POST /api/v2/register

  Expects JSON with registration fields.
  """
  def register(conn, _params) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok,
           %{
             "email" => email,
             "display_name" => display_name,
             "user_name" => user_name,
             "password" => password,
             "password_confirmation" => password_confirmation,
             "date_of_birth" => date_of_birth
           }} ->
            # Optional: parse date string to Date struct
            date =
              case Date.from_iso8601(date_of_birth) do
                {:ok, d} -> d
                _ -> nil
              end

            registration = %RegistrationStruct{
              email: email,
              display_name: display_name,
              user_name: user_name,
              password: password,
              password_confirmation: password_confirmation,
              date_of_birth: date
            }

            case UserManager.register_new_user(registration) do
              {:ok, _user} ->
                json(conn, %{success: true})

              {:error, reason} ->
                conn
                |> put_status(401)
                |> json(%{success: false, value: reason})
            end

          {:error, _} ->
            conn
            |> put_status(400)
            |> json(%{error: "Invalid JSON"})
        end

      {:more, _, _conn} ->
        conn
        |> put_status(413)
        |> json(%{error: "Payload too large"})

      {:error, _} ->
        conn
        |> put_status(400)
        |> json(%{error: "Failed to read request body"})
    end
  end

  @doc """
  Handles OAuth2 authorization login and session generation.
  """
  def login(conn, _params) do
    with {:ok, body, _conn} <- Plug.Conn.read_body(conn),
         {:ok, decoded} <- Jason.decode(body),
         {:ok, auth_params, email, password} <- extract_login_payload(decoded),
         {:ok, authorize_domain} <- AuthorizeDomain.from_object(auth_params),
         {:ok, user} <- UserManager.user_from_login(email, password) do
      # Ensure local session exists
      conn =
        if fetch_cookies(conn).cookies["local_refresh_token"] == nil do
          with {:ok, local_session} <- user.create_new_local_session(), #currently Errors
               {:ok, refresh_token} <- local_session.request_refresh_token(),
               {:ok, access_token} <- local_session.request_access_token(user) do
            conn
            |> put_resp_cookie("local_refresh_token", refresh_token, http_only: true)
            |> put_resp_cookie("local_access_token", access_token, http_only: true)
          else
            _ -> send_resp(conn, 400, "") |> halt()
          end
        else
          conn
        end

      # Validate response_type
      if authorize_domain.get_response_type() != "code" do
        send_resp(conn, 400, "")
      else
        with {:ok, session} <-
               user.create_new_session(
                 authorize_domain.get_client_id(),
                 authorize_domain.get_scope()
               ),
             {:ok, redirect_uri} <-
               session.request_authorization_code_redirect_uri(authorize_domain),
             :ok <- user.save_to_database() do
          conn
          |> put_resp_header("location", URI.to_string(redirect_uri))
          |> send_resp(301, "")
        else
          _ -> send_resp(conn, 400, "")
        end
      end
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{success: false, error: reason})

      _ ->
        conn
        |> put_status(400)
        |> json(%{success: false, error: "Malformed request"})
    end
  end

  defp extract_login_payload(%{
         "auth" => auth,
         "user" => %{"email" => email, "password" => password}
       }) do
    {:ok, auth, email, password}
  end

  defp extract_login_payload(_), do: {:error, "Missing required fields"}
end
