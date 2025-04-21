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
end
