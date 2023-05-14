extends Node

@onready var map_node = $MapNode
@onready var connections = $Connections
@onready var map_ui = $UILayer/MapUI
@onready var camera = $Camera

@onready var hex_scene = preload("res://scenes/HexTile.tscn")
@onready var biome_lookup = Image.load_from_file("res://assets/biome_lookup.png")
@export var map_scale : float = 0.5

@export_group("Hexagon Settings")
@export var tile_width: int = 122
@export var tile_height: int = 139

const max_size = 102
var max_rivers = 10
var selected_tile = null

# All possible tile types
enum TileType {
	TUNDRA, BOREAL, 
	SHRUBLAND, GRASSLAND, FOREST, RAINFOREST,
	DESERT, SAVANNAH, TROPICAL_RAINFOREST,
	WATER, COAST, NULL
}

# Colour keys using `biome_lookup`
var tile_colours = {
	"808080ff": TileType.TUNDRA,
	"007f46ff": TileType.BOREAL,
	"7f6a00ff": TileType.GRASSLAND,
	"ff6a00ff": TileType.SHRUBLAND,
	"007f7fff": TileType.FOREST,
	"004a7fff": TileType.RAINFOREST,
	"ffd800ff": TileType.DESERT,
	"7f3300ff": TileType.SAVANNAH,
	"007f0eff": TileType.TROPICAL_RAINFOREST,
	"0052afff": TileType.WATER,
	"2d8dfaff": TileType.COAST
}

# Create tiles and start map generation
func _ready():
	biome_lookup.flip_y()
	#Initial map generation
	SetUpTiles(max_size)
	InitialiseMap(map_ui.GetMapSize())

# Create pool of tiles
func SetUpTiles(size: int):
	for y in range(size):
		for x in range(size):
			var delta_x: int = (tile_width * x) + (tile_width/2 * (y%2))
			var delta_y: int = (tile_height/1.3 * y)
			var pos = Vector2(delta_x, delta_y)
			var new_tile = hex_scene.instantiate()
			new_tile.position = pos
			map_node.add_child(new_tile)
			new_tile.SetTile(TileType.NULL, TileType)
			new_tile.connect("tile_selected", _on_tile_selected)

# Generate map
func InitialiseMap(size: int):
	await GenerateNewMap(size)
	SetTileNeighbours(size)
	map_node.scale = Vector2(map_scale, map_scale)

# Create map variables
func GenerateNewMap(size: int):
	var seed = randi()
	var height: NoiseTexture2D = await GetNoiseTexture(size, randi(), map_ui.GetHeightSettings())
	var temp: NoiseTexture2D = await GetNoiseTexture(size, randi(), map_ui.GetTemperatureSettings())
	var prec: NoiseTexture2D = await GetNoiseTexture(size, randi(), map_ui.GetPrecipitationSettings())
	var images = EvaluateWorldMap(height.get_image(), temp.get_image(), prec.get_image(), size)
	map_ui.SetHeightTexture(ImageTexture.create_from_image(images[0]))
	map_ui.SetTemperatureTexture(ImageTexture.create_from_image(images[1]))
	map_ui.SetPrecipitationTexture(ImageTexture.create_from_image(images[2]))

# Return noise map
func GetNoiseTexture(size: int, seed: int, settings: Dictionary):
	var noise_texture = NoiseTexture2D.new()
	noise_texture.noise = FastNoiseLite.new()
	noise_texture.noise.seed = seed
	noise_texture.noise.set_noise_type(settings.get("noise"))
	noise_texture.noise.set_fractal_type(settings.get("fractal"))
	noise_texture.noise.set_frequency(settings.get("frequency")/100.0)
	noise_texture.width = size
	noise_texture.height = size
	await noise_texture.changed
	return noise_texture

# Set tiles
func EvaluateWorldMap(height_image: Image, temp_image: Image, prec_image: Image, size: int):
	var height; var temp; var prec; var tile; var biome: Color
	var height_settings = map_ui.GetHeightSettings()
	var tile_type = TileType.NULL
	var index = max_size + 1
	var v_offset = (max_size - size)
	for y in range(size):
		for x in range(size):
			tile = map_node.get_child(index)
			height = GetHeight(height_image.get_pixel(x, y).r)
			temp = GetTemp(temp_image.get_pixel(x, y).r, y, size/2.0)
			prec = GetPrec(prec_image.get_pixel(x, y).r, temp)
			height_image.set_pixel(x, y, Color(height, height, height))
			temp_image.set_pixel(x, y, Color(temp, temp, temp))
			prec_image.set_pixel(x, y, Color(prec, prec, prec))
			biome = biome_lookup.get_pixel(temp*99, prec*99)
			tile_type = tile_colours.get(biome.to_html())
			#tile.SetTile(tile_type, TileType)
			tile.SetTile(TileType.GRASSLAND, TileType)
			tile.SetTileData(height, temp, prec)
			#if height < height_settings.get("water_max"):
			#	tile.SetTile(TileType.WATER, TileType)
			#	tile.SetTileData(height, temp, prec)
			index += 1
		index += v_offset
	return [height_image, temp_image, prec_image]


# Return Height
func GetHeight(noise):
	return noise

# Return Temp
func GetTemp(noise, pos, centre):
	noise = (noise-0.5)
	var distance = 1-abs(centre - pos)/centre
	var new = clamp(distance + noise, 0, 1)
	return new

# Return Prec
func GetPrec(noise, temp):
	noise = clamp(noise * (1-temp*0.25), 0, 1) 
	return noise


# Handle tile neighbouring
func SetTileNeighbours(size: int):
	# Gets neighbour tiles for tile
	var index = max_size + 1
	var v_offset = (max_size - size)
	var nbrs = [null, null, null, null, null, null]
	var neighbours = []
	var tile; var offset
	var river_count = 0
	var max = max_size*max_size
	for x in range(size):
		for y in range(size):
			neighbours = []
			tile = map_node.get_child(index)
			offset = (x%2)*1
			nbrs[0] = GetTile(clamp(index-1, 0, max)) # W
			nbrs[1] = GetTile(clamp(index+1, 0, max)) # E
			nbrs[2] = GetTile(clamp(index-max_size+1-offset, 0, max)) # NW
			nbrs[3] = GetTile(clamp(index-max_size-offset, 0, max)) # NE
			nbrs[4] = GetTile(clamp(index+max_size-offset, 0, max)) # SW
			nbrs[5] = GetTile(clamp(index+max_size+1-offset, 0, max)) # SE
			for nbr in nbrs:
				if nbr != tile and nbr != null and nbr.type != TileType.NULL:
					neighbours.append(nbr)
					if tile.type == TileType.WATER and not tile.IsRiver():
						if nbr.type != TileType.WATER and nbr.type != TileType.COAST:
							tile.SetTile(TileType.COAST, TileType)
					
			tile.SetNeighbours(neighbours)
			index += 1
		index += v_offset

# Get tile
func GetTile(index):
	var tile = map_node.get_child(index)
	if tile:
		return tile

# Debug Tool
func ConnectNeighbours(tile):
	# Draw lines connecting this tile to neighbouring tiles
	for child in connections.get_children():
		connections.remove_child(child)
	var line
	for nbr in tile.neighbours:
		line = Line2D.new()
		line.add_point(tile.position * map_scale)
		line.add_point(nbr.position * map_scale)
		line.default_color = Color.from_string(tile_colours.find_key(nbr.type), Color.WEB_PURPLE)
		connections.add_child(line)

# Set tile to null
func ClearMap():
	# Clear map by setting all tiles to null
	for i in range(map_node.get_child_count()):
		map_node.get_child(i).SetTile(TileType.NULL, TileType)

# Connected Signals
func _on_map_ui_generate():
	ClearMap()
	InitialiseMap(map_ui.GetMapSize())

func _on_tile_selected(tile):
	if tile.type != TileType.NULL:
		if selected_tile != null:
			selected_tile.SetBorder(false, Color(0, 0, 0, 0))
		selected_tile = tile
		selected_tile.SetBorder(true, Color(255, 0, 0, 100))
		#ConnectNeighbours(tile)
