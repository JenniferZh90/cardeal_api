defmodule CardealApi.Router do
  # Bring Plug.Router module into scope
  use Plug.Router
  alias CardealApi.RouteHandler

  plug(Plug.Logger)
  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/json"],
    json_decoder: Jason
    )
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "OK")
  end

  # Handler for GET request with "/api" path
  post "/api/book" do
    with {:ok, data} <- RouteHandler.booking(conn) do
      send_resp(conn, 200, JSON.encode!(data))
    else
      {:error, error} -> send_resp(conn, 404, error)
    end
  end
  get "/api/query" do
    with {:ok, data} <- RouteHandler.query_booking(conn) do
      send_resp(conn, 200, JSON.encode!(data))
    else
      {:error, error} -> send_resp(conn, 404, error)
    end
  end
  put "/api/pickup" do
    with {:ok, data} <- RouteHandler.register_pickup(conn) do
      send_resp(conn, 200, JSON.encode!(data))
    else
      {:error, error} -> send_resp(conn, 404, error)
    end
  end
  put "/api/return" do
    with {:ok, data} <- RouteHandler.return(conn) do
      send_resp(conn, 200, JSON.encode!(data))
    else
      {:error, error} -> send_resp(conn, 404, error)
    end
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end

end
