defmodule CardealApi.HelperTest do
  use ExUnit.Case
  alias CardealApi.Helper

  test "parse_iso_date/1" do
    assert {:ok, ~N[2023-01-01 00:00:00]} === Helper.parse_iso_date("2023-01-01")
    assert {:error, "1234"} === Helper.parse_iso_date("1234")
    assert {:error, 0000} === Helper.parse_iso_date(0000)
  end

  test "choose/3" do
    assert :ok === Helper.choose(1 === 1, :ok, :error)
    assert :error === Helper.choose("aaaa", :ok, :error)
    assert :ok === Helper.choose("aaa" !== "bbb", :ok, :error)
  end

  test "date_convert/1" do
    data1 =  %{"end" => ~N[2023-01-04 00:00:00],
    "id" => "af6a7b45a0c3464f882c46f8b00e421f",
    "plate" => "ENIRO",
    "start" => ~N[2023-01-01 00:00:00],
    "pickup" => ~N[2023-01-02 00:00:00],
    "return" => ~N[2023-01-03 00:00:00]}

    assert %{"end" => "2023-01-04",
    "id" => "af6a7b45a0c3464f882c46f8b00e421f",
    "plate" => "ENIRO",
    "start" => "2023-01-01",
    "pickup" =>  "2023-01-02",
    "return" =>  "2023-01-03"} === Helper.date_convert(data1)

    data2 =  [%{"end" => ~N[2023-01-04 00:00:00],
    "id" => "af6a7b45a0c3464f882c46f8b00e421f",
    "plate" => "ENIRO",
    "start" => ~N[2023-01-01 00:00:00],
    "pickup" => ~N[2023-01-02 00:00:00],
    "return" => ~N[2023-01-03 00:00:00]},
    %{"end" => ~N[2023-01-10 00:00:00],
    "id" => "af6a7b45a0c3464f882c46f8b00e421f",
    "plate" => "ENIRO",
    "start" => ~N[2023-01-05 00:00:00],
    "pickup" => ~N[2023-01-04 00:00:00],
    "return" => ~N[2023-01-09 00:00:00]}]

    assert [
    %{"end" => "2023-01-10",
    "id" => "af6a7b45a0c3464f882c46f8b00e421f",
    "plate" => "ENIRO",
    "start" => "2023-01-05",
    "pickup" => "2023-01-04",
    "return" => "2023-01-09"},
    %{"end" => "2023-01-04",
    "id" => "af6a7b45a0c3464f882c46f8b00e421f",
    "plate" => "ENIRO",
    "start" => "2023-01-01",
    "pickup" =>  "2023-01-02",
    "return" =>  "2023-01-03"}]=== Helper.date_convert(data2)
  end
end
