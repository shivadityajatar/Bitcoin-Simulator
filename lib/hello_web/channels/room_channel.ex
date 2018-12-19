defmodule HelloWeb.RoomChannel do
    use Phoenix.Channel

    def join("room:lobby", _message, socket) do
        {:ok, socket}
    end

    def join("room:"<> _private_room_id, _params, _socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in("start_transactions", params, socket) do
      total_coins = params["coins_created"]
      IO.puts "coins in transaction: #{total_coins}"
      initial_wallet = params["initial_wallet"]
      colorArr = params["colorArr"]
      IO.inspect ["colorArr",colorArr]
      {updatedTrans,updatedWallet} = GenServer.call(:server, {:start_transactions, total_coins,initial_wallet}, 20000)
      IO.inspect ["transaction reply1:" ,updatedWallet]
      IO.inspect ["transaction reply2:" ,updatedTrans]
      push socket, "start_transactions", %{"coins_created" => total_coins, "updatedWallet" => updatedWallet, "colorArr" => colorArr}
      {:noreply, socket}
    end

    def handle_in("create_coins", params, socket) do
      userName = params["username"]
      time = params["time"]
      {val,coins,userWallets} = GenServer.call(:server, {:create_coins, ""}, 20000)
      IO.inspect ["initalWallet",userWallets]
      push socket, "create_coins", %{"coins_created" => val, "bitcoins" => coins, "initalWallet" => userWallets}
        {:reply, {:ok, Map.new}, socket}
    end

end
