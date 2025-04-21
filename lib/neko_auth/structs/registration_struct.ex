defmodule RegistrationStruct do
  @moduledoc """
  Represents the required fields for user registration.
  """

  defstruct [
    :email,
    :display_name,
    :user_name,
    :password,
    :password_confirmation,
    :date_of_birth
  ]
end
