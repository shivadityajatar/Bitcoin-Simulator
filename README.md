# Bitcoin Implementation - 2
COP5615 - Distributed Operating Systems Principles - Project 4.2

The goals of this project are :  
* To Finish the distributed protocol by extending Part-1 of the project and Implement a simulation with at least 100 participants where mining and transactions are performed.
* Implement a web interface using the Phoenix and Capture various metrics and send them via Phoenix to the browser to build Charts. 
* Implement various mining/transacting scenarios.

## Group Information

* **Shivaditya Jatar** - *UF ID: 6203 9241*
* **Ayush Mittal** - *UF ID: 3777 8171*

## Contents of this file

Simulator Contents, Prerequisites, Instruction Section, Mining and Transacting Scenarios

## Simulator Contents
 
#### 1. Mining

* A button ```Mine Coins``` is provided which performs bitcoin mining.

Bitcoins are mined by performing a SHA-256 of a random string which has been appended to **"bitcoin;ayushiva"**. 'HashCash Algorithm' is used as a **proof of work**. A counter is appended to the randomized string and the resulting string is hashed. If the hash has '4' leading zeroes, then this is a valid bitcoin. Otherwise, the counter is incremented by one. This counter is initialized to 0 and it keeps getting incremented every time until a bitcoin with '4' leading zeroes is mined. 
As the bitcoin gets mined, it is printed on **Web Browser**.

#### 2. Implement Wallets

Wallet contains **ECDSA** keypairs. Along with this, Wallet keeps the amount of Bitcoins (BTC) available. We are showing amount of bitcoins for 25 participants, since it is not feasible to print wallet's information for all the 100+ participants. To see amount of bitcoins for these 25 participants, just hover the mouse pointer over the bar charts. 
(For this part, we are taking random (100+) number of participants and hence the wallets)

#### 3. Transact Bitcoins

* A button ```Transactions``` is provided which initiates Transactions among participants.

When we send Bitcoin, a Bitcoin transaction (with transaction ID), is created by your wallet client and then broadcast to the network. Bitcoin nodes on the network will relay and rebroadcast the transaction, and if the transaction is valid, nodes will include it in the block they are mining. The transaction will be included, along with other transactions, in a block in the blockchain. At this point the receiver is able to see the transaction amount in their wallet.
(For this part, we are performing random (100+) number of transactions)

#### 4. Charts (Statistics)

We are showing 2 Charts :

1. **Bar Chart 1**: Bitcoin Distribution for 25 participants i.e. Bitcoins before transactions (Our simulator runs for 100+ participants, but it not feasible to show the chart for all of them)

2. **Bar Chart 2**: Bitcoin Distribution for 25 participants i.e. Bitcoins after transactions. (Our simulator runs for 100+ participants, but it not feasible to show the chart for all of them)

## Prerequisites

#### Erlang OTP 21(10.0.1)
#### Elixir version 1.7.3
#### Phoenix Framework

## Instruction section

#### To run the Simulator

```elixir
(Before running, Goto project4_2 directory, where mix.exs is present)
$ cd project4_2
$ mix deps.get
$ cd assets
$ npm install
$ cd ..
(Now we are under project4_2 directory, where mix.exs is present)
$ mix phx.server
Once the files have compiled, Open a browser and run https://localhost:4000 

```
Starts the simulator. The simulator prints the bitcoins mined, transactions performed, wallets of participants along with charts to show relevant statistics.

## Mining and Transacting Scenarios

*  **For Mining** : We are considering different scenarios for leading number of zeroes in a bitcoin. (There can be 1,2,3 or 4 zeroes, above this mining takes a lot of time)

* **For Transactions** : We are showing different scenarios where number of participants are 100+, and transactions are performed among them.

## For Complete (Detailed) Output, refer to Report.pdf.
