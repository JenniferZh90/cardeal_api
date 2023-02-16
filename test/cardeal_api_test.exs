defmodule CardealApi.Test do
  use ExUnit.Case

  describe "book/1" do
    test "book successful" do
      data = %{"user" => "Jen", "model" => "Honda E", "type" => "standard",
      "start" => ~N[2023-01-01 00:00:00], "end" => ~N[2023-01-03 00:00:00]}
      result = CardealApi.book(data)
      assert %{
        "fee" => 75,
        "model" => "Honda E",
        "plate" => "HONDAE",
        "start" => ~N[2023-01-01 00:00:00],
        "end" => ~N[2023-01-03 00:00:00],
        "state" => "new",
        "type" => "standard",
        "user" => "Jen"
      } === Map.delete(result, "id")
    end

    test "no car found" do
      data = %{"user" => "Jen", "model" => "Honda A", "type" => "standard",
      "start" => ~N[2023-01-01 00:00:00], "end" => ~N[2023-01-01 00:00:00]}
      assert {:error, "car_not_found"}  = CardealApi.book(data)
    end

    test "no available cars" do
      data = %{"user" => "Jen", "model" => "Honda E", "type" => "standard",
      "start" => ~N[2023-01-02 00:00:00], "end" => ~N[2023-01-02 00:00:00]}
      CardealApi.book(data)
      assert {:error, "no_available_cars"} === CardealApi.book(data)
    end

    test "no available cars2" do
      data1 = %{"user" => "Jen", "model" => "BMW i3", "type" => "premium",
      "start" => ~N[2023-01-02 00:00:00], "end" => ~N[2023-01-02 00:00:00]}
      data2 = %{"user" => "Jen", "model" => "BMW i3", "type" => "premium",
      "start" => ~N[2023-01-02 00:00:00], "end" => ~N[2023-01-04 00:00:00]}
      CardealApi.book(data1)
      assert {:error, "no_available_cars"} === CardealApi.book(data2)
    end

  end

  describe "book_query/1" do
    test "query successful" do
      data = %{"user" => "Rog", "model" => "Mini Electric", "type" => "standard",
      "start" => ~N[2023-01-01 00:00:00], "end" => ~N[2023-01-03 00:00:00]}
      %{"id" => id} = CardealApi.book(data)
      assert %{
        "id" => id,
        "plate" => "MINIE",
        "start" => ~N[2023-01-01 00:00:00],
        "end" => ~N[2023-01-03 00:00:00],
        "state" => "new",
        "user" => "Rog"
      } === CardealApi.book_query(%{"id" => id})
      assert [%{
        "id" => id,
        "plate" => "MINIE",
        "start" => ~N[2023-01-01 00:00:00],
        "end" => ~N[2023-01-03 00:00:00],
        "state" => "new",
        "user" => "Rog"
      }] === CardealApi.book_query(%{"user" => "Rog"})

      data = %{"user" => "Rog", "model" => "Mini Electric", "type" => "standard",
      "start" => ~N[2023-01-04 00:00:00], "end" => ~N[2023-01-04 00:00:00]}
      %{"id" => id2} = CardealApi.book(data)
      [%{"id" => new1}, %{"id" => new2}] = CardealApi.book_query(%{"user" => "Rog"})
      assert new1 in [id, id2] and new2 in [id, id2]
    end

    test "query not found" do
      assert  {:error, "booking_not_found"} === CardealApi.book_query(%{"id" => "134"})
      assert  {:error, "booking_not_found"} === CardealApi.book_query(%{"user" => "Ping"})
    end
  end

  describe "register_pickup/1" do
    test "register_pickup successful and cannot be picked for second time" do
      data = %{"user" => "Jun", "state" => "in_progress",
      "model" => "VW ID 3", "type" => "standard",
      "start" => ~N[2023-01-04 00:00:00], "end" => ~N[2023-01-04 00:00:00]}
      %{"id" => id} = CardealApi.book(data)
      assert %{
        "id" => id,
        "plate" => "ID3",
        "start" => ~N[2023-01-04 00:00:00],
        "end" => ~N[2023-01-04 00:00:00],
        "state" => "in_progress",
        "user" => "Jun",
        "pickup" => ~N[2023-01-04 00:00:00]
      } === CardealApi.register_pickup(%{"id" => id, "pickup" => ~N[2023-01-04 00:00:00]})

      assert {:error, "already_picked"}
      === CardealApi.register_pickup(%{"id" => id, "pickup" => ~N[2023-01-04 00:00:00]})
    end

    test "register_pickup time error" do
      data = %{"user" => "App", "state" => "in_progress",
      "model" => "Peugot e-208", "type" => "economic",
      "start" => ~N[2023-01-04 00:00:00], "end" => ~N[2023-01-05 00:00:00]}
      %{"id" => id} = CardealApi.book(data)

      assert {:error, "pickup_before_start_date_or_after_ending_date"}
      === CardealApi.register_pickup(%{"id" => id, "pickup" => ~N[2023-01-03 00:00:00]})

      assert {:error, "pickup_before_start_date_or_after_ending_date"}
      === CardealApi.register_pickup(%{"id" => id, "pickup" => ~N[2023-01-06 00:00:00]})

      assert {:error, "booking_not_found"}
      === CardealApi.register_pickup(%{"id" => "aaaa", "pickup" => ~N[2023-01-03 00:00:00]})
    end
  end

  describe "return/1" do
    test "return/1" do
      data = %{"user" => "Act", "state" => "in_progress",
      "model" => "Tesla Model 3", "type" => "premium",
      "start" => ~N[2023-01-06 00:00:00], "end" => ~N[2023-01-08 00:00:00]}
      %{"id" => id} = CardealApi.book(data)
      CardealApi.register_pickup(%{"id" => id, "pickup" => ~N[2023-01-06 00:00:00]})
      assert {:error, "return_after_ending_date"} ===
       CardealApi.return(%{"id" => id, "return" => ~N[2023-01-09 00:00:00]})
      assert %{"end" => ~N[2023-01-08 00:00:00],
               "id" => id,
               "pickup" => ~N[2023-01-06 00:00:00],
               "plate" => "MODEL3",
               "return" => ~N[2023-01-08 00:00:00],
               "start" => ~N[2023-01-06 00:00:00],
               "state" => "completed",
               "user" => "Act"} ===
       CardealApi.return(%{"id" => id, "return" => ~N[2023-01-08 00:00:00]})
       assert {:error, "booking_state_error"} ===
       CardealApi.return(%{"id" => id, "return" => ~N[2023-01-10 00:00:00]})
    end
  end

end
