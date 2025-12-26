# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name NetworkItem extends Node
## Base class for all NetworkHandlers, HetworkNodes, and NetworkSessions

@warning_ignore("unused_signal")

## Emited when this session is to be deleted after all nodes disconnect
signal request_delete()
