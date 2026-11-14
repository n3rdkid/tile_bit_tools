@tool
extends EditorPlugin

const G := preload("res://addons/tile_bit_tools/core/globals.gd")

const PLUGIN_NAME := "tile_bit_tools"

var texts := preload("res://addons/tile_bit_tools/core/texts.gd").new()
var output := preload("res://addons/tile_bit_tools/core/output.gd").new()

var plugin : EditorInspectorPlugin


func _enter_tree() -> void:
	output.debug("plugin.gd : _enter_tree()")
	output.info("Initializing TileBitTools v%s..." % G.VERSION)

	_setup_project_settings()

	plugin = preload("inspector_plugin.gd").new()
	add_inspector_plugin(plugin)
	var result : G.Errors = plugin.setup(get_editor_interface())
	if result != OK:
		output.user("Unable to initialize, disabling plugin")
		# Disabling a plugin from inside its own _enter_tree() crashes the
		# editor in recent Godot versions, so wait until we are out of it.
		_disable_self.call_deferred()
		return
	output.info("Initialization complete")
	output.user(texts.WELCOME_MESSAGE)
	output.user(texts.WELCOME_MESSAGE2)


func _disable_self() -> void:
	EditorInterface.set_plugin_enabled(PLUGIN_NAME, false)


# Called by the editor whenever it resets its state (after loading the
# layout, when closing scenes, ...). Only drop the per-selection inspector
# here: freeing the shared nodes left the plugin in a broken state until
# the next selection.
func _clear() -> void:
	output.debug("plugin.gd : _clear()")
	if plugin:
		plugin.clear_tiles_inspector()


func _exit_tree() -> void:
	output.debug("plugin.gd : _exit_tree()")
	output.info("Cleaning up...")
	if plugin:
		plugin.clean_up()
		remove_inspector_plugin(plugin)
		plugin = null




func _setup_project_settings() -> void:
	for key in G.Settings.keys():
		var setting : Dictionary = G.Settings[key]
		if !ProjectSettings.has_setting(setting.path):
			ProjectSettings.set(setting.path, setting.default)

		ProjectSettings.set_initial_value(setting.path, setting.default)
		ProjectSettings.add_property_info({
			"name": setting.path,
			"type": setting.type,
			"hint_string": setting.get("hint_string", null),
		})



