defmodule NekoAuthWeb.PortalController do
  use Phoenix.Controller, formats: [:json]

  def callback(conn, %{"code" => code, "state" => state}) do
    url = "#{System.get_env("HOST_NAME")}/api/v1/oauth/token"

    body = URI.encode_query(%{
      "grant_type" => "authorization_code",
      "code" => code
    })

    headers = [{"content-type", "application/x-www-form-urlencoded"}]

    case Finch.build(:post, url, headers, body) |> Finch.request(NekoAuth.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        with {:ok, %{
                "access_token" => access_token,
                "refresh_token" => refresh_token,
                "id_token" => id_token
              }} <- Jason.decode(body) do

          conn
          |> put_resp_cookie("portal_access_token", access_token, http_only: true)
          |> put_resp_cookie("portal_refresh_token", refresh_token, http_only: true)
          |> put_resp_cookie("portal_id_token", id_token, http_only: true)
          |> put_resp_header("location", "/portal")
          |> send_resp(302, "Redirecting to portal page...")
        else
          _ ->
            conn
            |> put_resp_header("location", "/error")
            |> send_resp(302, "Token decode failed")
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        IO.puts("Token request failed with status #{status}")
        IO.inspect(body)

        conn
        |> put_resp_header("location", "/error")
        |> send_resp(302, "Token endpoint error")

      {:error, reason} ->
        IO.puts("HTTP error:")
        IO.inspect(reason)

        conn
        |> put_resp_header("location", "/error")
        |> send_resp(302, "Token fetch error")
    end
  end



end
