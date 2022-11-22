defmodule Airly do
  alias Airly.Measurement

  def get_current_measurements(api_key: api_key, lat: lat, lng: lng) do
    %URI{
      scheme: "https",
      authority: "airapi.airly.eu",
      userinfo: nil,
      host: "airapi.airly.eu",
      port: 443,
      path: "/v2/measurements/point",
      query:
        URI.encode_query(%{
          "lat" => lat,
          "lng" => lng
        }),
      fragment: nil
    }
    |> URI.to_string()
    |> HTTPoison.get!([{"Accept", "application/json"}, {"apikey", api_key}])
    |> Map.fetch!(:body)
    |> Jason.decode!()
    |> Map.fetch!("current")
    |> Measurement.build()
  end
end
