extends Area2D

# Bu script araciligiyla yayinlayacagim olaylar
signal foodCollected # Meyve yedik
signal obstacleHit # Duvar ya da engellere carptik
signal headMoved(prevHeadPos) # Bas hareketini bir onceki konum ile iletelim. Mevcut konum zaten position'dan temin edilebilir

# Kullandigimiz bazi sabitler
const DIRECTION_RIGHT = Vector2(1,0)
const DIRECTION_LEFT  = Vector2(-1,0)
const DIRECTION_UP    = Vector2(0,-1)
const DIRECTION_DOWN  = Vector2(0,1)
const DIRECTION_NONE  = Vector2(0,0)

# Hareket ile ilgili bazi sabitler
var spriteSize
var currDir = DIRECTION_NONE
var prevDir = DIRECTION_NONE

var canChangeDir = true

# Sahne ile yuklenen bazi sabitler
onready var sprite = $Sprite
onready var tween = $Tween

# Her oyun dongu devrinde cagrilecek olan fonksiyonumuz
func _ready():
	canChangeDir = true
	spriteSize = sprite.texture.get_size() * sprite.transform.get_scale()
	configTween()

# Animasyon fonksiyonu. yılanımız öldüğü zaman cagrilacak
func configTween():
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0),
			0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)	
	tween.connect("tween_completed", self, "destroy_self")
	
# Yilanin basinin hareketinden sorumlu fonksiyon 
func move(direction):
	translate(direction * spriteSize)
		
# Mevcut durumda harekete devam. Bunu bir sayac araciligiyle ust sahnelerden cagiracagiz
func onMoveTimer_timeout():
	# mevcut konumu bir saklayalim
	var prevHeadPos = position
	
	# simdi sprite'i hareket ettirelim
	move(currDir)
	prevDir = currDir
	
	if currDir != DIRECTION_NONE and prevDir != DIRECTION_NONE:
		emit_signal("headMoved", prevHeadPos)

# Mevcut Area2D tipindeki Head node'muz bir sey ile kesistiginde cagrilan fonksiyondur
# bunun icin elbette ilgili sinyali Node sekmesinden bu fonksiyona baglamaliyiz.
# solda yesil bir sembol gormemiz gerekiyor
func onHead_body_entered(body):
	if body.is_in_group("Food"): # meyve
		emit_signal("foodCollected")
		
		# meyveyi silelim
		body.queue_free()
		print("[DEBUG] Food collected")	
	elif body.is_in_group("Obstacle"): # engel'e mi carptik. Bu isim gruplardan geliyor.
		emit_signal("obstacleHit")
		tween.start()
	
# Yilanimizin basini ceviriyoruz
func changeDirection(request):
	if canChangeDir == true:
		if request == "left" and prevDir != DIRECTION_RIGHT:
			currDir = DIRECTION_LEFT
			sprite.rotation = deg2rad(180.0)
		elif request == "right" and prevDir != DIRECTION_LEFT:
			currDir = DIRECTION_RIGHT
			sprite.rotation = deg2rad(0.0)
		elif request == "up" and prevDir != DIRECTION_DOWN:
			currDir = DIRECTION_UP			
			sprite.rotation = deg2rad(-90.0)
		elif request == "down" and prevDir != DIRECTION_UP:
			currDir = DIRECTION_DOWN			
			sprite.rotation = deg2rad(90.0)
	
	
