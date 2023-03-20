@tool
extends PopochiuHotspot
# You can use E.run([]) to trigger a sequence of events.
# Use await E.run([]) if you want to pause the excecution of
# the function until the sequence of events finishes.


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ VIRTUAL ░░░░
# When the node is clicked
func _on_click() -> void:
	await C.Goddiu.walk_to_hotspot(script_name)
	await C.Goddiu.face_left()
	await C.Goddiu.say('Oh... [wave]freedom...[/wave]')
	
	G.done()


# When the node is right clicked
func _on_right_click() -> void:
	# Replace the call to super() to implement your code. This only makes
	# the default behavior to happen.
	# For example you can make the character walk to the Hotspot and then say
	# something:
#	E.run([
#		C.face_clicked(),
#		'Player: A closed door'
#	])
	super.on_right_click()


# When the node is clicked and there is an inventory item selected
func _on_item_used(item: PopochiuInventoryItem) -> void:
	if item.script_name == 'ToyCar':
		await C.Goddiu.say('Boing!')
		await I.ToyCar.discard()
		
		G.done()
