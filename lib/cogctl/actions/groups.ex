defmodule Cogctl.Actions.Groups do
  use Cogctl.Action, "groups"
  alias Cogctl.CogApi
  alias Cogctl.Table

  def option_spec do
    []
  end

  def run(_options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        do_list(client)
      {:error, error} ->
        IO.puts "#{error["error"]}"
    end
  end

  defp do_list(client) do
    case CogApi.group_index(client) do
      {:ok, resp} ->
        groups = resp["groups"]
        group_attrs = for group <- groups do
          [group["name"], group["id"]]
        end

        IO.puts(Table.format([["NAME", "ID"]] ++ group_attrs))

        :ok
      {:error, resp} ->
        {:error, resp}
    end
  end
end