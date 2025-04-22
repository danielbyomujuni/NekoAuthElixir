defmodule ResultTest do
  use ExUnit.Case
  alias Result

  describe "from/1" do
    test "wraps a value in {:ok, value}" do
      assert Result.from(123) == {:ok, 123}
    end
  end

  describe "err/1" do
    test "wraps a message in {:error, message}" do
      assert Result.err("error") == {:error, "error"}
    end

    test "defaults to {:error, nil} when no message is given" do
      assert Result.err() == {:error, nil}
    end
  end

  describe "is_err/1" do
    test "returns true for an error result" do
      assert Result.is_err(Result.err("oops")) == true
    end

    test "returns false for a success result" do
      assert Result.is_err(Result.from("ok")) == false
    end
  end

  describe "get_value/1" do
    test "returns the value for {:ok, value}" do
      assert Result.get_value(Result.from("yay")) == "yay"
    end

    test "raises for {:error, _}" do
      assert_raise RuntimeError, "Called get_value on an Error Result", fn ->
        Result.get_value(Result.err("fail"))
      end
    end
  end

  describe "get_error/1" do
    test "returns the error message for {:error, message}" do
      assert Result.get_error(Result.err("broken")) == "broken"
    end

    test "returns nil if no message was set" do
      assert Result.get_error(Result.err()) == nil
    end

    test "raises for {:ok, _}" do
      assert_raise RuntimeError, "Called get_error on an Ok Result", fn ->
        Result.get_error(Result.from("value"))
      end
    end
  end
end
