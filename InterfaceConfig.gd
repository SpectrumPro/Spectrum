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
		),
		CommandPaletteEntry.new(
			CommandPaletteEntry.ObjectType.GLOBAL, 
			CommandPaletteEntry.DeleteSignalOrigin.PER_CLASS,
			Network.get_active_handler_by_name("Constellation").get_local_node().settings_manager, 
			"Constellation", 
			Signal(),
			Signal()
		)
	],
	"object_picker_default_items": {
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
}
