defmodule BlockScoutWeb.API.RPC.BlockController do
  use BlockScoutWeb, :controller

  alias BlockScoutWeb.Chain, as: ChainWeb
  alias Explorer.Chain
  alias Explorer.Chain.Cache.BlockNumber

  def getblockreward(conn, params) do
    with {:block_param, {:ok, unsafe_block_number}} <- {:block_param, Map.fetch(params, "blockno")},
         {:ok, block_number} <- ChainWeb.param_to_block_number(unsafe_block_number),
         {:ok, block} <- Chain.number_to_block(block_number) do
      reward = Chain.block_reward(block_number)

      render(conn, :block_reward, block: block, reward: reward)
    else
      {:block_param, :error} ->
        render(conn, :error, error: "Query parameter 'blockno' is required")

      {:error, :invalid} ->
        render(conn, :error, error: "Invalid block number")

      {:error, :not_found} ->
        render(conn, :error, error: "Block does not exist")
    end
  end

  def getblocknobytime(conn, params) do
    from_api = true

    with {:timestamp_param, {:ok, unsafe_timestamp}} <- {:timestamp_param, Map.fetch(params, "timestamp")},
         {:closest_param, {:ok, unsafe_closest}} <- {:closest_param, Map.fetch(params, "closest")},
         {:ok, timestamp} <- ChainWeb.param_to_block_timestamp(unsafe_timestamp),
         {:ok, closest} <- ChainWeb.param_to_block_closest(unsafe_closest),
         {:ok, block_number} <- Chain.timestamp_to_block_number(timestamp, closest, from_api) do
      render(conn, block_number: block_number)
    else
      {:timestamp_param, :error} ->
        render(conn, :error, error: "Query parameter 'timestamp' is required")

      {:closest_param, :error} ->
        render(conn, :error, error: "Query parameter 'closest' is required")

      {:error, :invalid_timestamp} ->
        render(conn, :error, error: "Invalid `timestamp` param")

      {:error, :invalid_closest} ->
        render(conn, :error, error: "Invalid `closest` param")

      {:error, :not_found} ->
        render(conn, :error, error: "Block does not exist")
    end
  end

  def eth_block_number(conn, params) do
    id = Map.get(params, "id", 1)
    max_block_number = BlockNumber.get_max()

    render(conn, :eth_block_number, number: max_block_number, id: id)
  end

  def getblockvalidator(conn, params) do
    #
    #Returns the list of validators for a given block number. Example: request for block number 0x83542
    #{
    #  "jsonrpc": "2.0",
    #  "id": "1",
    #  "result": {
    #     "Number": 537922,
    #      "Hash": "0x1adb13896264427aeb302648944d7750d31aeb89293f7d898b24523fc543e8a6",
    #      "Author": "0xff0d56bd960c455a71f908496c79e8eafec34ccf",
    #      "Committers": [
    #          "0xc21ee98b5a90a6a45aba37fa5eddf90f5e8e1816",
    #          "0x97f060952b1008c75cb030e3599725ad5cc306a2",
    #          "0x07afbe0d7d36b80454be1e185f55e02b9453625a",
    #          "0x4f9a82d7e094de7fb70d9ce2033ec0d65ac31124"
    #      ]
    #    }
    #}
    #

    with {:block_param, {:ok, unsafe_block_number}} <- {:block_param, Map.fetch(params, "blockno")},
         {:ok, block_number} <- ChainWeb.param_to_block_number(unsafe_block_number),
         {:ok, block} <- Chain.number_to_block(block_number) do
      params = block_number
      body =
        %{
          jsonrpc: "2.0",
          id: "1",
          method: "istanbul_getSignersFromBlock",
          params: [params]
        }
        |> Poison.encode!()

      url = "http://localhost:8545/"
      headers = [{"Content-type", "application/json"}]
      validators = HTTPoison.post!(url, body, headers, [])
      IO.inspect(validators)
      render(conn, :block_validators, block: block, validators: validators)
    end
  end
end
