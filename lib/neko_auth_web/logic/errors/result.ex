defmodule Result do
  @moduledoc """
  A module representing a result type that can either be a successful value (`:ok`) or an error (`:error` with optional message).

  ## Author
  Daniel Byomujuni <danielbyomujuni@nekosyndicate.com>

  ## Usage

      Result.from(42)
      # => {:ok, 42}

      Result.err("Something went wrong")
      # => {:error, "Something went wrong"}

      Result.get_value({:ok, "done"})
      # => "done"

      Result.get_error({:error, "fail"})
      # => "fail"
  """

  @author "Daniel Byomujuni <danielbyomujuni@nekosyndicate.com>"

  @doc """
  Wraps a value in an `:ok` tuple.
  """
  def from(value), do: {:ok, value}

  @doc """
  Returns an `:error` tuple with an optional message.
  """
  def err(message \\ nil), do: {:error, message}

  @doc """
  Checks if the result is an error.
  """
  def is_err({:error, _}), do: true
  def is_err(_), do: false

  @doc """
  Returns the value from an `:ok` result or raises if it's an error.
  """
  def get_value({:ok, value}), do: value
  def get_value({:error, _}), do: raise "Called get_value on an Error Result"

  @doc """
  Returns the error message from an `:error` result or raises if it's a success.
  """
  def get_error({:error, msg}), do: msg
  def get_error({:ok, _}), do: raise "Called get_error on an Ok Result"
end
