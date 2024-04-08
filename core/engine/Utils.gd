# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Utils extends Object
## Usefull function that would be annoying to write out each time

static func save_json_to_file(file_path: String, file_name: String, json: Dictionary) -> Error:
	
	var file_access: FileAccess = FileAccess.open(file_path+"/"+file_name, FileAccess.WRITE)
	
	if FileAccess.get_open_error():
		return FileAccess.get_open_error()
	
	print(JSON.stringify(json, "\t"))
	file_access.store_string(JSON.stringify(json, "\t"))
	file_access.close()
	
	return file_access.get_error()


static func serialize_variant(variant: Variant) -> Variant:
	return var_to_str(variant)
	#match typeof(variant):
		#TYPE_COLOR:
			#return "#" + variant.to_html()
			#
	#return ERR_INVALID_DATA


static func deserialize_variant(variant: Variant) -> Variant:
	return str_to_var(variant)
	#match typeof(variant):
		#TYPE_STRING:
			#match variant[0]:
				#"#":
					#print(variant.right(8))
					#return Color.from_string(variant.right(8), Color.BLACK)
	#
	#return ERR_INVALID_DATA


static func get_htp_color(color_1: Color, color_2: Color) -> Color:
	# Calculate the intensity of each channel for color1
	var intensity_1_r = color_1.r
	var intensity_1_g = color_1.g
	var intensity_1_b = color_1.b

	# Calculate the intensity of each channel for color2
	var intensity_2_r = color_2.r
	var intensity_2_g = color_2.g
	var intensity_2_b = color_2.b

	# Compare the intensities for each channel and return the color with the higher intensity for each channel
	var result_color = Color()
	result_color.r = intensity_1_r if intensity_1_r > intensity_2_r else intensity_2_r
	result_color.g = intensity_1_g if intensity_1_g > intensity_2_g else intensity_2_g
	result_color.b = intensity_1_b if intensity_1_b > intensity_2_b else intensity_2_b

	return result_color

