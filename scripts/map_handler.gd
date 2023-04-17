extends Node

@onready var map_node = $MapNode
@onready var map_ui = $UILayer/MapUI

@onready var hex_scene = preload("res://scenes/HexTile.tscn")
@export var map_scale : float = 0.5

@export_group("Hexagon Settings")
@export var tile_width: int = 126
@export var tile_height: int = 144

const max_size = 100

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
	SetUpTiles(100)
	InitialiseMap(map_ui.GetMapSize())

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
	var height_map: Image = await GenerateHeightMap(size, seed)
	var temp_map: Image = await GenerateTemperatureMap(size, seed)
	var moist_map: Image = await GenerateMoistureMap(size, seed)
	var world_map: Array = EvaluateWorldMap(height_map, temp_map, moist_map, size)
	return world_map

func GenerateHeightMap(size: int, seed: int):
	# ----- || Gen Height Map || ----- #
	var settings: Dictionary = map_ui.GetHeightSettings()
	var height_map = NoiseTexture2D.new()
	height_map.noise = FastNoiseLite.new()
	height_map.noise.seed = seed
	height_map.noise.set_noise_type(settings.get("noise"))
	height_map.noise.set_fractal_type(settings.get("fractal"))
	height_map.noise.set_frequency(settings.get("frequency")/100.0)
	height_map.width = size
	height_map.height = size
	await height_map.changed
	map_ui.SetHeightTexture(height_map)
	var height_image: Image = height_map.get_image()
	return height_image
	# ----- ||    Complete    || ----- #

func GenerateTemperatureMap(size: int, seed: int):
	# ----- || Gen Temp Map || ----- #
	var settings: Dictionary = map_ui.GetTemperatureSettings()
	var temp_map = NoiseTexture2D.new()
	temp_map.noise = FastNoiseLite.new()
	temp_map.noise.seed = seed
	temp_map.noise.set_noise_type(settings.get("noise"))
	temp_map.noise.set_fractal_type(settings.get("fractal"))
	temp_map.noise.set_frequency(settings.get("frequency")/100.0)
	temp_map.width = size
	temp_map.height = size
	await temp_map.changed
	map_ui.SetTemperatureTexture(temp_map)
	var temp_image = temp_map.get_image()
	return temp_image
	# ----- ||   Complete   || ----- #

func GenerateMoistureMap(size: int, seed: int):
	# ----- || Gen Temp Map || ----- #
	var settings: Dictionary = map_ui.GetMoistureSettings()
	var moist_map = NoiseTexture2D.new()
	moist_map.noise = FastNoiseLite.new()
	moist_map.noise.seed = seed
	moist_map.noise.set_noise_type(settings.get("noise"))
	moist_map.noise.set_fractal_type(settings.get("fractal"))
	moist_map.noise.set_frequency(settings.get("frequency")/100.0)
	moist_map.width = size
	moist_map.height = size
	await moist_map.changed
	map_ui.SetMoistureTexture(moist_map)
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

func GetTileHeight(height: float):
	var settings: Dictionary = map_ui.GetHeightSettings()
	var height_returned
	if height < settings.get("deep_max"):
		height_returned = "deep_water"
	elif height < settings.get("mid_max"):
		height_returned = "mid_water"
	elif height < settings.get("shallow_max"):
		height_returned = "shallow_water"
	elif height < settings.get("flat_max"):
		height_returned = "low"
	elif height < settings.get("hill_max"):
		height_returned = "mid"
	else:
		height_returned = "high"
	return height_returned

func GetTileTemperature(temp: float):
	var settings: Dictionary = map_ui.GetTemperatureSettings()
	var temperature_returned
	if temp < settings.get("snow_max"):
		temperature_returned = "cold"
	elif temp < settings.get("grass_max"):
		temperature_returned = "warm"
	else:
		temperature_returned = "hot"
	return temperature_returned

func GetTileMoisture(moist: float):
	var settings: Dictionary = map_ui.GetMoistureSettings()
	var moisture_returned
	if moist < settings.get("dry_max"):
		moisture_returned = "dry"
	elif moist < settings.get("damp_max"):
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

# Connected Signals
func _on_map_ui_generate():
	InitialiseMap(map_ui.GetMapSize())
