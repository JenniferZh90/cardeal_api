defmodule CardealApi.RouteHandler do
  import CardealApi.Helper
  #post http://localhost:8080/api/book
  def booking(%Plug.Conn{body_params: %{"user" => user, "type" => type, "model" => model,
                       "start" => start, "end" => finish}})
  when is_binary(user) and user !== "" and
  is_binary(type) and type !== "" and
  is_binary(start) and start !== "" and
  is_binary(finish) and finish !== ""
  do
    with {:ok, start_time} <- parse_iso_date(start),
    {:ok, end_time} <- parse_iso_date(finish),
    %{} = data <- CardealApi.book(%{"user" => user, "type" => type, "model" => model, "start" => start_time, "end" => end_time})
    do
      {:ok, data |> date_convert}
    else
      error -> error
    end
  end
  def booking(_), do: {:error, "error_param"}

  def query_booking(%Plug.Conn{query_params: %{"id" => id}})
  when is_binary(id) and id !== ""
  do
    do_query(%{"id" => id})
  end
  def query_booking(%Plug.Conn{query_params: %{"user" => user}})
  when is_binary(user) and user !== ""
  do
    do_query(%{"user" => user})
  end
  def query_booking(_), do: {:error, "error_param"}

  def register_pickup(%Plug.Conn{body_params: %{"id" => id, "pickup" => date }})
  when is_binary(id) and id !== "" and
  is_binary(date) and date !== ""
  do
    with {:ok, pick_date} <- parse_iso_date(date),
    %{} = data <- CardealApi.register_pickup(%{"id" => id, "pickup" => pick_date})
    do
      {:ok, data |> date_convert}
    else
      error -> error
    end
  end
  def register_pickup(_), do: {:error, "error_param"}

  def return(%Plug.Conn{body_params: %{"id" => id, "return" => date }})
  when is_binary(id) and id !== "" and
  is_binary(date) and date !== ""
  do
    with {:ok, return_date} <- parse_iso_date(date),
    %{} = data <- CardealApi.return(%{"id" => id, "return" => return_date})
    do
      {:ok, data |> date_convert}
    else
      error -> error
    end
  end
  def return(_), do: {:error, "error_param"}

  defp do_query(params) do
    with data when is_map(data) or is_list(data) <- CardealApi.book_query(params)
    do
      {:ok, data |> date_convert}
    else
      error -> error
    end
  end

end
