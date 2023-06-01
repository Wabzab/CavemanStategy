extends Node
class_name Feature

# Describes how to place objects within a region

@export var total: int = 10
@export var radius: int = 20
@export var objects: Array = []


func spread_objects(polygon, bounds):
	return


func is_overlapping(position: Vector2, radius: int, others):
	for o in others:
		if position.distance_to(o.position) < radius:
			return true
	return false

