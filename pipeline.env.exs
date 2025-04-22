# .env.exs
# THIS FILE IS FOR THE GITLAB PIPELINE
# DO NOT USE THIS FILE FOR LOCAL DEVELOPMENT


System.put_env("SALT_ROUNDS",10)
System.put_env("POSTGRES_USER","<database user>")
System.put_env("POSTGRES_PWD", "<database password>")
System.put_env("POSTGRES_HOST","<database host>")
System.put_env("POSTGRES_DATABASE","<database name>")
