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

    @spec generate_redirect_uri(String.t(), String.t(), keyword()) :: String.t()
    def generate_redirect_uri(base_url, path, query_params \\ []) do
      uri = URI.merge(base_url, path)
      query = URI.encode_query(query_params)
      uri_with_query = %URI{uri | query: query}
      URI.to_string(uri_with_query)
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
          refresh_token = UserManager.create_refresh_token(user)
          access_token = UserManager.create_access_token(user)
            conn
            |> put_resp_cookie("local_refresh_token", refresh_token, http_only: true)
            |> put_resp_cookie("local_access_token", access_token, http_only: true)
        else
          conn
        end

      # Validate response_type
      #IO.puts("YOU HAVE FAILED ME FOR THE FIRST TIME")
      if authorize_domain.response_type != "code" do
        send_resp(conn, 400, "INVALID DOMAIN")
      else

        #IO.puts("YOU HAVE FAILED ME FOR THE LAST TIME")
        redirect_uri = generate_redirect_uri(
          authorize_domain.redirect_uri,
          "",
          code: UserManager.generate_auth_code(user), state: authorize_domain.state
        )
          conn
          |> put_resp_header("location", redirect_uri)
          |> send_resp(201, "")

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
