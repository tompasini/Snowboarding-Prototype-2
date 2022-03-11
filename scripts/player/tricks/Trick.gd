extends Node2D

var animated_sprite

func _init(animated_sprite):
	self.animated_sprite = animated_sprite

func execute_trick( animation):
	animated_sprite.play(animation)

func completed_trick():
	pass
	
func continuous_trick(value, modifier):
	value += modifier
	return value
