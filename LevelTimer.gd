extends Label


# Declare member variables here. Examples:
var time_elapsed := 0.0
var minutes 
var seconds
var milliseconds
var finished = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	if(!finished):
		update_time()

func update_time():
	milliseconds =  fmod(time_elapsed, 1) * 100
	seconds = fmod(time_elapsed, 60)
	minutes = round(seconds / 60)
	
	self.text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
