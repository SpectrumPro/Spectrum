static var config: Dictionary = {
	## Defines a custom callable to call when logging infomation
	"custom_loging_method": Callable(),
	
	## Defines a custom callable to call when logging infomation verbosely
	"custom_loging_method_verbose": Callable(),
	
	## A String prefix to print before all message logs
	"log_prefix": "CTL:",
	
	## Default IP address to bind to
	"bind_address": "",
	
	## Default IP address to bind to
	"bind_interface": "",
	
	## File location for a user config override
	"user_config_file_location": "user://",
	
	## File name for the user config override
	"user_config_file_name": "constellation.conf"
}
