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

##Modes
The mode is a way to define how you intend to use the Grid Component and there are several options

* `basic` - Basic functionality makes use of background and border colors
* `basic_image` - Image functionality, this provides a way to use background images/hover images etc across the grid
* `inventory` - (not implemented yet) Inventory mode will create an ItemGrid Widget of the players inventory
* `container` - (not implemented yet) Container mode will create an ItemGrid Widget such as those in storage objects
* `data_store` - Datastore mode creates the grid matrix, but does not draw the grid, providing a way to use the grid matrix as a simple databank if needed. 

##TODO

There are some planned features currently not implemented.
* bindings
* event listeners for clicks/keypress' etc..
* more control/customization over images in grid cells
* hovering effects


