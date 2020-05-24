extends StaticBody2D

onready var tween = $Tween

# Animasyon ile ilgili ayarlamaları yapalım
func _ready():
	configTween()

func configTween():
	tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0),
			0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.connect("tween_completed", self, "destroy_self")

# Ölüm animasyonunu başlatalım
func runTween():
	tween.start()

# Kuyruk yok olunca cağıracağız
func destroy_self(object, node):
	object.queue_free()
