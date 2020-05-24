extends Node

# Sinyaller
signal inputReceived(key)
signal snakeIsDead

# Yilan ile ilgili degiskenler
var initialTailLength = 3

# Hareket araligina iliskin zamanlama saniye
var moveDelay = 0.25

onready var Tail = preload("res://scenes/game/snake/tail/tail.tscn")

# Sabitler
onready var head = $SnakeHead
onready var moveTimer = $MoveTimer
onready var tailContainer = $TailContainer
onready var eatSound = $EatSound
onready var hitSound = $HitSound

onready var tailSpriteSize = getTailSpriteSize()
var currTailLength  = 0
var foodEaten  = false

# Ilk yilan yonumuz
const DEFAULT_DIRECTION = Vector2(-1,0)

# Dugum sahnede ilklendiginde cagrilacak olan metodumuz
func _ready():
	setupSignals()
	setMoveDelay(0.25)
	
	# sahne agacindan kolay bir sekilde ilk noktayi belirlemek için
	head.position = $InitialPosition.position
	
	instantiateTail()
	moveTimer.start()

# Girdilere ilişkin Godot fonksiyonu		
func _input(event):
	if event.is_action_pressed("left"):
		emit_signal("inputReceived", "left")
	elif event.is_action_pressed("right"):
		emit_signal("inputReceived", "right")
	elif event.is_action_pressed("up"):
		emit_signal("inputReceived", "up")
	elif event.is_action_pressed("down"):
		emit_signal("inputReceived", "down")
		
# Sinyalleri baglayalim
func setupSignals():
	# yilan hareketi icin
	self.connect("inputReceived", head, "changeDirection")
	
	# engellere carpma kontrolu
	head.connect("obstacleHit", self, "die")
	
	# bas ile kuyruklarinda hareket ettirilmesi icin
	head.connect("headMoved", self, "moveTail")
	head.connect("foodCollected", self, "setFoodEatenAsTrue")
	
# Yilanin hareket araligini belirleyeim
func setMoveDelay(moveDelay):
	moveTimer.set_wait_time(moveDelay)
		
# Baslangicta ne kadar kuyruk uzunlugu olacak
func setInitialTailLength(length):
	initialTailLength = length
	
# Ilk acilista yilanin kuyrugunu olusturalim
func instantiateTail():
	for i in range(1, initialTailLength + 1):
		var tailPos = head.position + (DEFAULT_DIRECTION * tailSpriteSize * i)
		growTail(tailPos)

# Verilen konuma kuyruk ekleyelim
func growTail(pos):
	var newTail = Tail.instance()
	tailContainer.add_child(newTail)
	newTail.position = pos
	currTailLength += 1

# kuyrugu hareket ettirelim
func moveTail(headPos):
	# Yeni meyve yersek bunu da basa ekliyoruz
	if foodEaten == true:
		growTail(headPos)
		foodEaten = false
		
	# hareket ile ilgili asil olay burada. Sondaki kuyrugu silip, basa ekliyoruz
	if currTailLength > 0:
		var tailToMove = tailContainer.get_children().pop_back()
		tailToMove.position = headPos
		tailContainer.move_child(tailToMove, 0)
		
# olum animasyonlarini tetikleyelim
func die():
	moveTimer.stop()
	hitSound.play()
	emit_signal("snakeIsDead")
	destroyWholeTail()
	print("Game over!")
	
# kuyrugun hepsini ucuralim
func destroyWholeTail():
	for tail in tailContainer.get_children():
		tail.runTween()

func getTailSpriteSize():
	var tail = Tail.instance()
	var sprite = tail.get_node("Sprite")
	var sprite_size = sprite.texture.get_size() * sprite.transform.get_scale()
	
	tail.free()
	
	return sprite_size

# meyve yenildi mi
func setFoodEatenAsTrue():
	eatSound.play()
	foodEaten = true
