# .env.exs

System.put_env("SALT_ROUNDS","10")
System.put_env("POSTGRES_USER","danielbyomujuni")
#System.put_env(POSTGRES_PWD, "nil")
System.put_env("POSTGRES_HOST","localhost")
System.put_env("POSTGRES_DATABASE","elixir_auth")