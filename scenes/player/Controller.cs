using Godot;
using System;

public class Controller : ARVRController
{
	const float CONTROLLER_DEADZONE = 0.65f;

	const float THRUSTER_SPEED = 1.0f;

	const float CONTROLLER_RUMBLE_FADE_SPEED = 2.0f;

	[Export(PropertyHint.Range, "0,50,or_greater")]
	public int magazineSize = 10;
	
	public Timer gunCooldownTimer;

	public int bulletsLeft;

	public PackedScene bullet = ResourceLoader.Load<PackedScene>("res://scenes/Bullet.tscn");

	public Spatial gunPosition;

	public bool isShooting = false;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		gunPosition = GetNode<Spatial>("Gun");
		gunCooldownTimer = GetNode<Timer>("GunCooldown");

		this.Connect("button_pressed", this, "_on_LeftController_button_pressed");
		this.Connect("button_release", this, "_on_LeftController_button_release");

		bulletsLeft = magazineSize;
	}

	public override void _PhysicsProcess(float delta) 
	{
		if (Rumble > 0) 
		{
			Rumble -= delta * CONTROLLER_RUMBLE_FADE_SPEED;

			if (Rumble < 0)
			{
				Rumble = 0;
			}
		}

		if (isShooting) {
			shoot();
		}
	}

	private void startShooting()
	{
		isShooting = true;
		shoot();
	}

	private void shoot()
	{
		if (gunCooldownTimer.IsStopped() && (bulletsLeft != 0)) 
		{
			var bulletInstance = bullet.Instance<Bullet>();
			GetTree().Root.GetNode	("Main/BulletManager").AddChild(bulletInstance);
			bulletInstance.Transform = gunPosition.GlobalTransform.Orthonormalized();

			Rumble = 0.5f;

			gunCooldownTimer.Start();
			bulletsLeft -= 1;
		}
	}

	private void _on_GunCooldown_timeout()
	{
		gunCooldownTimer.Stop();
	}

	private void _on_LeftController_button_pressed(int button)
	{
		if (button == 15) 
		{
			startShooting();
		}
	} 

	private void _on_LeftController_button_release(int button)
	{	
		if (button == 15) 
		{
			isShooting = false;
			bulletsLeft = magazineSize;
		}
	}
}



