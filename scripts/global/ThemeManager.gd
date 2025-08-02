# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ClientThemeManager extends Node
## Core script to manage theme constants


## All color values
class Colors:
	class ResolveHint:
		static var None					= Color.TRANSPARENT
		static var Select 				= Color("06b6d4")  ## Cyan
		static var Assign				= Color("06b6d4")  ## Cyan
		static var Store				= Color("22c55e")  ## Green
		static var Edit					= Color("22c55e")  ## Green
		static var Rename				= Color("eab308")  ## Yellow
		static var Execute				= Color("eab308")  ## Yellow
		static var Stop					= Color("ef4444")  ## Red
		static var Delete				= Color("ef4444")  ## Red
	
	class Selections:
		static var UnSelectedGray 		= Color(0.2, 0.2, 0.2, 0.8)
		static var SelectedGray			= Color(0.4, 0.4, 0.4, 0.8)


## Stylebox 
class StyleBoxes:
	static var UIPanelBase				= load("res://assets/styles/UIPanelBase.tres") ## Base style for all UIPanels
	static var UIPanelPopup				= load("res://assets/styles/UIPanelPopup.tres") ## Popup style for UIPanels
	static var PanelMenuBarBase			= load("res://assets/styles/PanelMenuBar.tres") ## Popup style for PanelManuBar
	static var PanelMenuBarPopup		= load("res://assets/styles/PanelMenuBarPopup.tres") ## Popup style for PanelManuBar Popup mode
	static var SelectBoxBackground		= load("res://assets/styles/SelectBoxBackground.tres") ## Stylebox for the SelectBox component
	static var GridPoint				= load("res://assets/styles/GridPoint.tres") ## Stylebox for the grid Point
	static var ResolveBoxStyle			= load("res://assets/styles/ResolveBoxStyle.tres") ## Stylebox for the ResolveBoxStyle
	static var ResolveBoxBGLess			= load("res://assets/styles/ResolveBoxBGLess.tres") ## Stylebox for the ResolveBox Background less


## Constants
class Constants:
	class Times:
		static var InterfaceFadeTime 	= 0.15
		static var DeskItemMoveTime		= 0.1
		static var SelectBoxMoceTime	= 0.06
		static var EditControlResolve	= 0.3
