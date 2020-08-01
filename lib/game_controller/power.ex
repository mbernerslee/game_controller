defmodule GameController.Power do
  @priv :code.priv_dir(:game_controller)
  @aws_instance_script_location Path.join(@priv, "/scripts/aws_instance")

  # TODO add tests, stubb or a mock, UI etc
  # TODO stop hitting the real thing in tests
  def status do
    if Mix.env() in [:dev, :prod] do
      @aws_instance_script_location
      |> System.cmd(["status"])
      |> elem(0)
      |> Jason.decode()
      |> IO.inspect()
    else
      "nope"
    end
  end
end
