extends Node

var logoBlurLevel = 0
var logoBlurThreshold = 4

# 2 second wait
var waitTime = 4
var logoBlurIncrementAmount = -5
var performAnimation = true

func _ready():
	logoBlurLevel = $Logo.get_material().get_shader_param("radius")

# our logo will appear and then disapper with corresponding audio effect
func _process(delta):
	if performAnimation == true :
		logoBlurLevel += (logoBlurIncrementAmount*delta)
		$Logo.get_material().set_shader_param("radius", logoBlurLevel)
	else :
		if waitTime > 0:
			waitTime -= delta
			
			if $Logo.visible == true and waitTime < 2:
				$Logo.visible = false
				$Logo2.visible = true
		else :
			_on_Splash_splashCompleted()
	
	if logoBlurLevel < logoBlurThreshold:
		performAnimation = false
		logoBlurIncrementAmount *= (-2)   
		logoBlurLevel = logoBlurThreshold
		$Logo.get_material().set_shader_param("radius", logoBlurLevel)
		$LogoSound.set_volume_db(0.5)
		$LogoSound.play()

func _on_Splash_splashCompleted():
	global.goto_scene("res://scenes/game/main/main.tscn")
