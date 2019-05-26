local Keymap = ...

Keymap.data = {}

function Keymap:get(key)
  if not self.data[key] then return key end
  return self.data[key]
end