if not prism then error("Spectrum depends on prism!") end

spectrum = {}
spectrum.path = ...

function spectrum.require(p) return require(table.concat({ spectrum.path, p }, ".")) end

--- @module "spectrum.camera"
spectrum.Camera = spectrum.require "camera"

--- @module "spectrum.sensestracker"
spectrum.SensesTracker = spectrum.require "sensestracker"

--- @module "spectrum.spriteatlas"
spectrum.SpriteAtlas = spectrum.require "spriteatlas"

--- @module "spectrum.display"
spectrum.Display = spectrum.require "display"

--- @module "spectrum.keybindings"
spectrum.Keybinding = spectrum.require "keybindings"

--- @module "spectrum.gamestates.statemanager"
spectrum.StateManager = spectrum.require "gamestates.statemanager"

--- @module "spectrum.gamestates.gamestate"
spectrum.GameState = spectrum.require "gamestates.gamestate"

--- @module "spectrum.gamestates.levelstate"
spectrum.LevelState = spectrum.require "gamestates.levelstate"

--- @module "spectrum.components.drawable"
prism.components.Drawable = nil
