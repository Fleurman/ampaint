OLayer = ...
OLayer.__index = OLayer

function OLayer:new(w,h)
  local o = {}
  setmetatable(o,OLayer)
  o.width = w
  o.height = h
  o.visible = true
  o.locked = false
  o.level = 1
  o.name = 'layer ' .. Layers.count
  o.data = am.buffer(w*h):view('ubyte')
  o.opacity = 0.5
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
  --print(table.tostring(t.data))
  o.data = am.ubyte_array(t.data)
  return o
end
function OLayer:toTable()
  return {
      --width = self.width
      --height = self.height
      visible= self.visible,
      locked= self.locked,
      data= table.fromView(self.data),
      name = self.name,
      level = self.level,
      selected = Layers.selected == self.level
  }
end

function OLayer:empty()
  self.data:set(string.byte('.'))
end

function OLayer:sprite()
  if not self.visible then return [[..\n..]] end
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
  return string.char(self.data[id])
end
function OLayer:setPixel(id,v)
  if self.locked then return end
  self.data[id] = string.byte(v)
end
function OLayer:setCross(id,v)
  if self.locked then return end
  local r,c = self:getXY(id)
  r=r+1
  local ids = {[1]=id}
  if r-1 > 0 then table.insert(ids,id-self.width) end
  if r+1 <= self.height then table.insert(ids,id+self.width) end
  if c-1 > 0 then table.insert(ids,id-1) end
  if c+1 <= self.width then table.insert(ids,id+1) end
  for i,t in ipairs(ids) do
    self.data[t] = string.byte(v)
  end
end
function OLayer:setSquare(id,v)
  if self.locked then return end
  local r,c = self:getXY(id)
  r=r+1
  local points = {id}
  for ro=-2,2 do
    for co=-2,2 do
      if r+ro > 0 and r+ro <= self.height and c+co > 0 and c+co <= self.width then
        table.insert(points,id+(ro*self.width)+co)
      end
    end
  end
  for i,t in ipairs(points) do 
    self.data[t] = string.byte(v)
  end
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
  old = string.byte(old)
  if self.locked then return end
  for i=1,#self.data do
    if self.data[i]==old then self.data[i]=string.byte(new) end
  end
end

function OLayer:drawLineSquare(id1,id2,c)
  local row1,col1 = self:getXY(id1)
  local row2,col2 = self:getXY(id2)
  local row,col = row2-row1,col2-col1
  --print('DATA:',id1,id2,row1,col1,row2,col2,row,col)
  for i=1,math.abs(col) do
    local v = i*math.value(col)
    --print('ITER ROW:',v)
    self.data[id1+v] = string.byte(c)
    self.data[id1+(row*self.width)+v] = string.byte(c)
  end
  for i=1,math.abs(row) do
    local v = i*math.value(row)
    --print('ITER COL:',v)
    self.data[id1+(v*self.width)] = string.byte(c)
    self.data[id1+(v*self.width)+col] = string.byte(c)
  end
  self.data[id1] = string.byte(c)
  
end

function OLayer:drawFullSquare(id1,id2,color)
  local row1,col1 = self:getXY(id1)
  local row2,col2 = self:getXY(id2)
  local row,col = row2-row1,col2-col1
  --print('DATA:',id1,id2,row1,col1,row2,col2,row,col)
  for c=0,math.abs(col) do
    local cv = c*math.value(col)
    for r=0,math.abs(row) do
      local rv = r*math.value(row)
      
      self.data[id1+(rv*self.width)+cv] = string.byte(color)
      
    end
  end
  self.data[id1] = string.byte(color)
  
end


