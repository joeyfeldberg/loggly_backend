# LoggerLogglyBackend

Loggly logger backend for Elixir

## Installation

1. Add logger_loggly_backend to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [{:logger_loggly_backend, "~> 0.1.0"}]
end
```

2. Ensure logger_loggly_backend is started before your application:
```elixir
def application do
  [applications: [:logger_loggly_backend]]
end
```

3. Configure the logger
```elixir
config :logger,
  backends: [{LoggerLogglyBackend, :loggly}, :console]

config :logger, :loggly,
  host: "http://logs-01.loggly.com",
  type: :inputs,
  token: "your secret token",
  tags: ["http", "staging"],
  level: :error
```

* type can be one of :inputs or :bulk  
* tags can be any string

The configuration defaults to:
```elixir
config :logger, :loggly,
  host: "http://logs-01.loggly.com",
  type: :inputs,
  token: System.get_env("LOGGLY_TOKEN"), # so you can set the token as an environment variable which is recommended
  tags: [],
  level: :info
```
