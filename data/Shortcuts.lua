local Cuts = ...

Cuts.data = {
  centerview={'s'},
  swapcolor={'a'},
  move={'m'},
  pencil={'p'},
  eraser={'e'},
  bucket={'b'},
  viewer={'v'},
  tiles={'t'},
  save={'ctrl','s'},
  export={'ctrl','e'},
  colorpicker={'lctrl'},
  undo={'ctrl','left'},
  redo={'ctrl','right'},
  saveas={'ctrl','alt','s'},
  exportas={'ctr','alt','e'},
  delete={'delete'},
  upperlayer={'pageup'},
  bottomlayer={'pagedown'},
}

function Cuts:active(key)
  if not self.data[key] then return nil end
  local bool = true
  for k,v in ipairs(self.data[key]) do
    if #win:keys_down() > #self.data[key] then bool=nil return end
    v = Keymap:get(v)
    if v=='ctrl' or v=='alt' or v=='shift' then
      if win:key_down('l' ..v) or win:key_down('r' ..v) then else bool=nil end
    else
      if win:key_pressed(v) then else bool=nil end
    end
  end
  return bool
end

function Cuts:down(k)
  if not self.data[k] then return nil end
  local bool = true
  for k,v in ipairs(self.data[k]) do
    v = Keymap:get(v)
    if v=='ctrl' or v=='alt' or v=='shift' then
      if win:key_down('l' ..v) or win:key_down('r' ..v) then else bool=nil end
    else
      if win:key_down(v) then else bool=nil end
    end
  end
  return bool
end

