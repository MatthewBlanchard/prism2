return spectrum.Keybinding {
   { key = "z", mode = "ctrl", action = "undo", description = "Undo the most recent change." },
   { key = "y", mode = "ctrl", action = "redo", description = "Undo the most recent change." },
   { key = "c", mode = "ctrl", action = "copy", description = "Copy the current selection." },
   { key = "v", mode = "ctrl", action = "paste", description = "Paste the current selection." },

   { key = "f", action = "fill", description = "Toggle fill mode." },
   { key = "m", action = "mode", description = "Swaps between tile, actor, and actor + tile modes." },
   { key = "n", action = "pen", description = "Swap to the pen tool." },
   { key = "e", action = "delete", description = "Swap to the delete tool." },
   { key = "r", action = "rect", description = "Swap to the rect tool." },
   { key = "o", action = "ellipse", description = "Swap to the ellipse tool." },
   { key = "l", action = "line", description = "Swap to the line tool." },
   { key = "b", action = "bucket", description = "Swap to the bucket fill tool." },
   { key = "s", action = "select", description = "Swap to the select tool." },
}
