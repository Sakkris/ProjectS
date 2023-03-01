using Godot;

public class Bullet : Area
{
	public Timer lifeTime;
	public Vector3 velocity;

	public float bulletSpeed = 10.0f;

	public override void _Ready()
	{
		lifeTime = GetNode<Timer>("LifeTime");

		lifeTime.Connect("timeout", this, "_on_LifeTime_timeout");
	}

	public override void _PhysicsProcess(float delta)
	{
		GlobalTranslate(Transform.basis.z * bulletSpeed * delta);
	}
	
	public void _on_LifeTime_timeout()
	{
		QueueFree();
	}
}



