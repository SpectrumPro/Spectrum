# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name StartUpNoticeContainer extends Control
## Displays a StartUpNotice


## Emitted when this notice has been acknowledged
signal closing(dont_show_again: bool)


## The RichTextLabel to show the message
@export var rich_text_label: RichTextLabel

## The Link button
@export var link_button: Button

## The confirm button
@export var confirm_button: Button

## The DontShowAgain Button
@export var dont_show_again_button: Button


## The current notice
var _notice: StartUpNotice

## Template BBCode for the icon
var _icon_template: String = "[img=32]{PATH}[/img] "

## Template BBCode for the title
var _title_template: String = "[b][font_size=30]{TITLE}[/font_size][/b]"

## Template BBCode for the version and date prefixed with a new line
var _version_and_data_template: String = "\n[color=#ccc][font_size=10]{VERSION} | {DATE}[/font_size][/color] "


## Sets the startup notice
func set_notice(p_notice: StartUpNotice) -> void:
	rich_text_label.clear()
	link_button.hide()
	dont_show_again_button.set_pressed_no_signal(false)
	
	_notice = p_notice
	
	if not is_instance_valid(p_notice):
		return
	
	var bbcode: String = ""
	
	if _notice.get_title_icon():
		bbcode += _icon_template.replace("{PATH}", _notice.get_title_icon())
	
	bbcode += _title_template.replace("{TITLE}", _notice.get_title() if _notice.get_title() else "Notice!")
	bbcode += _version_and_data_template.replacen("{VERSION}", _notice.get_version() if _notice.get_version() else Details.version)\
	.replace("{DATE}", _notice.get_date() if _notice.get_date() else Time.get_date_string_from_system())
	
	bbcode += "\n"
	bbcode += "\n"
	bbcode += _notice.get_bbcode_body()
	
	rich_text_label.set_text(bbcode)
	
	if _notice.get_confirm_button_text():
		confirm_button.set_text(_notice.get_confirm_button_text())
	
	link_button.set_visible(_notice.get_link_url() != "")
	link_button.set_text(_notice.get_link_text())


## Gets the notice
func get_notice() -> StartUpNotice:
	return _notice


## Called when the link button is pressed
func _on_link_button_pressed() -> void:
	OS.shell_open(_notice.get_link_url())


## Called when the confirm button is presse
func _on_confirm_button_pressed() -> void:
	var dont_show_again: bool = dont_show_again_button.is_pressed()
	closing.emit(dont_show_again)
	
	Interface.config().notice_dont_show_again(_notice.get_notice_id())
	Interface.fade_and_hide(self, queue_free)
