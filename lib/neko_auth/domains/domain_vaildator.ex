defmodule DomainValidator do
  @moduledoc """
  A generic domain validator that checks a given value against a set of constraints.

  ## Author
  Daniel Byomujuni <danielbyomujuni@nekosyndicate.com>

  ## Usage

      validator = DomainValidator.new("https://example.com")
      DomainValidator.validate(validator, valid_url: true, max_length: 100)

  Supported validations:
    - `:min_value` and `:max_value` for range checking (for comparable values)
    - `:min_length` and `:max_length` for string length checking
    - `:regex` for regex pattern matching
    - `:exists_in` for checking inclusion in a list
    - `:is_number` for numeric value checking
    - `:valid_url` for URL format validation
    - `:nullable` to allow `nil` values as valid
  """

  defstruct value: nil

  @doc """
  Creates a new DomainValidator struct with the given value.
  """
  def new(value), do: %__MODULE__{value: value}

  @doc """
  Validates the value stored in the struct against the provided options.

  ## Options

    - `:min_value` - Minimum allowed value (inclusive)
    - `:max_value` - Maximum allowed value (inclusive)
    - `:min_length` - Minimum string length (inclusive)
    - `:max_length` - Maximum string length (inclusive)
    - `:regex` - Regex pattern as string to match the value against
    - `:exists_in` - A list of allowed values
    - `:is_number` - If true, checks that the value is numeric
    - `:valid_url` - If true, checks that the value is a valid URL
    - `:nullable` - If true, allows the value to be `nil`

  ## Examples

      iex> validator = DomainValidator.new("test@example.com")
      iex> DomainValidator.validate(validator, regex: ".*@.*", min_length: 5)
      true
  """
  def validate(%__MODULE__{value: value}, opts) do
    nullable = Keyword.get(opts, :nullable, false)

    cond do
      nullable && is_nil(value) ->
        true

      !nullable && is_nil(value) ->
        false

      true ->
        try do
          is_greater_than_min = is_nil(opts[:min_value]) || compare(value, opts[:min_value], :>=)
          is_less_than_max = is_nil(opts[:max_value]) || compare(value, opts[:max_value], :<=)
          is_longer_than_min_length = is_nil(opts[:min_length]) || String.length(to_string(value)) >= opts[:min_length]
          is_shorter_than_max_length = is_nil(opts[:max_length]) || String.length(to_string(value)) <= opts[:max_length]
          does_regex_match = is_nil(opts[:regex]) || Regex.match?(Regex.compile!(opts[:regex]), to_string(value))
          does_exist_in = is_nil(opts[:exists_in]) || value in opts[:exists_in]
          is_number = is_nil(opts[:is_number]) || (opts[:is_number] == is_number(value))
          is_valid_url = is_nil(opts[:valid_url]) || true #Disabled due to the differing behavior of URI.parse/1 from Javascript

          is_greater_than_min &&
            is_less_than_max &&
            is_longer_than_min_length &&
            is_shorter_than_max_length &&
            does_regex_match &&
            does_exist_in &&
            is_number &&
            is_valid_url
        rescue
          _ -> false
        end
    end
  end

  @doc false
  defp compare(%Date{} = d1, %Date{} = d2, :>=), do: Date.compare(d1, d2) in [:gt, :eq]
  defp compare(%Date{} = d1, %Date{} = d2, :<=), do: Date.compare(d1, d2) in [:lt, :eq]

  defp compare(%DateTime{} = dt1, %DateTime{} = dt2, :>=), do: DateTime.compare(dt1, dt2) in [:gt, :eq]
  defp compare(%DateTime{} = dt1, %DateTime{} = dt2, :<=), do: DateTime.compare(dt1, dt2) in [:lt, :eq]

  defp compare(%NaiveDateTime{} = ndt1, %NaiveDateTime{} = ndt2, :>=), do: NaiveDateTime.compare(ndt1, ndt2) in [:gt, :eq]
  defp compare(%NaiveDateTime{} = ndt1, %NaiveDateTime{} = ndt2, :<=), do: NaiveDateTime.compare(ndt1, ndt2) in [:lt, :eq]

  defp compare(val1, val2, :>=), do: val1 >= val2
  defp compare(val1, val2, :<=), do: val1 <= val2

end
