# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name StartUpNotice extends Object
## StartUpNotice


## The title of the notice
var _title: String = ""

## The resource path for an icon associated with the title
var _title_icon: String = ""

## The version string for this notice
var _version: String = ""

## The date of this notice
var _date: String = ""

## The BBCode body of the notice
var _bbcode_body: String = ""

## The text shown on the confirm button
var _confirm_button_text: String = ""

## The URL for the link button
var _link_url: String = ""

## The text shown on the link button
var _link_text: String = ""

## The ID of this notice, used for "dont show again"
var _notice_id: String = ""


## init
func _init(
	p_title: String = "",
	p_title_icon: String = "",
	p_version: String = "",
	p_date: String = "",
	p_bbcode_body: String = "",
	p_confirm_button_text: String = "",
	p_link_url: String = "",
	p_link_text: String = "",
	p_notice_id: String = ""
) -> void:
	_title = p_title
	_title_icon = p_title_icon
	_version = p_version
	_date = p_date
	_bbcode_body = p_bbcode_body
	_confirm_button_text = p_confirm_button_text
	_link_url = p_link_url
	_link_text = p_link_text
	_notice_id = p_notice_id


## Sets the title of the notice
func set_title(p_title: String) -> StartUpNotice:
	_title = p_title
	return self


## Sets the icon associated with the title
func set_title_icon(p_title_icon: String) -> StartUpNotice:
	_title_icon = p_title_icon
	return self


## Sets the version of this notice
func set_version(p_version: String) -> StartUpNotice:
	_version = p_version
	return self


## Sets the date of this notice
func set_date(p_date: String) -> StartUpNotice:
	_date = p_date
	return self


## Sets the BBCode body of the notice
func set_bbcode_body(p_bbcode_body: String) -> StartUpNotice:
	_bbcode_body = p_bbcode_body
	return self


## Sets the text shown on the confirm button
func set_confirm_button_text(p_confirm_button_text: String) -> StartUpNotice:
	_confirm_button_text = p_confirm_button_text
	return self


## Sets the URL for the link button
func set_link_url(p_link_url: String) -> StartUpNotice:
	_link_url = p_link_url
	return self


## Sets the text shown on the link button
func set_link_text(p_link_text: String) -> StartUpNotice:
	_link_text = p_link_text
	return self


## Sets the ID of this notice
func set_notice_id(p_notice_id: String) -> StartUpNotice:
	_notice_id = p_notice_id
	return self


## Returns the title of the notice
func get_title() -> String:
	return _title


## Returns the icon associated with the title
func get_title_icon() -> String:
	return _title_icon


## Returns the version of this notice
func get_version() -> String:
	return _version


## Returns the date of this notice
func get_date() -> String:
	return _date


## Returns the BBCode body of the notice
func get_bbcode_body() -> String:
	return _bbcode_body


## Returns the text shown on the confirm button
func get_confirm_button_text() -> String:
	return _confirm_button_text


## Returns the URL for the link button
func get_link_url() -> String:
	return _link_url


## Returns the text shown on the link button
func get_link_text() -> String:
	return _link_text


## Returns the ID of this notice
func get_notice_id() -> String:
	return _notice_id
