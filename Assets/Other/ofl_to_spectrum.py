"""	
	WARNING: This script was hastily written with ChatGPT, (I was in a rush)
	and it may not adhere to best coding practices.
	There's a high likelihood that the file is janky and could break under certain conditions.
 	Additionally, be aware that running this script may override any pre-existing files in the output folder.
  
	THIS SCRIPT WILL BREAK (It was only intended for development purposes).  
 
	This script is for converting OFL JSON fixture files into Spectrum fixture files.
 	It is by far not perfect and does not support all of the features used in the OFL JSON files.
  	The Spectrum fixture files outputted by this script may have some issues,
   	and some channels and their capabilities may not be recognized by Spectrum.
    Thus, requiring manual DMX programming of those channels.
    It is recommended to use Spectrum's fixture creation tool (coming soon),
    to recreate any fixtures that have problems when converted from OFL.
    
    THE VERSION OF THE SCRIPT HERE IS OLD, AND WILL TRY AND CREATE A FIXTURE MANIFEST THAT IS NOT SUPPORTED IN THE CURRENT SPECTRUM VERSION
    (I'll update it sometime)
"""

import os
import json

def convert_capabilities(capabilities):
    converted_capabilities = []
    for capability in capabilities:
        if isinstance(capability, dict):  # Check if 'capability' is already a dictionary
            converted_capabilities.append(capability)
        elif isinstance(capability, list):  # Check if 'capability' is a list
            for cap in capability:
                if isinstance(cap, dict):  # Check if each item in the list is a dictionary
                    converted_capabilities.append(cap)
    return converted_capabilities


def resolve_template_channels(template_channels, pixel_keys):
    resolved_channels = []
    for pixel_key in pixel_keys:
        for template_channel in template_channels:
            resolved_channel = template_channel.replace("$pixelKey", pixel_key)
            resolved_channels.append(resolved_channel)
    return resolved_channels

def has_matrix(ofl_fixture):
    matrix_info = ofl_fixture.get("matrix", {})
    return bool(matrix_info)

def convert_to_new_schema(ofl_fixture):
    new_fixture = {
        "schema_version": "1.0",
        "minimum_spectrum_version": "2.1",
        "info": {
            "name": ofl_fixture.get("name", ""),
            "brand": ofl_fixture.get("manufacturerKey", ""),
            "website": ofl_fixture.get("oflURL", ""),
            "videos": [],
            "date": ofl_fixture.get("meta", {}).get("lastModifyDate", ""),
            "author": ", ".join(ofl_fixture.get("meta", {}).get("authors", [])),
            "oflurl": ofl_fixture.get("oflURL", ""),
            "categories": ofl_fixture.get("categories", [])
        },
        "channels": {},
        "modes": []
    }

    pixel_keys = []

    matrix_info = ofl_fixture.get("matrix", {})
    pixel_keys_info = matrix_info.get("pixelKeys", [])
    if pixel_keys_info:
        pixel_keys = [key for row in pixel_keys_info[0] for key in row if key]

    for channel_name, channel_info in ofl_fixture.get("availableChannels", {}).items():
        capabilities_key = "capabilities" if "capabilities" in channel_info else "capability"
        capabilities = channel_info.get(capabilities_key, [])  # Use 'capabilities' or 'capability' based on key
        new_channel = {
            "capabilities": capabilities
        }

        new_fixture["channels"][channel_name] = new_channel

    for mode in ofl_fixture.get("modes", []):
        mode_entry = {
            "name": mode.get("name", ""),
            "shortName": mode.get("shortName", ""),
            "channels": []
        }

        for channel in mode.get("channels", []):
            if isinstance(channel, str):
                mode_entry["channels"].append(channel)
            elif isinstance(channel, dict):
                insert_data = channel.get("insert", "")
                if insert_data == "matrixChannels":
                    repeat_for = channel.get("repeatFor", "")
                    channel_order = channel.get("channelOrder", "")
                    template_channels = channel.get("templateChannels", [])
                    if repeat_for == "eachPixelXYZ" and channel_order == "perPixel":
                        resolved_channels = resolve_template_channels(template_channels, pixel_keys)
                        mode_entry["channels"].extend(resolved_channels)
                    else:
                        mode_entry["channels"].append(channel.get("name", ""))
                else:
                    mode_entry["channels"].append(channel.get("name", ""))

        new_fixture["modes"].append(mode_entry)

    return new_fixture

def process_fixtures(input_directory, output_directory):
    for manufacturer_folder in os.listdir(input_directory):
        manufacturer_path = os.path.join(input_directory, manufacturer_folder)

        if os.path.isdir(manufacturer_path):
            for fixture_file in os.listdir(manufacturer_path):
                fixture_path = os.path.join(manufacturer_path, fixture_file)

                if os.path.isfile(fixture_path):
                    with open(fixture_path, "r") as ofl_file:
                        ofl_fixture = json.load(ofl_file)

                    if has_matrix(ofl_fixture):
                        print(f"Skipping fixture '{ofl_fixture.get('name', '')}' as it uses matrices.")
                        continue

                    new_fixture = convert_to_new_schema(ofl_fixture)

                    output_manufacturer_path = os.path.join(output_directory, manufacturer_folder)
                    os.makedirs(output_manufacturer_path, exist_ok=True)

                    output_fixture_path = os.path.join(output_manufacturer_path, fixture_file)
                    with open(output_fixture_path, "w") as new_file:
                        json.dump(new_fixture, new_file, indent=2)

def main():
    input_directory = "" # OFL fixture folder
    output_directory = "" # Output Folder

    process_fixtures(input_directory, output_directory)

if __name__ == "__main__":
    main()
