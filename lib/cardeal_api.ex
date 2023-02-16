defmodule CardealApi do
  @moduledoc """
  Documentation for `CardealApi`.
  """
  use GenServer
  import CardealApi.Helper

  def book(data) do
    GenServer.call(__MODULE__, {:book, data})
  end

  def book_query(data) do
    GenServer.call(__MODULE__, {:book_query, data})
  end

  def register_pickup(data) do
    GenServer.call(__MODULE__, {:register_pickup, data})
  end

  def return(data) do
    GenServer.call(__MODULE__, {:return, data})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def stop() do
    GenServer.stop(__MODULE__, :normal)
  end

  def stop(pid) when is_pid(pid) do
    GenServer.stop(pid, :normal)
  end

  @impl true
  def init(_) do
      booking_init = %{}
      car_data = [%{
        "model" => "Kia e-Niro", "plate" => "ENIRO", "type" => "economic", "fee" => 50
      },
      %{
        "model" => "VW ID 3", "plate" => "ID3", "type" => "standard", "fee" => 75
      },
      %{
        "model" => "Peugot e-208", "plate" => "E208", "type" => "economic", "fee" => 50
      },
      %{
        "model" => "Mini Electric", "plate" => "MINIE", "type" => "standard", "fee" => 75
      },
      %{
        "model" => "Nissan Leave", "plate" => "LEAVE", "type" => "economic", "fee" => 50
      },
      %{
        "model" => "Honda E", "plate" => "HONDAE", "type" => "standard", "fee" => 75
      },
      %{
        "model" => "BMW i3", "plate" => "I3", "type" => "premium", "fee" => 100
      },
      %{
        "model" => "Tesla Model 3", "plate" => "MODEL3", "type" => "premium", "fee" => 100
      }]
    {:ok, {car_data, booking_init}}
  end

  #premise: "type" and "model" only defines one car
  @impl true
  def handle_call({:book,  %{"user" => user, "type" => type, "model" => model,
  "start" => start, "end" => finish}}, _from, {car_data, booking_info}) do
    with %{"plate" => plate} = car_info <- get_car_info(type, model, car_data),
    false <- is_booked(plate, start, finish, booking_info),
    {:ok, detail, booking_info} <- do_book(plate, user, start, finish, booking_info)
    do
      detail = Map.merge(detail, car_info)
      {:reply, detail, {car_data, booking_info}}
    else
      {:error, "car_not_found"} = error -> {:reply, error, {car_data, booking_info}}
      true -> {:reply, {:error, "no_available_cars"}, {car_data, booking_info}}
      error -> {:reply, error, {car_data, booking_info}}
    end
  end

  @impl true
  def handle_call({:book_query, %{"id" => id}}, _from, {_, booking_info} = state) do
    booking = booking_info[id]
    result = choose(booking !== nil, booking, {:error, "booking_not_found"})
    {:reply, result, state}
  end
  def handle_call({:book_query, %{"user" => user}}, _from, {_, booking_info} = state) do
    booking = Enum.reduce(booking_info, [],
          fn {k, %{"user" => ^user} = v}, acc ->[Map.put(v, "id", k) | acc]
              _, acc -> acc
     end)
    result = choose(booking !== [], booking, {:error, "booking_not_found"})
    {:reply, result, state}
  end

  @impl true
  def handle_call({:register_pickup, %{"id" => id, "pickup" => pick_date}}, _from,
                                      {car_data, booking_info} = state) do
    with {:member, true} <- {:member, Map.has_key?(booking_info, id)},
        {:state, true} <- {:state, booking_info[id]["state"] == "new"},
        {:date, true} <- {:date, not Timex.before?(pick_date, booking_info[id]["start"])},
        {:date, true}  <- {:date, not Timex.after?(pick_date, booking_info[id]["end"])}
    do
      data = Map.merge(booking_info[id], %{"state" => "in_progress", "pickup" => pick_date})
      {:reply, data, {car_data, Map.put(booking_info, id, data)}}
    else
      {:member, _} -> {:reply, {:error, "booking_not_found"}, state}
      {:state, _} -> {:reply, {:error, "already_picked"}, state}
      {:date, _} -> {:reply, {:error, "pickup_before_start_date_or_after_ending_date"}, state}
    end
  end

  @impl true
  def handle_call({:return, %{"id" => id, "return" => return_date}}, _from, {car_data, booking_info} = state) do
    with {:member, true} <- {:member, Map.has_key?(booking_info, id)},
        {:state, true} <- {:state, booking_info[id]["state"] == "in_progress"},
        {:date, true} <- {:date, not Timex.after?(return_date, booking_info[id]["end"])}
    do
      data = Map.merge(booking_info[id], %{"state" => "completed", "return" => return_date})
      {:reply, data, {car_data, Map.put(booking_info, id, data)}}
    else
      {:member, _} -> {:reply, {:error, "booking_not_found"}, state}
      {:state, _} -> {:reply, {:error, "booking_state_error"}, state}
      {:date, _} -> {:reply, {:error, "return_after_ending_date"}, state}
    end
  end

  @impl true
  def terminate(reason, _state) do
    reason
  end

  defp get_car_info(type, model, car_data) do
    Enum.find(car_data, {:error, "car_not_found"}, &(&1["type"] == type and &1["model"] == model))
  end

  defp is_booked(plate, start, finish, booking_info) do
    Enum.find(booking_info, false, fn {_id, info} ->
      info["plate"] == plate and info["state"] !== "completed" and
      (not Timex.after?(info["start"], start) and not Timex.before?(info["end"], start) or
       not Timex.after?(info["start"], finish) and not Timex.before?(info["end"], finish))
     end) !== false
  end

  defp do_book(plate, user, start, finish, booking_info) do
    id = generate_id()
    #could add some retry logic
    case Map.has_key?(booking_info, id) do
      true -> {:error, "server_error"}
      false ->
        data = %{"id" => id, "plate" => plate, "user" => user, "start" => start,
        "end" => finish, "state" => "new"}
        {:ok, data, Map.put_new(booking_info, id, data)}
    end
  end
end
