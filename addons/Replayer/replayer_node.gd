"""
Copyright 2022 Alexander Forselius <drsounds@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
"""


extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer = Timer.new()
var pos = 0

var animation = []


var current_frame = []

export (int) var wait_time setget  set_wait_time, get_wait_time

export var output_path = ''

var mode = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = 0.01
	timer.connect('timeout', self, '_on_tick')
	

func get_wait_time():
	return self.timer.wait_time
	
func set_wait_time(value):
	self.timer.wait_time = value

func _input(event): 
	for action in InputMap.get_actions():
		print(action)
		if Input.is_action_just_pressed(action):
			if action == 'replayer.record':
				if mode != 'record':
					record()
				else:
					stop()
			if action == 'replayer.play':
				play()
			if action == 'replayer.stop':
				stop()
			if action == 'replayer.pause':
				pause()
			if action == 'replayer.resume':
				resume()
		if Input.is_action_just_pressed(action):		
			if mode == 'record' and action.find("replayer") != 0:
				current_frame.append({
					'action': action,
					'is_pressed': true,
					'type': 'input'
			})
		if Input.is_action_just_released(action):		
			if mode == 'record' and action.find("replayer") != 0:
					
				current_frame.append({
					'action': action,
					'is_pressed': false,
					'type': 'input'
			})
	
func record():
	mode = 'record'
	pos = 0
	animation = []
	current_frame = []
	timer.start()
	
	
func play(position = 0):
	var f := File.new()
	if f.file_exists(output_path):
		mode = 'play' 
		f.open(output_path, File.READ)
		var data = f.get_as_text() 
		var json = JSON.parse(data).result
		animation = json['frames']
		
		pos = position
		timer.start()
		
func pause():
	self.timer.stop()

func resume():
	self.timer.start()


func stop():
	timer.stop()
	if mode == 'record':
		var f := File.new()
		f.open(output_path, File.WRITE)
		f.store_string(JSON.print({"frames": animation}))
		f.close()
	pos = 0

func _on_tick():
	if mode == 'record':
		animation.append(current_frame)
		current_frame = []
		pos = pos + 1
	elif mode == 'play':
		if pos < len(animation):
			var events = animation[pos]
			if len(events) > 0:
				for event in events:
					if event['type'] == 'input':
						var a = InputEventAction.new()
						a.pressed = event['is_pressed']
						a.action = event['action']
						if a.action and a.action.find("replayer") != 0:
							Input.parse_input_event(a)
			pos = pos +1
		else:
			pos = 0
			stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
