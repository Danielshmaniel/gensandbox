extends CharacterBody2D

# default values
const SPEED = 150.0
const FOCUS_SPEED = 100.0
const FLIGHT_SPEED = 300.0
const FOCUS_FLIGHT_SPEED = 150.0
const JUMP_VELOCITY = -300.0
const FLIGHT_TIME = 1.5
const FLIGHT_COOLDOWN_TIME = 4.0
const MIN_ZOOM = Vector2(2.5, 2.5) # least zoomed in
const MAX_ZOOM = Vector2(3.5, 3.5) # most zoomed in

# variables copying default values
var speed = SPEED
var focus_speed = FOCUS_SPEED
var flight_speed = FLIGHT_SPEED
var focus_flight_speed = FOCUS_FLIGHT_SPEED
var temp_speed = speed

var jump_velocity = JUMP_VELOCITY
var flight_time = FLIGHT_TIME
var flight_cooldown_time = FLIGHT_COOLDOWN_TIME

# other variables: booleans
var is_flying: bool = false
var just_stopped_flying: bool = false
var flight_in_cooldown: bool = false

var alr_entered_fade_ffg: bool = false
var alr_left_fade_ffg: bool = true

# child nodes
@onready var flight_timer: Timer = %FlightTimer
@onready var flight_cd: Timer = %FlightCooldown
@onready var spr_hitbox: Sprite2D = $HitboxSprite
@onready var spr_idle: Sprite2D = $spr_idle
@onready var spr_walk: AnimatedSprite2D = $spr_walk
@onready var cam: Camera2D = $Camera2D

#@export var inventory: Inventory

@onready var main_char: CharacterBody2D = $"."

@onready var fade_ffg: TileMapLayer = $"../../World/Front/Fade/FFG"

signal enter_fade_ffg
signal leave_fade_ffg

func _ready():
	spr_walk.play()
	# set default values
	cam.zoom = MIN_ZOOM
	spr_hitbox.visible = false
	flight_timer.wait_time = flight_time
	flight_cd.wait_time = flight_cooldown_time

func _process(float) -> void:
	# fading walls
	if fade_ffg.get_cell_source_id(fade_ffg.local_to_map(fade_ffg.to_local(main_char.global_position))) != -1:
		if(not alr_entered_fade_ffg):
			enter_fade_ffg.emit()
			alr_entered_fade_ffg = true
			alr_left_fade_ffg = false
	else:
		if(not alr_left_fade_ffg):
			leave_fade_ffg.emit()
			alr_left_fade_ffg = true
			alr_entered_fade_ffg = false

func _input(event):
	# toggle walk animation
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		spr_walk.visible = true
		spr_idle.visible = false
	else:
		spr_idle.visible = true
		spr_walk.visible = false

	# toggle focus mode
	if Input.is_action_pressed("toggle_focus_mode"):
		temp_speed = focus_speed
		spr_hitbox.visible = true
		if is_flying:
			temp_speed = focus_flight_speed
	else:
		temp_speed = speed
		spr_hitbox.visible = false
		if is_flying:
			temp_speed = flight_speed
	
	if Input.is_action_pressed("zoom_in"):
		if cam.zoom >= MIN_ZOOM and not cam.zoom >= MAX_ZOOM:
			cam.zoom += Vector2(0.5, 0.5)

	if Input.is_action_pressed("zoom_out"):
		if cam.zoom <= MAX_ZOOM and not cam.zoom <= MIN_ZOOM:
			cam.zoom -= Vector2(0.5, 0.5)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_flying:
		velocity += get_gravity() * delta

	if just_stopped_flying and is_on_floor():
		just_stopped_flying = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
			$AutoClimbSlab.disabled = true
		else: # attempting to double jump -> enter flight mode
			if flight_in_cooldown:
				print("wait a bit")
			if not is_flying and not just_stopped_flying and not flight_in_cooldown:
				# float in mid air
				is_flying = true
				# reset momentum
				velocity.x = 0.0
				velocity.y = 0.0
				temp_speed = flight_speed
				print("flying")
				# start timer
				flight_timer.start()
			elif not flight_in_cooldown: # triple jump and so on
				print("triple jump")

	# Get the input direction and handle the movement/deceleration.
	var x_direction := Input.get_axis("move_left", "move_right")
	var y_direction := Input.get_axis("move_up", "move_down") # up is -1, down is 1
	
	if x_direction:
		velocity.x = x_direction * temp_speed
		# flip the sprite acc. to direction
		spr_idle.flip_h = sign(velocity.x) == -1
		spr_walk.flip_h = sign(velocity.x) == -1
		# flip the raycasts acc. to direction
		$StairChecker.scale.x = sign(velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, temp_speed)

	if y_direction:
		if is_flying:
			velocity.y = y_direction * temp_speed
	else:
		if is_flying:
			velocity.y = move_toward(velocity.y, 0, temp_speed)
	
	move_and_slide()
	
	# Check if we need to climb stairs
	if x_direction and velocity.y >= 0.0:
		var next_to_stair = not %TopCheck.is_colliding() and %SlabCheck.is_colliding() and not %BlockCheck.is_colliding()
		var next_to_block = not %TopCheck.is_colliding() and %BlockCheck.is_colliding()
		$AutoClimbSlab.disabled = not next_to_stair
		$AutoClimbBlock.disabled = not next_to_block

func _on_flight_timer_timeout() -> void:
	is_flying = false
	just_stopped_flying = true
	flight_in_cooldown = true
	flight_cd.start()
	temp_speed = speed
	print("stopped flying")

func _on_flight_cooldown_timeout() -> void:
	flight_in_cooldown = false
