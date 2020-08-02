defmodule GameController.RemoteGameServerApi.RealApi do
  alias GameController.RemoteGameServerApi.ResponseParser
  @priv :code.priv_dir(:game_controller)
  @aws_instance_script_location Path.join(@priv, "/scripts/aws_instance")

  def power_status do
    @aws_instance_script_location
    |> System.cmd(["status"])
    |> elem(0)
    |> Jason.decode()
    |> ResponseParser.power_status()
  end
end
