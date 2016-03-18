defmodule Cogctl.Actions.Rules.Create do
  use Cogctl.Action, "rules create"
  alias Cogctl.Table

  def option_spec do
    [{:rule_text, ?r, 'rule-text', {:string, :undefined}, 'Text of the rule (required)'}]
  end

  def run(options, _args, _config, client) do
    with_authentication(client,
                        &do_create(&1, :proplists.get_value(:rule_text, options)))
  end

  defp do_create(_client, :undefined) do
    display_arguments_error
  end

  defp do_create(client, rule_text) do
    case CogApi.rule_create(client, %{rule: rule_text}) do
      {:ok, resp} ->
        rule = resp["rule"]
        rule_attrs = [{"ID", resp["id"]}, {"Rule Text", rule}]

        display_output("""
        Created #{resp["id"]}

        #{Table.format(rule_attrs, false)}
        """ |> String.rstrip)
      {:error, error} ->
        display_error(error["error"])
    end
  end
end
