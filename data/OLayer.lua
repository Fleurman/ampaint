OLayer = ...
OLayer.__index = OLayer

function blankData(w,h)
    local row = {}
    for i=1,w do table.insert(row,'.') end
    local tab = {}
    for i=1,h do table.insert(tab,table.shallow_copy(row)) end
    return tab
end

function OLayer:new(w,h)
  local o = {}
  setmetatable(o,OLayer)
  o.width = w
  o.height = h
  o.visible = true
  o.locked = false
  o.level = 1
  o.name = 'layer ' .. Layers.count
  o.data = blankData(w,h)
  return o
end
function OLayer:create(w,h,t)
  local o = {}
  setmetatable(o,OLayer)
  o.width = w
  o.height = h
  o.level = t.level
  o.visible = t.visible
  o.locked = t.locked
  o.name = t.name
  o.data = t.data
  return o
end
function OLayer:toTable()
  return {
      --width = self.width
      --height = self.height
      visible= self.visible,
      locked= self.locked,
      data= self.data,
      name = self.name,
      level = self.level,
      selected = Layers.selected == self.level
  }
end

function OLayer:empty()
  self.data = blankData(self.width,self.height)
end

function OLayer:sprite()
  if not self.visible then return [[..\n..]] end
  --if self.memo then return self.memo end
  local nsp = ''
  for i,r in ipairs(self.data) do
    local tl = ''
    for n,l in ipairs(r) do tl = tl .. l end
    nsp = nsp .. tl
  if i < self.height then nsp = nsp .. '\n' end
  end
  self.memo = spr
  return nsp
end

function OLayer:crossTargets(id)
  local a = {}
  if id%self.width ~= 1 then table.insert(a,id-1) end
  if id%self.width ~= 0 then table.insert(a,id+1) end
  if id > self.width then table.insert(a,id-self.width) end
  if id < self.width*(self.height-1) then table.insert(a,id+self.width) end
  return a
end
function OLayer:getXY(id) return math.floor((id-1)/self.width),((id-1)%self.width)+1 end
function OLayer:get(id)
  local r,c = self:getXY(id)
  return self.data[r+1][c]
end
function OLayer:setPixel(id,v)
  --print(self,self.data)
  if self.locked then return end
  local r,c = self:getXY(id)
  self.data[r+1][c] = v
  self.memo = nil
end
function OLayer:setCross(id,v)
  if self.locked then return end
  local r,c = self:getXY(id)
  r=r+1
  local points = {{r,c}}
  if r-1 > 0 then table.insert(points,{r-1,c}) end
  if r+1 <= self.height then table.insert(points,{r+1,c}) end
  if c-1 > 0 then table.insert(points,{r,c-1}) end
  if c+1 <= self.width then table.insert(points,{r,c+1}) end
  for i,t in ipairs(points) do 
    self.data[t[1]][t[2]] = v
  end
  self.memo = nil
end
function OLayer:setSquare(id,v)
  if self.locked then return end
  local r,c = self:getXY(id)
  local points = {{r,c}}
  for ro=-2,2 do
    for co=-2,2 do
      if r+ro > 0 and r+ro <= self.height and c+co > 0 and c+co <= self.width then
        table.insert(points,{r+ro,c+co})
      end
    end
  end
  for i,t in ipairs(points) do self.data[t[1]][t[2]] = v end
  self.memo = nil
end

function OLayer:fill(id,new)
  if self.locked then return end
  local old = self:get(id)
  self:setPixel(id,new)
  local search = {id}
  local new_s = {}
  local procc = true
  while procc do
    procc = false
    for k,i in ipairs(search) do
      local targets = self:crossTargets(i)
      for kk,s in pairs(targets) do
        local px = self:get(s)
        --print('start:'+id,'pointer:'+s,'test:'+px,'old:'+old,'color:'+new)
        if px == old and not(px == new) then
          procc = true
          self:setPixel(s,new)
          table.insert(new_s,s)
          --print('draw '+s)
        end
      end
    end
    search = new_s
  end
end

function OLayer:fillErase(id)
  if self.locked then return end
  self.fill(id,'.')
end

function OLayer:fillByColor(old,new)
  if self.locked then return end
  for r,l in ipairs(self.data) do
    for c,p in ipairs(l) do 
      if self.data[r][c]==old then self.data[r][c]=new end 
    end
  end
end