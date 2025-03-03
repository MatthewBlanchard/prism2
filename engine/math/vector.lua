---@module 'Vector2''
--- @alias DistanceType
--- | "euclidean"
--- | "chebyshev"
--- | "manhattan"
--- | "4way"
--- | "8way"

--- 4way is an alias for manhattan distance
--- 8way is an alias for chebyshev distance

---@class Vector2 : Object
--- A Vector2 represents a 2D vector with x and y components.
---@overload fun(x: number, y: number): Vector2
---@operator add(Vector2): Vector2
---@operator sub(Vector2): Vector2
---@operator mul(Vector2): Vector2
---@operator unm(): Vector2
---@field x number The x component of the vector.
---@field y number The y component of the vector.
local Vector2 = prism.Object:extend("Vector2")

--- Constructor for Vector2 accepts two numbers, x and y.
---@param x number The x component of the vector.
---@param y number The y component of the vector.
function Vector2:__new(x, y)
   self.x = x or 0
   self.y = y or 0
end

--- Returns a copy of the vector.
---@return Vector2 # A copy of the vector.
function Vector2:copy()
   return Vector2(self.x, self.y)
end

--- Returns the length of the vector.
---@return number # The length of the vector.
function Vector2:length()
   return math.sqrt(self.x * self.x + self.y * self.y)
end

--- Rotates the vector clockwise.
---@return Vector2 The rotated vector.
function Vector2:rotateClockwise()
   return Vector2(self.y, -self.x)
end

--- Adds two vectors together.
---@param a Vector2 The first vector.
---@param b Vector2 The second vector.
---@return Vector2 # The sum of the two vectors.
function Vector2.__add(a, b)
   return Vector2(a.x + b.x, a.y + b.y)
end

--- Subtracts vector b from vector a.
---@param a Vector2 The first vector.
---@param b Vector2 The second vector.
---@return Vector2 # The difference of the two vectors.
function Vector2.__sub(a, b)
   return Vector2(a.x - b.x, a.y - b.y)
end

--- Checks the equality of two vectors.
---@param a Vector2 The first vector.
---@param b Vector2 The second vector.
---@return boolean # True if the vectors are equal, false otherwise.
function Vector2.__eq(a, b)
   return a.x == b.x and a.y == b.y
end

--- Multiplies a vector by a scalar.
---@param a Vector2 The vector.
---@param b number The scalar.
---@return Vector2 # The product of the vector and the scalar.
function Vector2.__mul(a, b)
   return Vector2(a.x * b, a.y * b)
end

--- Negates the vector.
---@param a Vector2 The vector to negate.
---@return Vector2 # The negated vector.
function Vector2.__unm(a)
   return Vector2(-a.x, -a.y)
end

--- Creates a string representation of the vector.
---@return string # The string representation of the vector.
function Vector2:__tostring()
   return "x: " .. self.x .. " y: " .. self.y
end

---@return number hash
function Vector2:hash()
   return Vector2._hash(self.x, self.y)
end

---@param x integer
---@param y integer
function Vector2._hash(x, y)
   -- Shift to handle negatives (assuming 26-bit signed integers)
   x = x + 0x2000000 -- Shift range from [-2^25, 2^25-1] to [0, 2^26-1]
   y = y + 0x2000000 
   return y * 0x4000000 + x -- Combine into a single number
end

function Vector2.unhash(hash)
   local x, y = Vector2._unhash(hash)
   return Vector2(x, y)
end

---@param hash number
function Vector2._unhash(hash)
   local x = hash % 0x4000000
   local y = math.floor(hash / 0x4000000)
   -- Reverse the shift
   x = x - 0x2000000
   y = y - 0x2000000
   return x, y
end

--- Euclidian distance from another point.
--- @param vec Vector2
--- @return number distance
function Vector2:distance(vec)
   return math.sqrt(math.pow(self.x - vec.x, 2) + math.pow(self.y - vec.y, 2))
end

--- Manhattan distance from another point.
--- @param vec Vector2
--- @return number distance
function Vector2:distanceManhattan(vec)
   return math.abs(self.x - vec.x) + math.abs(self.y - vec.y)
end

--- Chebyshev distance from another point.
--- @param vec Vector2
--- @return number distance
function Vector2:distanceChebyshev(vec)
   return math.max(math.abs(self.x - vec.x), math.abs(self.y - vec.y))
end

--- Linearly interpolates between two vectors.
--- @param self Vector2 The starting vector (A).
--- @param vec Vector2 The ending vector (B).
--- @param t number The interpolation factor (0 <= t <= 1).
--- @return Vector2 # The interpolated vector.
function Vector2:lerp(vec, t)
   -- Ensure t is clamped between 0 and 1
   t = math.max(0, math.min(t, 1))

   local x = self.x + (vec.x - self.x) * t
   local y = self.y + (vec.y - self.y) * t

   return Vector2(x, y)
end

--- @type table<DistanceType, fun(Vector2, Vector2)>
local rangeCase = {
   ["8way"] = Vector2.distanceChebyshev,
   ["chebyshev"] = Vector2.distanceChebyshev,
   ["4way"] = Vector2.distanceManhattan,
   ["manhattan"] = Vector2.distanceManhattan,
   ["euclidean"] = Vector2.distance
}
--- Gets the range, a ciel'd integer representing the number of tiles away the other vector is
--- @param type DistanceType
--- @param vec Vector2
function Vector2:getRange(type, vec)
   return rangeCase[type](self, vec)
end

--- @return number x The x component of the vector.
--- @return number y The y component of the vector.
function Vector2:decompose()
   return self.x, self.y
end

--- The static UP vector.
---@type Vector2
Vector2.UP = Vector2(0, -1)

--- The static RIGHT vector.
---@type Vector2
Vector2.RIGHT = Vector2(1, 0)

--- The static DOWN vector.
---@type Vector2
Vector2.DOWN = Vector2(0, 1)

--- The static LEFT vector.
---@type Vector2
Vector2.LEFT = Vector2(-1, 0)

--- The static UP_RIGHT vector.
---@type Vector2
Vector2.UP_RIGHT = Vector2(1, -1)

--- The static UP_LEFT vector.
---@type Vector2
Vector2.UP_LEFT = Vector2(-1, -1)

--- The static DOWN_RIGHT vector.
---@type Vector2
Vector2.DOWN_RIGHT = Vector2(1, 1)

--- The static DOWN_LEFT vector.
---@type Vector2
Vector2.DOWN_LEFT = Vector2(-1, 1)

--- @alias Neighborhood table<Vector2>

--- @type Neighborhood
Vector2.neighborhood8 = {
   Vector2.UP,
   Vector2.DOWN,
   Vector2.LEFT,
   Vector2.RIGHT,
   Vector2.UP_LEFT,
   Vector2.UP_RIGHT,
   Vector2.DOWN_LEFT,
   Vector2.DOWN_RIGHT,
}

--- @type Neighborhood
Vector2.neighborhood4 = {
   Vector2.UP,
   Vector2.DOWN,
   Vector2.RIGHT,
   Vector2.LEFT
}

return Vector2
