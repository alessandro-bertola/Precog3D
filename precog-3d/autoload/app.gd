extends Node
## Application entry and scene routing. Development build by default.

const BUILD_DEV := true

func go_boot() -> void:
	get_tree().change_scene_to_file(Conventions.SCENE_BOOT)


func go_test() -> void:
	get_tree().change_scene_to_file(Conventions.SCENE_TEST)


func go_level() -> void:
	get_tree().change_scene_to_file(Conventions.SCENE_LEVEL)
