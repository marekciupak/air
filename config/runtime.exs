import Config

config :air, airly_api_key: System.get_env("AIRLY_API_KEY"), lat: System.get_env("LAT"), lng: System.get_env("LNG")

config :air, Air.Db.Connection,
  auth: [method: :token, token: System.get_env("AIRLY_INFLUXDB_TOKEN")],
  bucket: System.get_env("AIRLY_INFLUXDB_BUCKET"),
  org: System.get_env("AIRLY_INFLUXDB_ORG"),
  host: System.get_env("AIRLY_INFLUXDB_HOST"),
  port: System.get_env("AIRLY_INFLUXDB_PORT"),
  scheme: System.get_env("AIRLY_INFLUXDB_SCHEME"),
  version: :v2,
  http_opts: [ssl_options: [{:cacertfile, System.get_env("AIRLY_INFLUXDB_CA_PATH")}]]
