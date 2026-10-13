@icon("res://addons/at-icons/node/gun.svg")
class_name WeaponController extends Node

signal weapon_empty
signal weapon_fired
signal weapon_ready
signal weapon_reload_started
signal weapon_reload_finished

@export var audio_player: AudioStreamPlayer3D
@export var current_weapon: Weapon
@export var fire_origin: Marker3D
@export var hitscan_origin: Marker3D
@export var weapon_pos: Node3D

var current_ammo: int:
	get():
		return _current_ammo
var max_ammo: int:
	get():
		return current_weapon.max_ammo

var _weap_model: Node3D
var _current_ammo: int = 0


func fire() -> void:
	%StateChart.send_event("ToFire")


func reload() -> void:
	%StateChart.send_event("ToReload")


func _fire_hitscan() -> void:
	assert(hitscan_origin != null, "Hitscan origin point must be assigned.")
	current_weapon = current_weapon as HitscanWeapon

	var space_state = hitscan_origin.get_world_3d().direct_space_state
	var from := hitscan_origin.global_position
	var frwd := -hitscan_origin.global_transform.basis.z
	var to: Vector3 = from + frwd * current_weapon.max_range

	var query := PhysicsRayQueryParameters3D.create(from, to)
	var res := space_state.intersect_ray(query)

	if res:
		_spawn_impact_marker(res.position)


func _fire_projectile() -> void:
	assert(fire_origin != null, "Fire origin point must be assigned.")

	current_weapon = current_weapon as BallisticWeapon
	var projectile := current_weapon.projectile.instantiate() as Projectile3D

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = fire_origin.global_position

	var frwd := -fire_origin.global_transform.basis.z
	var velocity: Vector3 = frwd * current_weapon.muzzle_velocity

	projectile.look_at(projectile.global_position + frwd, Vector3.UP)
	projectile.setup(velocity, current_weapon.damage)


func _spawn_impact_marker(pos: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	marker.mesh = sphere

	var material := StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)

	get_tree().current_scene.add_child(marker)
	marker.global_position = pos

	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)


func _spawn_weapon_model():
	if _weap_model:
		_weap_model.queue_free()

	_weap_model = current_weapon.weapon_model.instantiate()
	weapon_pos.add_child(_weap_model)


#region Engine callbacks
func _ready() -> void:
	if not current_weapon:
		return
	_spawn_weapon_model()
	_current_ammo = current_weapon.max_ammo


#endregion


#region State machine
func _on_ready_state_entered() -> void:
	weapon_ready.emit()


func _on_fire_state_entered() -> void:
	if is_instance_of(current_weapon, BallisticWeapon):
		_fire_projectile()
	elif is_instance_of(current_weapon, HitscanWeapon):
		_fire_hitscan()
	else:
		assert(false, "Firing method not implemented")
	weapon_fired.emit()


func _on_fire_state_physics_processing(_delta: float) -> void:
	_current_ammo -= 1
	if audio_player and not current_weapon.fire_sounds.is_empty():
		var sound: AudioStream = current_weapon.fire_sounds.pick_random()
		audio_player.stream = sound
		audio_player.play()

	if _current_ammo <= 0:
		%StateChart.send_event("ToEmpty")
	else:
		%StateChart.send_event("ToReady")


func _on_empty_state_entered() -> void:
	weapon_empty.emit()


func _on_reload_state_entered() -> void:
	weapon_reload_started.emit()
	get_tree().create_timer(current_weapon.reload_time).timeout.connect(
		func():
			_current_ammo = max_ammo
			%StateChart.send_event("ToReady")
	)


func _on_reload_state_exited() -> void:
	weapon_reload_finished.emit()

#endregion
