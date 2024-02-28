class_name PopochiuIDialog
extends Node
## Provides access to the [PopochiuDialog]s in the game. Access with [b]D[/b] (e.g.
## [code]C.AskAboutLoom.start()[/code]).
##
## Use it to work with branching dialogs and listen to options selection. Its script is
## [b]i_dialog.gd[/b].
##
## Some things you can do with it:[br][br]
## [b]•[/b] Start a branching dialog.
## [b]•[/b] Know when a dialog has finished, or an option in the current list of options is selected.
## [b]•[/b] Create a list of options on the fly.
##
## Example:
## [codeblock]
## func on_click() -> void:
##    # Create a dialog with 3 options
##    var opt: PopochiuDialogOption = await D.show_inline_dialog([
##        "Ask Popsy something", "Give Popsy a hug", "Do nothing"
##    ])
##
##    # The options IDs will go from 0 to the size - 1 of the array passed to D.show_inline_dialog
##    match opt.id:
##        "0": # "Ask Popsy something" was selected
##            D.ChatWithPopsy.start() # Start the ChatWithPopsy dialog
##        "1": # "Give Popsy a hug"  was selected
##            await C.walk_to_clicked()
##            await C.player.play_hug()
##        "2": # "Do nothing" was selected
##            await C.player.say("Maybe later...")
## [/codeblock]

## Emitted when [param dlg] starts.
signal dialog_started(dlg: PopochiuDialog)
## Emitted when an [param opt] is selected in the current dialog.
signal option_selected(opt: PopochiuDialogOption)
## Emitted when [param dlg] finishes.
signal dialog_finished(dlg: PopochiuDialog)
## Emitted when the list of available [param options] in the current dialog is requested.
signal dialog_options_requested(options: Array[PopochiuDialogOption])
## Emitted when an inline dialog is created based on a list of [param options].
signal inline_dialog_requested(options: Array)

var active := false
var trees := {}
var current_dialog: PopochiuDialog = null : set = set_current_dialog
var selected_option: PopochiuDialogOption = null
var prev_dialog: PopochiuDialog = null


#region Public #####################################################################################
# Shows a list of options (like a dialog tree would do) and returns the
# PopochiuDialogOption of the selected option
func show_inline_dialog(opts: Array) -> PopochiuDialogOption:
	active = true
	
	if current_dialog:
		D.option_selected.disconnect(current_dialog._on_option_selected)
	
	inline_dialog_requested.emit(opts)
	
	var pdo: PopochiuDialogOption = await option_selected
	
	if current_dialog:
		D.option_selected.connect(current_dialog._on_option_selected)
	else:
		active = false
		G.unblock()
	
	return pdo


# Finishes the dialog currently in execution.
func finish_dialog() -> void:
	dialog_finished.emit(current_dialog)


func say_selected() -> void:
	await C.player.say(selected_option.text)


#endregion

#region SetGet #####################################################################################
func set_current_dialog(value: PopochiuDialog) -> void:
	current_dialog = value
	active = true
	
	await self.dialog_finished
	
	# Save the state of the dialog
	trees[current_dialog.script_name] = current_dialog
	
	active = false
	current_dialog = null
	selected_option = null


#endregion
