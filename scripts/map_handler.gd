extends Node

@onready var map_node: Node2D = $MapNode
@onready var lbl_seed: Label = $Camera2D/UI/VBC/HBC/PC/VBC/Seed
@onready var map_size_node: SpinBox = $Camera2D/UI/VBC/HBC/PC/VBC/MapSize/SpinBox
@onready var tr_heightmap: TextureRect = $Camera2D/UI/VBC/HBC/Maps/VBoxContainer/tr_heightmap
@onready var tr_tempmap: TextureRect = $Camera2D/UI/VBC/HBC/Maps/VBoxContainer/tr_tempmap
@onready var tr_moistmap: TextureRect = $Camera2D/UI/VBC/HBC/Maps/VBoxContainer/tr_moistmap
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
@export_group("Moisture Map Settings")
@export_range(0,1) var dry: float = 0.3
@export_range(0,1) var damp: float = 0.7
@export_range(0,5) var moist_noise : int = 1
@export_range(0,3) var moist_fractal : int = 3
@export_range(1, 100) var moist_frequency : int = 5
@export_group("Hexagon Settings")
@export var tile_width: int = 126
@export var tile_height: int = 144

enum TileType {
			OCEAN_DEEP, OCEAN_MID, OCEAN_SHALLOW,
			GRASS, GRASS_FLOWER, GRASS_HILL, GRASS_MOUNTAIN,
			FOREST, FOREST_HILL,
			SWAMP, 
			SAND, SAND_HILL, 
			SAVANNAH, SAVANNAH_HILL,
			JUNGLE, JUNGLE_HILL,
			SNOW, SNOW_HILL, SNOW_MOUNTAIN, 
			TUNDRA, TUNDRA_HILL,
			TAIGA, TAIGA_HILL,
			NULL
			}

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
	var moist_map: Image = await GenerateMoistureMap(size, seed)
	var world_map: Array = EvaluateWorldMap(height_map, temp_map, moist_map, size)
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
	# Image Blending
	var height_image: Image = height_map.get_image()
	var blend_image: Image = tr_blendimage.texture.get_image()
	blend_image.resize(size, size)
	height_image = BlendImage(height_image, blend_image, 2)
	tr_heightmap.texture = ImageTexture.create_from_image(height_image)
	# Blended
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

func GenerateMoistureMap(size: int, seed: int):
	# ----- || Gen Temp Map || ----- #
	var moist_map = NoiseTexture2D.new()
	moist_map.noise = FastNoiseLite.new()
	moist_map.noise.seed = seed
	moist_map.noise.set_noise_type(moist_noise)
	moist_map.noise.set_fractal_type(moist_fractal)
	moist_map.noise.set_frequency(moist_frequency/100.0)
	moist_map.width = size
	moist_map.height = size
	await moist_map.changed
	tr_moistmap.texture = moist_map
	var moist_image = moist_map.get_image()
	return moist_image
	# ----- ||   Complete   || ----- #

func EvaluateWorldMap(height_map: Image, temp_map: Image, moist_map: Image, size: int):
#	Make World map
	var world_map: Array = []
	for x in range(size):
		world_map.append([])
		for y in range(size):
			world_map[x].append(0)
	
#	Evaluate World Tiles
	var height
	var temp
	var moist
	var tile_type = TileType.NULL
	for x in range(size):
		for y in range(size):
			height = height_map.get_pixel(x, y).r
			temp = temp_map.get_pixel(x, y).r
			moist = moist_map.get_pixel(x, y).r
			world_map[x][y] = GetTileType(height, temp, moist)
	return world_map

# --- v New Tile Deciders v --- #

func GetTileHeight(height: float):
	var height_returned
	if height < deep_water:
		height_returned = "deep_water"
	elif height < mid_water:
		height_returned = "mid_water"
	elif height < shallow_water:
		height_returned = "shallow_water"
	elif height < hill:
		height_returned = "low"
	elif height < mountain:
		height_returned = "mid"
	else:
		height_returned = "high"
	return height_returned

func GetTileTemperature(temp: float):
	var temperature_returned
	if temp < snow:
		temperature_returned = "cold"
	elif temp < grass:
		temperature_returned = "warm"
	else:
		temperature_returned = "hot"
	return temperature_returned

func GetTileMoisture(moist: float):
	var moisture_returned
	if moist < dry:
		moisture_returned = "dry"
	elif moist < damp:
		moisture_returned = "damp"
	else:
		moisture_returned = "wet"
	return moisture_returned

func GetTileType(tile_height: float, tile_temp: float, tile_moist: float):
	var height = GetTileHeight(tile_height)
	var temp = GetTileTemperature(tile_temp)
	var moist = GetTileMoisture(tile_moist)
	var tile_type
	var tile_string
	match height:
		"deep_water":
			tile_type = TileType.OCEAN_DEEP
		"mid_water":
			tile_type = TileType.OCEAN_MID
		"shallow_water":
			tile_type = TileType.OCEAN_SHALLOW
		_:
			tile_string = temp + '_' + height + '_' + moist
			match tile_string:
#				Cold Tiles
				"cold_low_wet":
					tile_type = TileType.TAIGA
				"cold_mid_wet":
					tile_type = TileType.TAIGA_HILL
				"cold_high_wet":
					tile_type = TileType.SNOW_MOUNTAIN
				"cold_low_damp":
					tile_type = TileType.TUNDRA
				"cold_mid_damp":
					tile_type = TileType.TUNDRA_HILL
				"cold_high_damp":
					tile_type = TileType.SNOW_MOUNTAIN
				"cold_low_dry":
					tile_type = TileType.SNOW
				"cold_mid_dry":
					tile_type = TileType.SNOW_HILL
				"cold_high_dry":
					tile_type = TileType.SNOW_MOUNTAIN
#				Warm Tiles
				"warm_low_wet":
					tile_type = TileType.SWAMP
				"warm_mid_wet":
					tile_type = TileType.SWAMP
				"warm_high_wet":
					tile_type = TileType.GRASS_MOUNTAIN
				"warm_low_damp":
					tile_type = TileType.FOREST
				"warm_mid_damp":
					tile_type = TileType.FOREST_HILL
				"warm_high_damp":
					tile_type = TileType.GRASS_MOUNTAIN
				"warm_low_dry":
					tile_type = TileType.GRASS
				"warm_mid_dry":
					tile_type = TileType.GRASS_HILL
				"warm_high_dry":
					tile_type = TileType.GRASS_MOUNTAIN
#				Hot Tiles
				"hot_low_wet":
					tile_type = TileType.JUNGLE
				"hot_mid_wet":
					tile_type = TileType.JUNGLE_HILL
				"hot_high_wet":
					tile_type = TileType.JUNGLE_HILL
				"hot_low_damp":
					tile_type = TileType.SAVANNAH
				"hot_mid_damp":
					tile_type = TileType.SAVANNAH_HILL
				"hot_high_damp":
					tile_type = TileType.SAVANNAH_HILL
				"hot_low_dry":
					tile_type = TileType.SAND
				"hot_mid_dry":
					tile_type = TileType.SAND_HILL
				"hot_high_dry":
					tile_type = TileType.SAND_HILL
	return tile_type

# --- ^ New Tile Deciders ^ --- #

func SetMap(world_map: Array):
	var index = 0
	for x in range(world_map.size()):
		for y in range(world_map.size()):
			map_node.get_child(index).SetTile(world_map[x][y], TileType)
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
		map_node.get_child(i).SetTile(TileType.NULL, TileType)

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
