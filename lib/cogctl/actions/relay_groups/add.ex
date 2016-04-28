defmodule Cogctl.Actions.RelayGroups.Add do
  use Cogctl.Action, "relay-groups add"

  @moduledoc """
  Used to add relays to relay groups.

  Usage:
  'cogctl relay-groups add $RELAYGROUP --relays=$RELAY1,$RELAY2,$RELAY3'
  """

  def option_spec() do
    [{:relay_group, :undefined, :undefined, {:string, :undefined}, 'Relay Group name (required)'},
     {:relays, :undefined, 'relays', {:list, :undefined}, 'Relay names (required)'}]
  end

  def run(options, _args, _config, endpoint) do
    # At least one relay is required, so we specify that here
    case convert_to_params(options, option_spec, [relay_group: :required,
                                                  relays: :required]) do
      {:ok, params} ->
        with_authentication(endpoint, &do_add(&1, params))
      {:error, {:missing_params, missing_args}} ->
        display_arguments_error(missing_args)
    end
  end

  defp do_add(endpoint, params) do
    case CogApi.HTTP.Client.relay_group_add_relays_by_name(params.relay_group, params.relays, endpoint) do
      {:ok, _} ->
        relay_string = List.wrap(params.relays)
        |> Enum.join(", ")
        display_output("Added '#{relay_string}' to relay group '#{params.relay_group}'")
      {:error, error} ->
        display_error(error)
    end
  end
end