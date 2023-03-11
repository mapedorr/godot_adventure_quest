tool
extends Reference

const SUCCESS = 0
const ERR_ASEPRITE_CMD_NOT_FULL_PATH = 1
const ERR_ASEPRITE_CMD_NOT_FOUND = 2
const ERR_SOURCE_FILE_NOT_FOUND = 3
const ERR_OUTPUT_FOLDER_NOT_FOUND = 4
const ERR_ASEPRITE_EXPORT_FAILED = 5
const ERR_UNKNOWN_EXPORT_MODE = 6
const ERR_NO_VALID_LAYERS_FOUND = 7
const ERR_INVALID_ASEPRITE_SPRITESHEET = 8
const ERR_NO_ANIMATION_PLAYER_FOUND = 9
const ERR_NO_SPRITE_FOUND = 10
const ERR_UNNAMED_TAG_DETECTED = 11
const ERR_TAGS_OPTIONS_ARRAY_EMPTY = 12

## TODO: these messages are a bit dull, having params would be better.
## Maybe add a param argument

static func get_error_message(code: int):
	match code:
		ERR_ASEPRITE_CMD_NOT_FULL_PATH:
			return "Aseprite command not found at given path. Please check \"Project Settings > Popochiu > Import > Command Path\" to hold the FULL path to a valid Aseprite executable."
		ERR_ASEPRITE_CMD_NOT_FOUND:
			return "Aseprite command failed. Please, check if the right command is in your PATH or configured through \"Project Settings > Popochiu > Import > Command Path\"."
		ERR_SOURCE_FILE_NOT_FOUND:
			return "source file does not exist"
		ERR_OUTPUT_FOLDER_NOT_FOUND:
			return "output location does not exist"
		ERR_ASEPRITE_EXPORT_FAILED:
			return "unable to import file"
		ERR_INVALID_ASEPRITE_SPRITESHEET:
			return "aseprite generated bad data file"
		ERR_NO_VALID_LAYERS_FOUND:
			return "no valid layers found"
		ERR_NO_ANIMATION_PLAYER_FOUND:
			return "no animation player found in target node"
		ERR_NO_SPRITE_FOUND:
			return "no sprite found in target node"
		ERR_UNNAMED_TAG_DETECTED:
			return "unnamed tag detected"
		ERR_TAGS_OPTIONS_ARRAY_EMPTY:
			return "tags options array is empty"
		_:
			return "import failed with code %d" % code
