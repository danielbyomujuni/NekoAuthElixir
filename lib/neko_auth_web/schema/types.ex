defmodule NekoAuth.Schema.Types do
  use Absinthe.Schema.Notation

  # Define a custom scalar for binary data (image)
  scalar :binary, description: "A binary blob of data" do
    parse fn
      %{value: value} when is_binary(value) -> {:ok, value}
      _ -> :error
    end

    serialize fn
      value when is_binary(value) -> value
      _ -> :error
    end
  end
end
