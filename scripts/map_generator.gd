extends Node

@onready var ground : TileMap = $Ground
@onready var texture_rect : TextureRect = $Panel/TextureRect
@onready var globals = get_node("/root/Globals")

@export var map_size : int = 10
@export_group("Height Map Settings")
@export_range(0,1) var deep_water : float = 0.1 
@export_range(0,1) var mid_water : float = 0.3 
@export_range(0,1) var shallow_water : float = 0.45
@export_range(0,100) var flower_chance : int = 25


func _ready():
	#Initial map generation
	DrawMap()

func _input(event):
	#Regenerate map on demand
	if event.is_action_pressed("reload"):
		await ClearMap()
		DrawMap()

func DrawMap():
	#Fetch heightmap
	var map = await GenerateHeightMap(map_size)
	#Populate tilemap and render
	for x in range(map.size()):
		for y in range(map.size()):
			var tile = map[x][y]
			ground.set_cell(0, Vector2i(x, y), 7, Vector2.ZERO, 1)
			await ground.child_entered_tree
			var node = ground.get_child(ground.get_child_count()-1)
			node.SetTile(tile)

func GenerateHeightMap(size):
	#Initiate 2D array for heightmap
	var map = []
	for x in range(size):
		map.append([])
		for y in range(size):
			map[x].append(4)
	#Setup noise for heightmap
	var noise_map = NoiseTexture2D.new()
	noise_map.noise = FastNoiseLite.new()
	noise_map.noise.seed = randi()
	noise_map.width = size
	noise_map.height = size
	await noise_map.changed
	var image = noise_map.get_image()
	texture_rect.texture = noise_map
	#Populate heightmap
	for x in range(size):
		for y in range(size):
			var height = image.get_pixel(x, y).r
			if height < deep_water:
				map[x][y] = globals.TileType.OCEAN_DEEP
			elif height < mid_water:
				map[x][y] = globals.TileType.OCEAN_MID
			elif height < shallow_water:
				map[x][y] = globals.TileType.OCEAN_SHALLOW
			elif randi()%100 < flower_chance:
				map[x][y] = globals.TileType.GRASSLAND_FLOWER
			else:
				map[x][y] = globals.TileType.GRASSLAND
	#Return heightmap
	return map

func ClearMap():
	for child in ground.get_children():
		child.queue_free()
		await ground.child_exiting_tree
