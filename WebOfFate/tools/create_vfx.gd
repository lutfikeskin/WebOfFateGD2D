@tool
extends SceneTree

func _init():
	create_synergy_particles()
	create_dissolve_particles()
	create_chaos_particles()
	quit()

func create_synergy_particles():
	var particles = CPUParticles2D.new()
	particles.name = "SynergyParticles"
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 30
	particles.explosiveness = 1.0
	particles.lifetime = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	particles.color = Color(1, 0.8, 0.2, 1) # Gold
	
	# Add gradient for fading
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 0.8, 0.2, 1))
	gradient.set_color(1, Color(1, 0.8, 0.2, 0))
	particles.color_ramp = gradient
	
	var scene = PackedScene.new()
	scene.pack(particles)
	ResourceSaver.save(scene, "res://WebOfFate/vfx/synergy_particles.tscn")
	print("Created synergy_particles.tscn")

func create_dissolve_particles():
	var particles = CPUParticles2D.new()
	particles.name = "DissolveParticles"
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 40
	particles.explosiveness = 0.8
	particles.lifetime = 1.2
	particles.direction = Vector2(0, -1)
	particles.spread = 45.0
	particles.gravity = Vector2(0, -50)
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 60.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 3.0
	particles.color = Color(0.5, 0.5, 0.5, 1) # Smoke grey
	
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.5, 0.5, 0.5, 1))
	gradient.set_color(1, Color(0.2, 0.2, 0.2, 0))
	particles.color_ramp = gradient
	
	var scene = PackedScene.new()
	scene.pack(particles)
	ResourceSaver.save(scene, "res://WebOfFate/vfx/dissolve_particles.tscn")
	print("Created dissolve_particles.tscn")

func create_chaos_particles():
	var particles = CPUParticles2D.new()
	particles.name = "ChaosParticles"
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 20
	particles.explosiveness = 0.9
	particles.lifetime = 0.5
	particles.direction = Vector2(0, 0)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = Color(1.0, 0.2, 0.2, 1) # Red
	
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 0, 0, 1))
	gradient.set_color(1, Color(0.5, 0, 0, 0))
	particles.color_ramp = gradient
	
	var scene = PackedScene.new()
	scene.pack(particles)
	ResourceSaver.save(scene, "res://WebOfFate/vfx/chaos_particles.tscn")
	print("Created chaos_particles.tscn")

