class_name InterfaceConfig

static var config: Dictionary = {
	"command_palette_default_items": [
		CommandPaletteEntry.new(
			CommandPaletteEntry.ObjectType.GLOBAL,
			CommandPaletteEntry.DeleteSignalOrigin.NONE,
			Interface.settings_manager,
			"Interface",
		),
		CommandPaletteEntry.new(
			CommandPaletteEntry.ObjectType.GLOBAL,
			CommandPaletteEntry.DeleteSignalOrigin.NONE,
			Network.settings_manager,
			"Network",
		)
	],
	"object_picker_default_items": {
		EngineComponent: ClassTreeConfig.new(
			ClassList.get_global_class_tree(), 
			ClassList.is_class_hidden, 
			ComponentDB.get_components_by_classname, 
			func (p_component: EngineComponent): return p_component.self_class_name,
			func (p_component: EngineComponent): return p_component.name,
		),
		NetworkItem: ClassTreeConfig.new(
			NetworkClassList.get_global_class_tree(), 
			NetworkClassList.is_class_hidden, 
			Network.get_items_by_classname, 
			func (p_item: NetworkItem): return p_item.get_script().get_global_name(),
			func (p_item: NetworkItem): return p_item.get_handler_name() if p_item is NetworkHandler else p_item.get_session_name() if p_item is NetworkSession else p_item.get_node_name() if p_item is NetworkNode else "",
		)
	}
}
