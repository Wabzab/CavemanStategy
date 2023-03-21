extends Node

@onready var ground : TileMap = $Ground
@onready var globals = get_node("/root/Globals")

@export var map_size : int = 10
@export_group("Height Map Settings")
@export_range(0,1) var deep_water : float = 0.1 
@export_range(0,1) var mid_water : float = 0.3 
@export_range(0,1) var shallow_water : float = 0.45
@export_range(0,100) var flower_chance : int = 25
@export_group("Temperature Map Settings")
@export_range(0,1) var snow: float = 0.1
@export_range(0,1) var tundra: float = 0.3
@export_range(0,1) var grassland: float = 0.7


func _ready():
	#Initial map generation
	DrawMap()

func _input(event):
	#Regenerate map on demand
	if event.is_action_pressed("reload"):
		await ClearMap()
		DrawMap()

func GenerateNewMap(size: int):
	var height_map: Image = await GenerateHeightMap(size)
	var temp_map: Image = await GenerateTemperatureMap(size)
	var world_map: Array = EvaluateWorldMap(height_map, temp_map, size)
	return world_map

func DrawMap():
	#Fetch heightmap
	var map = await GenerateNewMap(map_size)
	#Populate tilemap and render
	for x in range(map_size):
		for y in range(map_size):
			var tile = map[x][y]
			ground.set_cell(0, Vector2i(x, y), 7, Vector2.ZERO, 1)
			await ground.child_entered_tree
			var node = ground.get_child(ground.get_child_count()-1)
			node.SetTile(tile)

func GenerateHeightMap(size: int):
	# ----- || Gen Height Map || ----- #
	var height_map = NoiseTexture2D.new()
	height_map.noise = FastNoiseLite.new()
	height_map.noise.seed = randi()
	height_map.width = size
	height_map.height = size
	await height_map.changed
	var height_image = height_map.get_image()
	return height_image
	# ----- ||    Complete    || ----- #

func GenerateTemperatureMap(size: int):
	# ----- || Gen Temp Map || ----- #
	var temp_map = NoiseTexture2D.new()
	temp_map.noise = FastNoiseLite.new()
	temp_map.noise.seed = randi()
	temp_map.width = size
	temp_map.height = size
	await temp_map.changed
	var temp_image = temp_map.get_image()
	return temp_image
	# ----- ||   Complete   || ----- #

func EvaluateWorldMap(height_map: Image, temp_map: Image, size: int):
	# ----- World Map ----- #
	var world_map: Array = []
	for x in range(size):
		world_map.append([])
		for y in range(size):
			world_map[x].append(0)
	# ----- | Done! | ----- #
	
	# ----- Evaluate World ----- #
	for x in range(size):
		for y in range(size):
			var height = height_map.get_pixel(x, y).r
			var temp = temp_map.get_pixel(x, y).r
			
			if height < deep_water:
				world_map[x][y] = globals.TileType.OCEAN_DEEP
			elif height < mid_water:
				world_map[x][y] = globals.TileType.OCEAN_MID
			elif height < shallow_water:
				world_map[x][y] = globals.TileType.OCEAN_SHALLOW
			elif temp < snow:
				world_map[x][y] = globals.TileType.SNOW
			elif temp < tundra:
				world_map[x][y] = globals.TileType.TUNDRA
			elif temp < grassland:
				if randi()%100 < flower_chance:
					world_map[x][y] = globals.TileType.GRASSLAND_FLOWER
				else:
					world_map[x][y] = globals.TileType.GRASSLAND
			else:
				world_map[x][y] = globals.TileType.DESERT
	return world_map
	# ----- |    Done    | ----- #

func ClearMap():
	for child in ground.get_children():
		child.queue_free()
		await ground.child_exiting_tree
