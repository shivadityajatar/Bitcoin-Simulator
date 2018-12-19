defmodule Server do

  use GenServer

  def start_link(opts \\ []) do
    {:ok, _pid} = GenServer.start_link(Server, [], opts)
  end

  def init(args) do
    indicator_r = 0 # For the ReadActor
    indicator_w = 0 # For the WriteActor
    indicator_s = 0 # This is for the TweetActors
    sequenceNum = 0
    request_hitcount = 0
    state = {:running, indicator_r, indicator_w, indicator_s, sequenceNum, request_hitcount}
    {:ok, state}
  end

  def handle_call(:start, from, state) do
    {:reply, :started, state}
  end

  def handle_call({:create_coins, uName}, clientPid, state) do
     k = 3
     zeroes = "000"
     node_set = Map.new
     {totalCoins,node_set} = Server.spawnThreadsServer(0, 50, zeroes, k,0,node_set)
     totalCoins = totalCoins * 2
     IO.inspect ["totalCoins: ",totalCoins]
     # totalUsers = Enum.random(5..10)
     totalUsers = Enum.random(100..500)
     userWallets = Tuple.to_list(makeWallet(0,25,{},totalCoins,Kernel.trunc(totalCoins / (26)),Kernel.trunc(totalCoins / 25)))
     {:reply, {totalCoins,node_set,userWallets}, "totalCoins"}
   end

   def handle_call({:start_transactions, totalCoins,userWallets}, clientPid, state) do
      IO.puts "searching for mentions: #{totalCoins}"
      IO.inspect ["totalCoins: ",totalCoins]
      totalUsers = Kernel.length(userWallets)
      totalTrans = Enum.random(20..30) #get random of transactions to be performed
      blocksInChain = makeBlockchain(totalUsers, 0,userWallets,{},totalTrans) #makes blocks for the transactions
      #performs the created transactions and returns updated wallet
      {updatedTrans,updatedWallet} = doTransactions(Tuple.to_list(blocksInChain),userWallets,totalTrans,0,DateTime.utc_now())
      {:reply, {updatedTrans,updatedWallet}, "totalCoins"}
    end

    def makeWallet(count, totalUsers, tuple,coins,lowerLimit,upperLimit) do
      if count <= totalUsers do
        {public_key, private_key} = KeyPair.keyPairMain()
        if totalUsers == count do
          userData = {coins, public_key, private_key}
          tuple1 = Tuple.append(tuple, Tuple.to_list(userData))
          makeWallet(count+1, totalUsers, tuple1,coins,lowerLimit,upperLimit)
        else
          assignedCoins = Enum.random(lowerLimit..upperLimit)
          userData = {assignedCoins, public_key, private_key}
          tuple1 = Tuple.append(tuple, Tuple.to_list(userData))
          makeWallet(count+1, totalUsers, tuple1,coins - assignedCoins,lowerLimit,upperLimit)
        end
      else
        tuple
      end
    end

    #makes a blockchain of transactions, with Receiver & Sender, with transaction ID & amount
    def makeBlockchain(totalUsers, count,walletsList,blocksInChain,totalTrans) do
      if(count<totalTrans) do
        {user1,user2} = validateBlock(totalUsers)
        amountReduced = Enum.random(1..(Enum.at(Enum.at(walletsList,user1),0) + 3))
        public_key_usr1 = Enum.at(Enum.at(walletsList,user1),1)
        public_key_usr2 = Enum.at(Enum.at(walletsList,user2),1)
        transactionID = RandomizeStrings.randomizer(8)
        status = "nil"
        transactionData = {public_key_usr1,public_key_usr2,amountReduced,transactionID,status}
        tuple1 = Tuple.append(blocksInChain, Tuple.to_list(transactionData))
        makeBlockchain(totalUsers, count+1,walletsList,tuple1,totalTrans)
      else
        blocksInChain
      end
    end

    #performs the actual transactions specified by blocks
    def doTransactions(blocksInChain,walletsList,totalTrans,count,currentTimeStamp) do
      if(count < totalTrans) do
        user1 = Enum.find_index(walletsList, fn x ->
          Enum.at(x,1) == Enum.at(Enum.at(blocksInChain,count),0)
        end)
        user2 = Enum.find_index(walletsList, fn x ->
          Enum.at(x,1) == Enum.at(Enum.at(blocksInChain,count),1)
        end)
        amountReduced = Enum.at(Enum.at(blocksInChain,count),2)
        newAmount1 = Enum.at(Enum.at(walletsList,user1),0) - amountReduced
        if(newAmount1 < 0) do
          IO.puts "   #{String.slice(Enum.at(Enum.at(blocksInChain,count),3),0,8)}         #{String.slice(Enum.at(Enum.at(walletsList,user1),1),0,6)}         #{String.slice(Enum.at(Enum.at(walletsList,user2),1),0,6)}       #{to_string(currentTimeStamp)}    Unconfirmed     #{amountReduced} BTC"
          updatedTrans = List.replace_at(blocksInChain, count, List.replace_at(Enum.at(blocksInChain,count),4,"Failure"))
          Process.sleep(500)
          doTransactions(updatedTrans,walletsList,totalTrans,count+1,DateTime.utc_now())
        else
          private_key = Enum.at(Enum.at(walletsList,user1),2)
          block_msg = Enum.at(Enum.at(walletsList,user1),1)
          signature = Signature.generate(private_key,block_msg)
          if signature do

          end
          updatedList = List.replace_at(walletsList,user1,List.replace_at(Enum.at(walletsList,user1), 0, newAmount1))
          newAmount2 = Enum.at(Enum.at(walletsList,user2),0) + amountReduced
          updatedList2 = List.replace_at(updatedList,user2,List.replace_at(Enum.at(updatedList,user2), 0, newAmount2))
          IO.puts "   #{String.slice(Enum.at(Enum.at(blocksInChain,count),3),0,8)}         #{String.slice(Enum.at(Enum.at(walletsList,user1),1),0,6)}         #{String.slice(Enum.at(Enum.at(walletsList,user2),1),0,6)}       #{to_string(currentTimeStamp)}      Success       #{amountReduced} BTC"
          updatedTrans = List.replace_at(blocksInChain, count, List.replace_at(Enum.at(blocksInChain,count),4,"Success"))
          Process.sleep(500)
          doTransactions(updatedTrans,updatedList2,totalTrans,count+1,DateTime.utc_now())
        end
      else
        {blocksInChain,walletsList}
      end
    end

    def validateBlock(totalUsers) do
      user1 = Enum.random(0..totalUsers-1)
      user2 = Enum.random(0..totalUsers-1)
      if (user1 == user2) do
        validateBlock(totalUsers)
      else
        {user1,user2}
      end
    end

   def spawnThreadsServer(count, totalSpawn, zeroes, k, coinCount,node_set) do
     if count === totalSpawn do
       IO.puts "Maximum number of threads reached!"
       {coinCount , node_set}
     else
       random_str = "bitcoin;ayushiva" <> RandomizeStrings.randomizer(10)
       spawn(Server, :bitcoinHasher, [random_str, 0, zeroes, k,coinCount, node_set,self()]) #spawns new process to mine bitcoins
       {coinsMined,node_set} = receive do
         {coinCounter,node_set} ->
         {coinCounter,node_set}
       end
       spawnThreadsServer(count+1, totalSpawn, zeroes, k,coinsMined,node_set)
     end
   end

   def bitcoinHasher(random_str, counter, zeroes, k,coinCount, node_set,pid) do
      final_str = random_str <> Integer.to_string(counter)
      hash = String.downcase(:crypto.hash(:sha256, final_str )|> Base.encode16)
      if String.starts_with?(hash,zeroes) do
        bitcoin = final_str <> "\t" <> hash
        IO.puts bitcoin
        node_set = Map.put(node_set,coinCount,bitcoin)
        if counter < 45978 do
          bitcoinHasher(random_str, counter+1, zeroes, k,coinCount+1, node_set,pid)
        else
          send pid , {coinCount,node_set}
        end
      else
        if counter < 45978 do
          bitcoinHasher(random_str, counter+1, zeroes, k,coinCount, node_set,pid)
        else
          send pid , {coinCount,node_set}
        end
      end
    end

end

defmodule RandomizeStrings do
   def randomizer(length, type \\ :all) do
     alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
     numbers = "0123456789"
      lists =
       cond do
         type == :alpha -> alphabets <> String.downcase(alphabets)
         type == :numeric -> numbers
         type == :upcase -> alphabets
         type == :downcase -> String.downcase(alphabets)
         true -> alphabets <> String.downcase(alphabets) <> numbers
       end
       |> String.split("", trim: true)
     do_randomizer(length, lists)
   end

  defp get_range(length) when length > 1, do: (1..length)
  defp get_range(length), do: [1]

  defp do_randomizer(length, lists) do
     get_range(length)
     |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
     |> Enum.join("")
  end
 end

 defmodule KeyPair do

   @type_algorithm :ecdh
   @ecdsa_curve :secp256k1

   def generate, do: :crypto.generate_key(@type_algorithm, @ecdsa_curve)

   def to_public_key(private_key) do
     private_key
     |> String.valid?()
     |> maybe_decode(private_key)
     |> generate_key()
   end

   defp maybe_decode(true, private_key), do: Base.decode16!(private_key)
   defp maybe_decode(false, private_key), do: private_key

   defp generate_key(private_key) do
     with {public_key, _private_key} <-
            :crypto.generate_key(@type_algorithm, @ecdsa_curve, private_key),
          do: public_key
   end

   def keyPairMain() do
       {public_key1, private_key1} = KeyPair.generate()
       public_key = public_key1 |> Base.encode16
       private_key = private_key1 |> Base.encode16
       {public_key, private_key}
   end

 end

 defmodule Signature do
   @ecdsa_curve :secp256k1
   @type_signature :ecdsa
   @type_hash :sha256

   @spec generate(binary, String.t()) :: String.t()
   def generate(private_key, message),
    do: :crypto.sign(@type_signature, @type_hash, message, [private_key, @ecdsa_curve])

   @spec verify(binary, binary, String.t()) :: boolean
   def verify(public_key, signature, message) do
    :crypto.verify(@type_signature, @type_hash, message, signature, [public_key, @ecdsa_curve])
   end
 end
