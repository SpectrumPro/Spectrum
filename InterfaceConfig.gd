class_name InterfaceConfig

## File location to store the UI Save
var ui_save_location: String = "user://"

## File name to store the UI Save
var ui_save_file: String = "ui.json"

## Default items in the UICommandPalette
var command_palette_default_items: Array[CommandPaletteEntry] = [
		CommandPaletteEntry.new(
			Interface.settings_manager,
			"Interface",
		),
		CommandPaletteEntry.new(
			Network.settings_manager,
			"Network",
		),
		CommandPaletteEntry.new(
			Network.get_active_handler_by_name("Constellation").get_local_node().settings_manager, 
			"Constellation", 
		)
	]

## Default items in the UIObjectPicker
var object_picker_default_items: Dictionary[Script, ClassTreeConfig] = {
		EngineComponent: ClassTreeConfig.new(
			ClassList.get_global_class_tree(), 
			ClassList.get_inheritance_map(),
			ClassList.is_class_hidden, 
			ComponentDB.get_components_by_classname, 
			func (p_component: EngineComponent): return p_component.classname(),
			func (p_component: EngineComponent): return p_component.name(),
			ClassList.does_class_inherit,
			Core.create_component,
		),
		NetworkItem: ClassTreeConfig.new(
			NetworkClassList.get_global_class_tree(), 
			NetworkClassList.get_inheritance_map(),
			NetworkClassList.is_class_hidden, 
			Network.get_items_by_classname, 
			func (p_item: NetworkItem): return p_item.get_script().get_global_name(),
			func (p_item: NetworkItem): return p_item.get_handler_name() if p_item is NetworkHandler else p_item.get_session_name() if p_item is NetworkSession else p_item.get_node_name() if p_item is NetworkNode else "",
			NetworkClassList.does_class_inherit,
			Callable()
		)
	}
