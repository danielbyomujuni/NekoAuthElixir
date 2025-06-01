defmodule NekoAuthWeb.UserController do
  use Phoenix.Controller, formats: [:json]

  alias NekoAuth.User.UserManager
  alias RegistrationStruct
  alias Result

  defp user_manager, do: Application.get_env(:neko_auth, :user_manager, NekoAuth.User.UserManager)

  @doc """
  Handles POST /api/v2/register

  Expects JSON with registration fields.
  """
  def register(conn, _params) do
    with {:ok, body, conn} <- Plug.Conn.read_body(conn),
         {:ok, decoded} <- Jason.decode(body),
         %{
           "email" => email,
           "display_name" => display_name,
           "user_name" => user_name,
           "password" => password,
           "password_confirmation" => password_confirmation,
           "date_of_birth" => date_of_birth
         } <- decoded do
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

      # IO.inspect(email)
      IO.inspect(registration)

      case UserManager.register_new_user(registration) do
        {:ok, _user} ->
          json(conn, %{success: true})

        {:error, reason} ->
          conn
          |> put_status(401)
          |> json(%{success: false, value: reason})
      end
    else
      {:error, %Jason.DecodeError{} = _} ->
        conn
        |> put_status(401)
        |> json(%{success: false, error: "Invalid JSON"})

      {:error, reason} ->
        conn
        |> put_status(401)
        |> json(%{success: false, error: reason})

      _ ->
        conn
        |> put_status(401)
        |> json(%{success: false, error: "Malformed request"})
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
         {:ok, user} <- user_manager().user_from_login(email, password) do
      # Ensure local session exists
      conn =
        conn
        |> put_resp_cookie("local_refresh_token", user_manager().create_refresh_token(user),
          http_only: true
        )
        |> put_resp_cookie("local_access_token", user_manager().create_access_token(user),
          http_only: true
        )

      # Validate response_type
      # IO.puts("YOU HAVE FAILED ME FOR THE FIRST TIME")
      if authorize_domain.response_type != "code" do
        send_resp(conn, 401, "INVALID DOMAIN")
      else
        # IO.puts("YOU HAVE FAILED ME FOR THE LAST TIME")
        redirect_uri =
          generate_redirect_uri(
            authorize_domain.redirect_uri,
            "",
            code: user_manager().generate_auth_code(user),
            state: authorize_domain.state
          )

        conn
        |> put_resp_header("location", redirect_uri)
        |> send_resp(201, "")
      end
    else
      {:error, reason, _conn} ->
        conn
        |> put_status(401)
        |> json(%{success: false, error: reason})

      _ ->
        conn
        |> put_status(401)
        |> json(%{success: false, error: "Malformed request"})
    end
  end
  def avatar(conn, %{"user_name" => user_name, "descriminator" => descriminator}) do
    user = NekoAuth.Repo.get_by(NekoAuth.Users.User, user_name: user_name, descriminator: descriminator)

    data_url =
      case user && user.image do
        nil ->
          # Fetch default image and send raw bytes
          default_url = "https://photosrush.com/wp-content/uploads/anime-pfp-edit-3.jpg"
          case HTTPoison.get(default_url) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
              Plug.Conn.send_resp(conn, 200, body)

            _ ->
              Plug.Conn.send_resp(conn, 404, "Image not found")
          end

        data_url ->
          # Extract MIME type and base64 content
          [_, mime, base64] = Regex.run(~r/^data:(.*?);base64,(.*)$/, data_url)
          {:ok, data} = Base.decode64(base64)
          conn
          |> Plug.Conn.put_resp_content_type(mime)
          |> Plug.Conn.send_resp(200, data)
      end

    data_url
  end



  defp extract_login_payload(%{
         "auth" => auth,
         "user" => %{"email" => email, "password" => password}
       }) do
    {:ok, auth, email, password}
  end

  defp extract_login_payload(_), do: {:error, "Missing required fields"}
end
