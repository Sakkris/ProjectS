using Godot;
using System;

public class Drone : KinematicBody
{
	// Declare member variables here. Examples:
	// private int a = 2;
	// private string b = "text";
	private int direction = 1;
	private float speed = 3f;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		TranslateObjectLocal( Transform.basis.x * direction * delta * speed);
	}

	private void _on_ChangeDirectionTimer_timeout()
	{
		this.direction *= -1;
	}
}



