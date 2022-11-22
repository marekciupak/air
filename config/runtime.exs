import Config

config :air, airly_api_key: System.get_env("AIRLY_API_KEY"), lat: System.get_env("LAT"), lng: System.get_env("LNG")
