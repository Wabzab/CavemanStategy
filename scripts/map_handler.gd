extends Node

@onready var map_node: Node2D = $MapNode
@onready var lbl_seed: Label = $Camera2D/UI/VBC/HBC/PC/VBC/Seed
@onready var map_size_node: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/MapSize/SpinBox
@onready var tr_heightmap: TextureRect = $Camera2D/UI/VBC/HBC/Maps/VBoxContainer/tr_heightmap
@onready var tr_tempmap: TextureRect = $Camera2D/UI/VBC/HBC/Maps/VBoxContainer/tr_tempmap
@onready var tr_blendimage: TextureRect = $Camera2D/UI/VBC/HBC/Maps/VBoxContainer/tr_blendimage
# Height Map vars
@onready var deep_water_max: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Deep/SpinBox
@onready var mid_water_max: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Mid/SpinBox
@onready var shallow_water_max: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Shallow/SpinBox
@onready var mountain_min: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Mountain/SpinBox
@onready var hill_min: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Hill/SpinBox
@onready var height_noise_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/NoiseType/SpinBox
@onready var height_fractal_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/FractalType/SpinBox
@onready var height_freqeuncy_limit: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Frequency/SpinBox
# Temp Map vars
@onready var snow_max: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Snow/SpinBox
@onready var tundra_max: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Tundra/SpinBox
@onready var grass_max: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Grass/SpinBox
@onready var temp_noise_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/NoiseType2/SpinBox
@onready var temp_fractal_type: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/FractalType2/SpinBox
@onready var temp_freqeuncy_limit: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/Frequency2/SpinBox

@onready var globals = get_node("/root/Globals")
@onready var hex_scene = preload("res://scenes/hex_tile.tscn")

const max_size: int = 100
@export_range(10, max_size) var map_size : int = 50
@export var map_scale : float = 0.5
@export_group("Height Map Settings")
@export_range(0,1) var deep_water : float = 0.1 
@export_range(0,1) var mid_water : float = 0.3 
@export_range(0,1) var shallow_water : float = 0.45
@export_range(0,1) var hill : float = 0.80
@export_range(0,1) var mountain : float = 0.90
@export_range(0,100) var flower_chance : int = 25
@export_range(0,5) var height_noise : int = 2
@export_range(0,3) var height_fractal : int = 1
@export_range(1, 100) var height_frequency : int = 5
@export_group("Temperature Map Settings")
@export_range(0,1) var snow: float = 0.1
@export_range(0,1) var tundra: float = 0.3
@export_range(0,1) var grass: float = 0.7
@export_range(0,5) var temp_noise : int = 1
@export_range(0,3) var temp_fractal : int = 3
@export_range(1, 100) var temp_frequency : int = 5
@export_group("Hexagon Settings")
@export var tile_width: int = 126
@export var tile_height: int = 144

###
# Create a pool of hextiles that are used to build the map and reused on generation
# On map regen, compare map size to current hextiles
# If greater, create new hextiles
# If lesser, set excess tiles to null and [0,0]
###


func _ready():
	#Initial map generation
	SetUpTiles(max_size)
	InitialiseMap(map_size)

func _input(event):
	#Regenerate map on demand
	if event.is_action_pressed("reload"):
		_on_button_pressed()

func SetUpTiles(size: int):
	for i in range(size*size):
		var new_tile = hex_scene.instantiate()
		new_tile.position = Vector2(0, 0)
		map_node.add_child(new_tile)

func InitialiseMap(size: int):
	var world_map = await GenerateNewMap(size)
	SetMap(world_map)
	DrawMap()
	map_node.scale = Vector2(map_scale, map_scale)

func GenerateNewMap(size: int):
	var seed = randi()
	lbl_seed.text = "Seed: " + str(seed)
	var height_map: Image = await GenerateHeightMap(size, seed)
	var temp_map: Image = await GenerateTemperatureMap(size, seed)
	var world_map: Array = EvaluateWorldMap(height_map, temp_map, size)
	return world_map

func GenerateHeightMap(size: int, seed: int):
	# ----- || Gen Height Map || ----- #
	var height_map = NoiseTexture2D.new()
	height_map.noise = FastNoiseLite.new()
	height_map.noise.seed = seed
	height_map.noise.set_noise_type(height_noise)
	height_map.noise.set_fractal_type(height_fractal)
	height_map.noise.set_frequency(height_frequency/100.0)
	height_map.width = size
	height_map.height = size
	await height_map.changed
	var height_image: Image = height_map.get_image()
	var blend_image: Image = tr_blendimage.texture.get_image()
	blend_image.resize(size, size)
	
	height_image = BlendImage(height_image, blend_image, 2)
	
	tr_heightmap.texture = ImageTexture.create_from_image(height_image)
	return height_image
	# ----- ||    Complete    || ----- #

func GenerateTemperatureMap(size: int, seed: int):
	# ----- || Gen Temp Map || ----- #
	var temp_map = NoiseTexture2D.new()
	temp_map.noise = FastNoiseLite.new()
	temp_map.noise.seed = seed
	temp_map.noise.set_noise_type(temp_noise)
	temp_map.noise.set_fractal_type(temp_fractal)
	temp_map.noise.set_frequency(temp_frequency/100.0)
	temp_map.width = size
	temp_map.height = size
	await temp_map.changed
	tr_tempmap.texture = temp_map
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
	var tile_type = globals.TileType.NULL
	for x in range(size):
		for y in range(size):
			var height = height_map.get_pixel(x, y).r
			var temp = temp_map.get_pixel(x, y).r
			if height < shallow_water:
				tile_type = DetermineOceanBiome(height, temp)
			else:
				tile_type = DetermineLandBiome(height, temp)
			world_map[x][y] = tile_type
			
	return world_map
	# ----- |    Done    | ----- #

func DetermineOceanBiome(height: float, temp: float):
	# Determine ocean biome #
	if height < deep_water:
		return globals.TileType.OCEAN_DEEP
	elif height < mid_water:
		return globals.TileType.OCEAN_MID
	return globals.TileType.OCEAN_SHALLOW

func DetermineLandBiome(height: float, temp: float):
	# Determine land biome #
	if temp < tundra:
		return DetermineColdType(height, temp)
	elif temp < grass:
		return DetermineGrassType(height, temp)
	return DetermineSandType(height, temp)

func DetermineColdType(height: float, temp: float):
	if temp < snow:
		return globals.TileType.SNOW
	if height > mountain:
		return globals.TileType.SNOW_MOUNTAIN
	elif height > hill:
		return globals.TileType.SNOW_HILL
	return globals.TileType.TUNDRA

func DetermineGrassType(height: float, temp: float):
	if height > mountain:
		return globals.TileType.GRASS_MOUNTAIN
	elif height > hill:
		return globals.TileType.GRASS_HILL
	elif randi()%100 < flower_chance:
		return globals.TileType.GRASS_FLOWER
	return globals.TileType.GRASS

func DetermineSandType(height: float, temp: float):
	if height > mountain:
		return globals.TileType.SAND_MOUNTAIN
	elif height > hill:
		return globals.TileType.SAND_HILL
	return globals.TileType.SAND

func SetMap(world_map: Array):
	var index = 0
	for x in range(world_map.size()):
		for y in range(world_map.size()):
			map_node.get_child(index).SetTile(world_map[x][y], globals)
			index += 1
		index += (max_size - world_map.size())

func DrawMap():
	var size = sqrt(map_node.get_child_count())
	var index = 0
	for y in range(size):
		for x in range(size):
			var delta_x: int = (tile_width * x) + (tile_width/2 * (y%2))
			var delta_y: int = (tile_height/1.3 * y)
			var pos = Vector2(delta_x, delta_y)
			map_node.get_child(index).position = pos
			index += 1

func ClearMap():
	# Clear map by setting all tiles to null
	# This makes them recognised as "useless"
	for i in range(map_node.get_child_count()):
		map_node.get_child(i).SetTile(globals.TileType.NULL, globals)

func BlendImage(image1: Image, image2: Image, weight: int):
	# Merges image1 and image2 with a weight towards image2
	var return_image = Image.create(image1.get_width(), image1.get_height(), false, Image.FORMAT_RGB8)
	var color: Color
	for y in range(image1.get_height()):
		for x in range(image1.get_width()):
			color = image1.get_pixel(x, y) * (image2.get_pixel(x, y) * weight)
			return_image.set_pixel(x, y, color)
	return return_image

func _on_button_pressed():
	# Adjust map size
	map_size = clamp(map_size_node.value, 10, max_size)
	# Adjust height map settings
	deep_water = deep_water_max.value/100.0
	mid_water = mid_water_max.value/100.0
	shallow_water = shallow_water_max.value/100.0
	mountain = mountain_min.value/100.0
	hill = hill_min.value/100.0
	height_noise = height_noise_type.value
	height_fractal = height_fractal_type.value
	height_frequency = height_freqeuncy_limit.value
	# Adjust temp map settings
	snow = snow_max.value/100.0
	tundra = tundra_max.value/100.0
	grass = grass_max.value/100.0
	temp_noise = temp_noise_type.value
	temp_fractal = temp_fractal_type.value
	temp_frequency = temp_freqeuncy_limit.value
	# Reload Map
	ClearMap()
	InitialiseMap(map_size)
