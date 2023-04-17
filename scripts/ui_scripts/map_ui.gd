extends HBoxContainer

# Height Nodes
@onready var h_noise = $c/tc/Height/NoiseType/slider
@onready var h_freqeuncy = $c/tc/Height/NoiseFrequency/slider
@onready var h_fractal = $c/tc/Height/FractalType/slider
@onready var h_deep_max = $c/tc/Height/MaxDeep/slider
@onready var h_mid_max = $c/tc/Height/MaxMid/slider
@onready var h_shallow_max = $c/tc/Height/MaxShallow/slider
@onready var h_flat_max = $c/tc/Height/MaxFlatLand/slider
@onready var h_hill_max = $c/tc/Height/MaxHill/slider
@onready var h_noise_image = $c2/tc/Height/noise_image
# Temp Nodes
@onready var t_noise = $c/tc/Temp/NoiseType/slider
@onready var t_freqeuncy = $c/tc/Temp/NoiseFrequency/slider
@onready var t_fractal = $c/tc/Temp/FractalType/slider
@onready var t_snow_max = $c/tc/Temp/MaxSnow/slider
@onready var t_grass_max = $c/tc/Temp/MaxGrass/slider
@onready var t_noise_image = $c2/tc/Temp/noise_image
# Moisture Nodes
@onready var m_noise = $c/tc/Moisture/NoiseType/slider
@onready var m_freqeuncy = $c/tc/Moisture/NoiseFrequency/slider
@onready var m_fractal = $c/tc/Moisture/FractalType/slider
@onready var m_dry_max = $c/tc/Moisture/MaxDry/slider
@onready var m_damp_max = $c/tc/Moisture/MaxDamp/slider
@onready var m_noise_image = $c2/tc/Moisture/noise_image
# Other Nodes
@onready var max_size = $c/pc/MapSize/slider

signal generate

func GetMapSize():
	return max_size.value

func GetHeightSettings():
	var settings = {
		"noise": h_noise.value,
		"frequency": h_freqeuncy.value,
		"fractal": h_fractal.value,
		"deep_max": h_deep_max.value/100.0,
		"mid_max": h_mid_max.value/100.0,
		"shallow_max": h_shallow_max.value/100.0,
		"flat_max": h_flat_max.value/100.0,
		"hill_max": h_hill_max.value/100.0
	}
	return settings

func GetTemperatureSettings():
	var settings = {
		"noise": t_noise.value,
		"frequency": t_freqeuncy.value,
		"fractal": t_fractal.value,
		"snow_max": t_snow_max.value/100.0,
		"grass_max": t_grass_max.value/100.0
	}
	return settings

func GetMoistureSettings():
	var settings = {
		"noise": m_noise.value,
		"frequency": m_freqeuncy.value,
		"fractal": m_fractal.value,
		"dry_max": m_dry_max.value/100.0,
		"damp_max": m_damp_max.value/100.0
	}
	return settings

func SetHeightTexture(texture: Texture2D):
	h_noise_image.texture = texture

func SetTemperatureTexture(texture: Texture2D):
	t_noise_image.texture = texture

func SetMoistureTexture(texture: Texture2D):
	m_noise_image.texture = texture

func _on_btn_generate_pressed():
	generate.emit()
