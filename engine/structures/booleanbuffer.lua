local ffi = require "ffi"

local _max, _min = math.max, math.min

--- A class representing a 2D boolean buffer implemented as a densely packed C type.
--- @class BooleanBuffer : Object
local BooleanBuffer = prism.Object:extend("BooleanBuffer")

--- Constructor for the BooleanBuffer class.
--- @param w integer The width of the buffer.
--- @param h integer The height of the buffer.
function BooleanBuffer:__new(w, h)
   self.w = w
   self.h = h

   -- Initialize the buffer with false values
   self.buffer = ffi.new("bool[?]", w * h)
end

--- Calculate the index in the buffer array for the given coordinates.
--- @param x integer The x-coordinate (1-based).
--- @param y integer The y-coordinate (1-based).
--- @return integer index The corresponding index in the buffer array.
function BooleanBuffer:getIndex(x, y)
   assert(x > 0 and y > 0, "Index out of bounds (" .. x .. ", " .. y .. ")")
   assert(x <= self.w and y <= self.h, "Index out of bounds (" .. x .. ", " .. y .. ")")
   return (y - 1) * self.w + (x - 1)
end

--- Clear the buffer, setting all values to false.
function BooleanBuffer:clear()
   ffi.fill(self.buffer, ffi.sizeof("bool") * self.w * self.h)
end

--- Set the value at the given coordinates.
--- @param x integer The x-coordinate (1-based).
--- @param y integer The y-coordinate (1-based).
--- @param v boolean The value to set.
function BooleanBuffer:set(x, y, v)
   self.buffer[self:getIndex(x, y)] = v
end

--- Get the value at the given coordinates.
--- @param x integer The x-coordinate (1-based).
--- @param y integer The y-coordinate (1-based).
--- @return boolean value The value at the given coordinates.
function BooleanBuffer:get(x, y)
   return self.buffer[self:getIndex(x, y)]
end

return BooleanBuffer
