using Godot;
using System;



public class Player : Spatial
{	
	const String ANIMATION_PLAYER_CONTROLLER = "AnimationPlayer";

	private WebXRInterface _webxrInterface;

	private bool _vrSupported = false;

	private ARVRController leftController;

	private ARVRController rightController;

	public override void _Ready()
	{
		Button _startButton = GetNode<Button>("Button");
		_startButton.Connect("pressed", this, "OnButtonPressed");

		_webxrInterface = (WebXRInterface)ARVRServer.FindInterface("WebXR");
		
		if (_webxrInterface != null) 
		{
			_webxrInterface.XrStandardMapping = true;
			
			_webxrInterface.Connect("session_supported", this, "WebxrSessionSupported");
			_webxrInterface.Connect("session_started", this, "WebxrSessionStarted");
			_webxrInterface.Connect("session_ended", this, "WebxrSessionEnded");
			_webxrInterface.Connect("session_failed", this, "WebxrSessionFailed");
			
			_webxrInterface.Connect("select", this, "WebxrOnSelect");
			_webxrInterface.Connect("selectstart", this, "WebxrOnSelectStart");
			_webxrInterface.Connect("selectend", this, "WebxrOnSelectEnd");
			
			_webxrInterface.Connect("squeeze", this, "WebxrOnSqueeze");
			_webxrInterface.Connect("squeezestart", this, "WebxrOnSqueezeStart");
			_webxrInterface.Connect("squeezeend", this, "WebxrOnSqueezeEnd");
			
			_webxrInterface.IsSessionSupported("immersive-vr");
			OS.VsyncEnabled = false;
			Engine.TargetFps = 90;
		}
		
		this.leftController = GetNode<ARVRController>("ARVROrigin/LeftController");
		this.leftController.Connect("button_pressed", this, "OnLeftControllerButtonPressed");
		this.leftController.Connect("button_release", this, "OnLeftControllerButtonRelease");
	}
	
	public void WebxrSessionSupported(String sessionMode, bool supported) 
	{
		if (sessionMode == "immersive-vr") 
		{
			this._vrSupported = supported;
		}
	}
	
	public void OnButtonPressed() 
	{	
		if (!this._vrSupported) 
		{
			OS.Alert("Your Browser doesn't support VR");
			return;
		}
		
		_webxrInterface.SessionMode = "immersive-vr";
		_webxrInterface.RequestedReferenceSpaceTypes = "bounded-floor, local-floor, local";
		
		if (!_webxrInterface.Initialize())
		{
			OS.Alert("Failed to initialize");
			return;
		}
	}
	
	public void WebxrSessionStarted() 
	{
		Button _startButton = GetNode<Button>("Button");
		_startButton.Visible = false;
		
		GetViewport().Arvr = true;
		
		GD.Print("Reference Space Type: " + _webxrInterface.ReferenceSpaceType);
	}
	
	public void WebxrSessionFailed(String message)
	{
		OS.Alert("Failed to initialize: " + message);
	}
 
	public void OnLeftControllerButtonPressed(int button) 
	{
		GD.Print("Button pressed: " + button.ToString());

		var animationPlayer = this.leftController.GetNode<AnimationPlayer>(ANIMATION_PLAYER_CONTROLLER);
		animationPlayer.Play("Sign_Point");
	}
 
	public void OnLeftControllerButtonRelease(int button) 
	{
		GD.Print("Button release: " + button.ToString());

		var animationPlayer = this.leftController.GetNode<AnimationPlayer>(ANIMATION_PLAYER_CONTROLLER);
		animationPlayer.Play("Default pose");
	}

	public override void _Process(float delta)
	{
		int _leftControllerId = 100;
		int _thumbstickXAxisId = 2;
		int _thumbstickYAxisId = 3;

		Vector2 _thumbstickVector = new Vector2(
			Input.GetJoyAxis(_leftControllerId, _thumbstickXAxisId),
			Input.GetJoyAxis(_leftControllerId, _thumbstickYAxisId));
		
		if (_thumbstickVector != Vector2.Zero)
		{
			GD.Print("Left thumbstick position: " + _thumbstickVector.ToString());
		}
	}

	public void WebxrOnSelect(int controllerId) 
	{
		GD.Print("Select: " + controllerId.ToString());
		
		ARVRPositionalTracker controller = _webxrInterface.GetController(controllerId);
		
		GD.Print(controller.GetOrientation());
		GD.Print(controller.GetPosition());
	}
 
 
	public void WebxrOnSelectStart(int controllerId) 
	{
		GD.Print("Select Start: " + controllerId.ToString());
	}
	
	public void WebxrOnSelectEnd(int controllerId) 
	{
		GD.Print("Select End: " + controllerId.ToString());
	}
	
	public void WebxrOnSqueeze(int controllerId) 
	{
		GD.Print("Squeeze: " + controllerId.ToString());
	}
	
	public void WebxrOnSqueezeStart(int controllerId) 
	{
		GD.Print("Squeeze Start: " + controllerId.ToString());
	}
	
	public void WebxrOnSqueezeEnd(int controllerId) 
	{
		GD.Print("Squeeze End: " + controllerId.ToString());
	}
}
