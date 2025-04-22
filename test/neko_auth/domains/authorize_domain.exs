defmodule AuthorizeDomainTest do
  use ExUnit.Case
  alias AuthorizeDomain
  alias Result

  describe "from_object/1" do
    setup do
      valid_input = %{
        "response_type" => "code",
        "client_id" => "123",
        "redirect_uri" => "https://example.com/callback",
        "scope" => "openid profile",
        "state" => "xyz",
        "nonce" => "abc123",
        "code_challenge" => "challenge123",
        "code_challenge_method" => "S256"
      }

      %{valid_input: valid_input}
    end

    test "returns ok result for valid input", %{valid_input: input} do
      assert {:ok, %AuthorizeDomain{} = domain} = AuthorizeDomain.from_object(input)
      assert domain.response_type == "code"
      assert domain.client_id == 123
      assert domain.redirect_uri == "https://example.com/callback"
    end

    test "returns error for invalid response_type", %{valid_input: input} do
      input = Map.put(input, "response_type", "token")
      assert {:error, _} = AuthorizeDomain.from_object(input)
    end

    test "returns error for non-numeric client_id", %{valid_input: input} do
      input = Map.put(input, "client_id", "abc")
      assert {:error, _} = AuthorizeDomain.from_object(input)
    end

    test "returns error for invalid redirect_uri", %{valid_input: input} do
      input = Map.put(input, "redirect_uri", "not-a-url")
      assert {:error, _} = AuthorizeDomain.from_object(input)
    end

    test "returns error for missing scope", %{valid_input: input} do
      input = Map.delete(input, "scope")
      assert {:error, _} = AuthorizeDomain.from_object(input)
    end

    test "returns error when only code_challenge is provided", %{valid_input: input} do
      input = Map.delete(input, "code_challenge_method")
      assert {:error, "GENERIC ERROR"} = AuthorizeDomain.from_object(input)
    end

    test "returns error when only code_challenge_method is provided", %{valid_input: input} do
      input = Map.delete(input, "code_challenge")
      assert {:error, "GENERIC ERROR"} = AuthorizeDomain.from_object(input)
    end
  end

  describe "from_query_string/1" do
    test "parses valid query string and returns ok result" do
      query = "response_type=code&client_id=123&redirect_uri=https%3A%2F%2Fexample.com&scope=openid&state=abc"
      assert {:ok, %AuthorizeDomain{state: "abc"}} = AuthorizeDomain.from_query_string(query)
    end

    test "returns error for invalid query string values" do
      query = "response_type=bad&client_id=notanumber&redirect_uri=baduri&scope="
      assert {:error, _} = AuthorizeDomain.from_query_string(query)
    end
  end

  describe "create_url/2" do
    test "generates full URL with query parameters" do
      domain = %AuthorizeDomain{
        response_type: "code",
        client_id: 123,
        redirect_uri: "https://example.com",
        scope: "openid",
        state: "xyz"
      }

      url = AuthorizeDomain.create_url(domain, "https://auth.example.com/oauth/authorize")

      assert url =~ "https://auth.example.com/oauth/authorize?"
      assert url =~ "response_type=code"
      assert url =~ "client_id=123"
      assert url =~ "redirect_uri=https%3A%2F%2Fexample.com"
    end
  end

  describe "getters" do
    setup do
      domain = %AuthorizeDomain{
        response_type: "code",
        client_id: 42,
        redirect_uri: "https://uri",
        scope: "read",
        state: "abc"
      }

      %{domain: domain}
    end

    test "get_response_type/1", %{domain: d} do
      assert AuthorizeDomain.get_response_type(d) == "code"
    end

    test "get_client_id/1", %{domain: d} do
      assert AuthorizeDomain.get_client_id(d) == 42
    end

    test "get_redirect_uri/1", %{domain: d} do
      assert AuthorizeDomain.get_redirect_uri(d) == "https://uri"
    end

    test "get_scope/1", %{domain: d} do
      assert AuthorizeDomain.get_scope(d) == "read"
    end

    test "get_state/1", %{domain: d} do
      assert AuthorizeDomain.get_state(d) == "abc"
    end
  end
end
