PenguinGUI-Grid
===============

A Grid component for PenguinGUI


This is a component for PenguinGUI (http://penguintoast.github.io/PenguinGUI/) an OO GUI Library for Starbound lua canvases

![alt Screenshot](http://i.imgur.com/YQAQtND.jpg)

## Usage
Place Grid.lua alongside PenguinGUI's files in your mod.

Reference Grid.lua after PenguinGUI in your object configuration and interface configuration files
```json
"scripts" : ["/scripts/penguinui/Util.lua", "/scripts/penguinui/Grid.lua"]
```

Within your interface LUA script initialize the grid like other components and add it to your GUI
```lua
--local grid = Grid(x, y, rows, columns)
local grid = Grid(1, 1, 3, 4)
--grid.option = xxx

GUI.add(grid)
```

##Options

The grid component comes with many options




