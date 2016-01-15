defmodule Cogctl.Actions.Roles.Create do
  use Cogctl.Action, "roles create"
  alias Cogctl.CogApi
  alias Cogctl.Table

  @params [:name]

  def option_spec do
    [{:name, :undefined, 'name', {:string, :undefined}, 'Role name'}]
  end

  def run(options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        do_create(client, options)
      {:error, error} ->
        IO.puts "#{error["error"]}"
    end
  end

  defp do_create(client, options) do
    params = make_role_params(options)
    case CogApi.role_create(client, %{role: params}) do
      {:ok, resp} ->
        role = resp["role"]
        name = role["name"]

        role_attrs = for {title, attr} <- [{"ID", "id"}, {"Name", "name"}] do
          [title, role[attr]]
        end

        IO.puts("Created #{name}")
        IO.puts("")
        IO.puts(Table.format(role_attrs))

        :ok
      {:error, resp} ->
        {:error, resp}
    end
  end

  defp make_role_params(options) do
    options
    |> Keyword.take(@params)
    |> Enum.reject(&match?({_, :undefined}, &1))
    |> Enum.into(%{})
  end
end
