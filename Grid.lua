--- A Grid Matrix
-- @classmod Grid
-- @usage
-- -- Create a grid
-- local grid = Grid(x, y, num_rows, num_columns)
-- grid.mode = basic
-- grid.showCoords = true

Grid = class(Component)

--- Grid mode
-- @param basic Displays the grid with basic rectangles, borders, and functionality
-- @param basic_image Displays a grid of images with basic functionality
-- @param inventory (not implemented) The grid will be players inventory
-- @param container (not implemented) The grid will act as a container
-- @param data_store No grid rendering, provides only the grid matrix use
Grid.mode = "basic"

--- Displays grid cell coordinates on each cell
Grid.showCoords = true

--- Displays the bounding box
Grid.showBoundingBox = false
--- Grid bounding box border color
Grid.boundingBorderColor = "#545454"
--- Grid bounding box border size
Grid.boundingBorderSize = 1
--- Grid bounding box background color
Grid.boundingBackgroundColor = "black"
--- Grid bounding box padding
Grid.boundingPadding = 4

--- The padding between grid cells
Grid.cellPadding = 2
--- The width of each cell
Grid.cellWidth = 20
--- The height of each cell
Grid.cellHeight = 20
--- The linesize of the cell border
Grid.cellBorderSize = 1
--- The border color for cells
Grid.cellBorderColor = "white"
--- The color for background cells
Grid.cellBackgroundColor = "#CCCCCC"
-- The color
Grid.cellBackgroundHoverColor = "black"

--- Empty cell Container Image
Grid.cellBackgroundImage = "/interface/inventory/empty.png"

--- Constructs a Grid
--
-- @param x The x coordinate of the new component, relative to its parent
-- @param y The y coordinate of the new component, relative to its parent
-- @param rows The number of rows the grid wil have
-- @param cols The number of columns the grid will have
-- @param[opt] itemFactory
function Grid:_init(x, y, rows, cols, itemFactory)
	Component._init(self)

	self.mouseOver = false

	-- Grid Position relative to bottom left of parent component
	self.x = x
	self.y = y

	-- Grid Layout
	self.rows = rows
	self.cols = cols

	self.itemFactory = itemFactory or TextRadioButton

	-- Generate Grid Matrix
	self.matrix = self:genMatrix(rows, cols)

	self:updateCellItem()
end

--- Retrieve the item at the given grid coordinate
--
-- @param row The row the item is in
-- @param col The column the row is in
-- @return The item at the coordinate or nil if there is none.
function Grid:getItem(row, col)
	return self.matrix[row][col]["obj"]
end

--- Retrieve the coordinates of the given item
--
-- @param item The item to find the coordinate of
-- @return array The coordinates of the item, or nil if not found
function Grid:coordOfItem(item)
	for i = 1, self.rows do
		for j = 1, self.cols do
			if item == self.matrix[i][j]["obj"] then
				return self.matrix[i][j]["loc"]
			end
		end
	end

	return nil
end

--- Generates a grid matrix
--
-- @param rows The number of rows
-- @param cols The number of columns
-- @return array The matrix
function Grid:genMatrix(rows, cols)
	local matrix = {}

	for i = 1, rows do
		matrix[i] = {}
		for j = 1, cols do
			-- setup matrices cell structure and init stored data
			--@TODO id of item/object in grid space, count is how many of the item exists there.
			matrix[i][j] = { loc = {i, j}, obj = nil, id = 0, meta = {} }
		end
	end

	return matrix
end

--- Get the grid matrix
--
-- @return array The Matrix
function Grid:returnMatrix()
	return self.matrix
end

--- Constructs and adds an item to the grid
--
-- @return The new grid item
-- @return The grid coordinates of the new grid item
function Grid:emplaceItem(coords, ...)
	local width = self.cellWidth
	local height = self.cellHeight
	local coords = coords

	item = self.itemFactory(0, 0, width, height, ...)

	return self:addItem(item, coords)

end

--- Adds an item to the Grid
--
-- @param item The item to be added
-- @param coords Coordinate array ({row, col}) of where to add the item
-- @param[opt] itemId An id assigned to whatever is stored.
-- @param[opt] metaData Some meta data related to whatever is being stored
-- @return The item added to the grid
-- @return The coordinates of the item added
function Grid:addItem(item, coords, itemId, metaData)
	local item = item
	local coords = coords
	local itemId = itemId or 0
	local metaData = metaData or {}

	local row = coords[1]
	local col = coords[2]

	self:add(item)

	self.matrix[row][col] = { loc = coords, obj = item, id = itemId, meta = metaData }

	self:updateCellItem()

	return item, coords
end

--- Removes an item from the Grid
--
-- @param target Either a coordinate array, the stored item id, or the item to remove
-- @return The removed item or nil if item was not removed
function Grid:removeItem(target)
	local item
	local itemId
	local coords

	if type(target) == "array" then -- Remove by coord
		coords = target
		for i = 1, self.rows do
			for j = 1, self.cols do
				if self.matrix[i][j]["loc"] == coords then
					item = self.matrix[i][j]["obj"]
					self.matrix[i][j] = { loc = {i, j}, obj = nil, id = 0, meta = {} }
				end
			end
		end
		if not item then
			return nil
		end
	elseif type(target) == "number" then -- remove by item id
		itemId = target
		for i = 1, self.rows do
			for j = 1, self.cols do
				if self.matrix[i][j]["id"] == itemId then
					item = self.matrix[i][j]["obj"]
					self.matrix[i][j] = { loc = {i, j}, obj = nil, id = 0, meta = {} }
				end
			end
		end
		if not item then
			return nil
		end
	else -- remove by item
		for i = 1, self.rows do
			for j = 1, self.cols do
				if self.matrix[i][j]["obj"] == target then
					item = self.matrix[i][j]["obj"]
					self.matrix[i][j] = { loc = {i, j}, obj = nil, id = 0, meta = {} }
				end
			end
		end

		if not item then
			return nil
		end
	end

	self:remove(item)
	self:updateCellItem()

	return item
end

function Grid:update(dt)
	-- Logic

end

function Grid:draw(dt)
	if self.mode ~= "data_store" then
		-- offsets = absolute coords of lower left parent
		local startX = self.x - self.offset[1]
		local startY = self.y - self.offset[2]

		local border = self.boundingBorderSize

		-- Grid Bounding Box Width and Height
		local w =  (self.cellWidth * self.cols) + (border * 2) + (self.boundingPadding * 2) + (self.cellBorderSize * 2) + (self.cellPadding * 2) * self.cols
		local h =  (self.cellHeight * self.rows) + (border * 2) + (self.boundingPadding * 2) + (self.cellBorderSize * 2) + (self.cellPadding * 2) * self.rows


		local borderRect = { startX, startY, startX + w, startY + h }
		local backgroundRect = { startX + border, startY + border, startX + w - border, startY + h - border }

		if self.showBoundingBox then
			PtUtil.drawRect(borderRect, self.boundingBorderColor, border)
			PtUtil.fillRect(backgroundRect, self.boundingBackgroundColor)
		end

		--PtUtil.drawRect({ 1, 200, 1+326, 200 + 26 }, "white", 1)

		local bStartX = startX + border + self.boundingPadding - self.cellWidth - self.cellBorderSize
		local bStartY = startY + border + self.boundingPadding - self.cellHeight - self.cellBorderSize

		for i = 1, self.rows do
			for j = 1, self.cols do
				self:drawCell(bStartX, bStartY, i, j)
				self:drawCoords(bStartX, bStartY, i, j)
			end
		end
	end
end

--- Draws the individual cells
--
-- @param bStartX absolute x relative to parent lower left
-- @param bStartY absolute y relative to parent lower left
-- @param row The row of the cell
-- @param col The column of the cell
function Grid:drawCell(bStartX, bStartY, row, col)

	if self.mode == "basic_image" then
		-- @TODO: eventually this should be a rendering of the players inventory
		-- @TODO: change isInventory to a mode flag to determine how the grid is going to be used
		local position = {
			bStartX + (self.cellWidth + self.cellPadding) * col,
			bStartY + (self.cellHeight + self.cellPadding) * row
		}
		PtUtil.drawImage(self.cellBackgroundImage, position, 1)
	elseif self.mode == "basic" then

		local w = self.cellWidth
		local h = self.cellHeight

				-- ref: console.canvasDrawRect({x1, y1, x2, y2}, {color})
		local startX = bStartX + (w + self.cellPadding*2) * col
		local startY = bStartY + (h + self.cellPadding*2) * row

		local lineSize = self.cellBorderSize

		local borderRect = { startX, startY, startX + w, startY + h }
		local backgroundRect = { startX + lineSize, startY + lineSize, startX + w - lineSize, startY + h - lineSize }

		if lineSize then
			PtUtil.drawRect(borderRect, self.cellBorderColor, lineSize)
			PtUtil.fillRect(backgroundRect, self.cellBackgroundColor)
		else
			PtUtil.fillRect(borderRect, self.cellBackgroundColor)
		end
	end
end


-- Draws items contained in a cell, if they exist
function Grid:updateCellItem()
	local item
	local border = self.boundingBorderSize
	local bStartX = border + self.boundingPadding - self.cellWidth - self.cellBorderSize
	local bStartY = border + self.boundingPadding - self.cellHeight - self.cellBorderSize

	local matrix = self.matrix
	local rows = self.rows
	local cols = self.cols

	for i = 1, rows do
		for j = 1, cols do
			item = matrix[i][j]["obj"]
			if item ~= nil then
				item.x = bStartX + (self.cellWidth + self.cellPadding*2) * j
				item.y = bStartY + (self.cellHeight + self.cellPadding*2) * i
				item.visible = true
			end
		end
	end
end

--- Draws the coordinates on each cell
--
-- @param startX absolute x relative to parent lower left
-- @param startY absolute y relative to parent lower left
-- @param row The row of the cell
-- @param col The column of the cell
function Grid:drawCoords(bStartX, bStartY, row, col)
	if self.showCoords then
		local options = {
			position = {
				bStartX + (self.cellWidth +  self.cellPadding*2) * col,
				bStartY + (self.cellHeight + self.cellPadding*2) * row
			},
			verticalAnchor = "bottom"
		}
		PtUtil.drawText( tostring(self.matrix[row][col]["loc"][1]) .. "," .. tostring(self.matrix[row][col]["loc"][2]),  options, 7, "yellow" )
	end
end

function Grid:clickEvent(position, button, pressed)
	--[[ process clicks
	if button <= 3 then
		if self.onClick and not pressed and self.pressed then
			self:onClick(button)
		end
		world.logInfo("Click event Click event ==============>")
		return true
	end]]
end

-- [[ Many thanks to PenguinToast for thorough code examples and for creating the PenguinGUI ]]