extends Node
class_name ScreenShaker

# Simple screen shake component to be attached to a Camera2D

@export var trauma_reduction_rate: float = 1.0
@export var max_offset: float = 10.0
@export var max_roll: float = 5.0 # Degrees
@export var noise: FastNoiseLite

var trauma: float = 0.0 # 0 to 1
var time: float = 0.0

@onready var camera: Camera2D = get_parent() as Camera2D

func _ready() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.frequency = 0.5

func _process(delta: float) -> void:
	if not camera: return
	
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	_shake()

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _shake() -> void:
	var amount = pow(trauma, 2) # Exponential falloff looks better
	
	var offset_x = max_offset * amount * noise.get_noise_2d(time * 50, 0)
	var offset_y = max_offset * amount * noise.get_noise_2d(0, time * 50)
	var rotation = max_roll * amount * noise.get_noise_2d(time * 50, time * 50)
	
	camera.offset = Vector2(offset_x, offset_y)
	camera.rotation_degrees = rotation

