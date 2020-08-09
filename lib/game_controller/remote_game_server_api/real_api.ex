defmodule GameController.RemoteGameServerApi.RealApi do
  alias GameController.RemoteGameServerApi.ResponseParser
  @priv :code.priv_dir(:game_controller)
  @aws_instance_script_location Path.join(@priv, "/scripts/aws_instance")

  def power_status do
    run_aws_instance_script("status", &ResponseParser.power_status/1)
  end

  def power_on do
    run_aws_instance_script("start", &ResponseParser.power_on/1)
  end

  def power_off do
    run_aws_instance_script("stop", &ResponseParser.power_off/1)
  end

  defp run_aws_instance_script(arg, parser) do
    @aws_instance_script_location
    |> System.cmd([arg])
    |> elem(0)
    |> Jason.decode()
    |> parser.()
  end
end
