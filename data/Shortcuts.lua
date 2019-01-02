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
  colorpicker={'ctrl'},
  undo={'ctrl','left'},
  redo={'ctrl','right'},
  saveas={'ctrl','alt','s'},
  exportas={'ctr','alt','e'},
  deleteall={'ctrl','shift','d'},
}

function Cuts:active(key)
  local bool = true
  for k,v in ipairs(self.data[key]) do
    if #win:keys_down() > #self.data[key] then bool=nil return end
    if v=='ctrl' or v=='alt' or v=='shift' then
      if win:key_down('l' ..v) or win:key_down('r' ..v) then else bool=nil end
    else
      if win:key_pressed(v) then else bool=nil end
    end
  end
  return bool
end

function Cuts:down(k)
  local bool = true
  for k,v in ipairs(self.data[k]) do
    if v=='ctrl' or v=='alt' or v=='shift' then
      if win:key_down('l' ..v) or win:key_down('r' ..v) then else bool=nil end
    else
      if win:key_down(v) then else bool=nil end
    end
  end
  return bool
end