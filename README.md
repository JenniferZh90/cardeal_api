# CardealApi
For quick design, only use http rest API and no performance improvment is considered.
Lots of details are ignored just to focus on making function work

Below are examples of how to call the api after server is loaded
1. book:
```
post http://localhost:8080/api/book with json body as
{
    "user": "Jen",
    "type": "economic",
    "model": "Kia e-Niro",
    "start":"2023-01-03",
    "end":"2023-01-03"
}
```

2. query
`get http://localhost:8080/api/query?id=306022df37fb44a48f8bcfac75b6b161`
or 
`get http://localhost:8080/api/query?user=Jen`


3. pickup
```
put http://localhost:8080/api/pickup with json body as
{
    "id": "221b69c4b9794507a4ed9ed77476ff0a",
    "pickup": "2023-01-03"
}
```

4. return
```
put http://localhost:8080/api/return with json body as
{
    "id": "af6a7b45a0c3464f882c46f8b00e421f",
    "return": "2023-01-03"
}
```

## Installation
Install elixir on mac with homebrew command `brew install elixir`

## Download library
Download project lib with command `mix deps.get`

## Run project
Run the project with command `mix run --no-halt`

## If you want to access the running project with other shell locally
1. Start the project with command like `elixir --sname cardeal -S mix run --no-halt`
2. Open another shell and type command `iex --sname jen --remsh cardeal@<YourHost>`
  e.g. `iex --sname jen --remsh cardeal@JennifersBook`
3. In the newly opened shell, you can inspect gen_server state with 
```
iex(cardeal@JennifersBook)1> pid = Process.whereis(CardealApi)
  #PID<0.444.0>
iex(cardeal@JennifersBook)2> :sys.get_state(pid)
```


