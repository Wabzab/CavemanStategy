extends HBoxContainer

# Height Nodes
@onready var h_noise = $c/tc/Height/NoiseType/slider
@onready var h_freqeuncy = $c/tc/Height/NoiseFrequency/slider
@onready var h_fractal = $c/tc/Height/FractalType/slider
@onready var h_water_max = $c/tc/Height/MaxWater/slider
@onready var h_flat_max = $c/tc/Height/MaxFlatLand/slider
@onready var h_hill_max = $c/tc/Height/MaxHill/slider
@onready var h_noise_image = $c2/tc/Height/noise_image
# Temp Nodes
@onready var t_noise = $c/tc/Temp/NoiseType/slider
@onready var t_freqeuncy = $c/tc/Temp/NoiseFrequency/slider
@onready var t_fractal = $c/tc/Temp/FractalType/slider
@onready var t_noise_image = $c2/tc/Temp/noise_image
# Precipitation Nodes
@onready var m_noise = $c/tc/Precip/NoiseType/slider
@onready var m_freqeuncy = $c/tc/Precip/NoiseFrequency/slider
@onready var m_fractal = $c/tc/Precip/FractalType/slider
@onready var m_noise_image = $c2/tc/Precip/noise_image
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
		"water_max": h_water_max.value/100.0,
		"flat_max": h_flat_max.value/100.0,
		"hill_max": h_hill_max.value/100.0
	}
	return settings

func GetTemperatureSettings():
	var settings = {
		"noise": t_noise.value,
		"frequency": t_freqeuncy.value,
		"fractal": t_fractal.value
	}
	return settings

func GetPrecipitationSettings():
	var settings = {
		"noise": m_noise.value,
		"frequency": m_freqeuncy.value,
		"fractal": m_fractal.value,
	}
	return settings

func SetHeightTexture(texture: Texture2D):
	h_noise_image.texture = texture

func SetTemperatureTexture(texture: Texture2D):
	t_noise_image.texture = texture

func SetPrecipitationTexture(texture: Texture2D):
	m_noise_image.texture = texture

func _on_btn_generate_pressed():
	generate.emit()
