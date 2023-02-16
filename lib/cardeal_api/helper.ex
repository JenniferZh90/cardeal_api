defmodule CardealApi.Helper do
  def parse_iso_date(date) when is_binary(date) and date !== "" do
    case Timex.parse(date, "{ISOdate}") do
    {:ok, parsed_date} -> {:ok, parsed_date}
    _ -> {:error, date}
    end
  end
  def parse_iso_date(date), do: {:error, date}

  def generate_id() do
    UUID.uuid4(:hex)
  end

  def choose(true, a, _b) do
    a
  end
  def choose(_, _a, b) do
    b
  end

  #timezone issue should be handled later
  #better way is to store time as erlang timestamp and use timestamp to
  #do convert. For quick solution, use Timex format instead
  def date_convert(data) when is_list(data) do
    Enum.reduce(data, [], &([date_convert(&1)|&2]))
  end
  def date_convert(%{"start" => start} = data) when not is_binary(start) do
    date_convert(Map.put(data, "start", Timex.format!(start, "{YYYY}-{0M}-{0D}")))
  end
  def date_convert(%{"end" => finish} = data) when not is_binary(finish) do
    date_convert(Map.put(data, "end", Timex.format!(finish, "{YYYY}-{0M}-{0D}")))
  end
  def date_convert(%{"pickup" => pick} = data) when not is_binary(pick) do
    date_convert(Map.put(data, "pickup", Timex.format!(pick, "{YYYY}-{0M}-{0D}")))
  end
  def date_convert(%{"return" => return} = data) when not is_binary(return) do
    date_convert(Map.put(data, "return", Timex.format!(return, "{YYYY}-{0M}-{0D}")))
  end
  def date_convert(data), do: data
end
