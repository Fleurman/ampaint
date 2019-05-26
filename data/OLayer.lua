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
  o.history = {pos=0,data={}}
  o.opacity = 0.5
  
  o:record('init')
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
  --print('CREATE',table.tostring(t.data))
  o.data = am.ubyte_array(t.data)
  o.history = {pos=0,data={}}
  o:record('init')
  return o
end
function OLayer:copy()
  local obj = OLayer.new({},self.width,self.height)
  local copy = table.fromView(self.data)
  obj.data:set(copy)
  obj.history = {pos=0,data={}}
  obj.visible = self.visible
  obj.locked = self.locked
  obj.name = self.name + '.c'
  obj:record('init')
  return obj
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
  self:record('empty')
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
function OLayer:getXY(id) 
  return math.floor((id-1)/self.width),((id-1)%self.width)+1 
end
function OLayer:get(id)
  return string.char(self.data[id])
end
function OLayer:setPixel(id,v)
  if self.locked then return end
--  self:record()
  self.data[id] = string.byte(v)
end
function getCrossIds(self,id)
  local r,c = self:getXY(id)
  r=r+1
  local ids = {[1]=id}
  if r-1 > 0 then table.insert(ids,id-self.width) end
  if r+1 <= self.height then table.insert(ids,id+self.width) end
  if c-1 > 0 then table.insert(ids,id-1) end
  if c+1 <= self.width then table.insert(ids,id+1) end
  return ids
end
function OLayer:setCross(id,v)
  if self.locked then return end
  local ids = getCrossIds(self,id)
--  self:record('set cross')
  for i,t in ipairs(ids) do
    self.data[t] = string.byte(v)
  end
end

function getSquareIds(self,id)
  local r,c = self:getXY(id)
  r=r+1
  local ids = {id}
  for ro=-2,2 do
    for co=-2,2 do
      if r+ro > 0 and r+ro <= self.height and c+co > 0 and c+co <= self.width then
        table.insert(ids,id+(ro*self.width)+co)
      end
    end
  end
  return ids
end
function OLayer:setSquare(id,v)
  if self.locked then return end
  local ids = getSquareIds(self,id)
--  self:record('set square')
  for i,t in ipairs(ids) do 
    self.data[t] = string.byte(v)
  end
end

function OLayer:setPixelLine(from,target,col)
  if self.locked then return end
  local ids = getLineIds(self,from,target)
  self:record('set pixel line')
  for _,id in ipairs(ids) do
      if id > 0 and id <= (self.width*self.height) then
      self.data[id] = string.byte(col)
    end
  end
end
function OLayer:setCrossLine(from,target,col)
  if self.locked then return end
  local ids = getLineIds(self,from,target)
  self:record('set cross line')
  for _,id in ipairs(ids) do
      if id > 0 and id <= (self.width*self.height) then
      local ids = getCrossIds(self,id)
      for i,t in ipairs(ids) do
        self.data[t] = string.byte(col)
      end
    end
  end
end
function OLayer:setSquareLine(from,target,col)
  if self.locked then return end
  local ids = getLineIds(self,from,target)
  self:record('set square line')
  for _,id in ipairs(ids) do
      if id > 0 and id <= (self.width*self.height) then
      local ids = getSquareIds(self,id)
      for i,t in ipairs(ids) do 
        self.data[t] = string.byte(col)
      end
    end
  end
end
function getLineIds(self,a,b)
  local scale = win.scene'canvas'.scale
  local from = positionFromIndex(a)
  local target = positionFromIndex(b)
  from = vec2(from.x-(from.x%scale),from.y-(from.y%scale)) + scale/2
  target = vec2(target.x-(target.x%scale),target.y-(target.y%scale)) + scale/2
  local v = target - from
  local ratio = vec2(math.floor(v.x/scale),math.floor(v.y/scale))
  local max = math.max(math.abs(ratio.x,1),math.abs(ratio.y,1))
  max = math.ampl(max,1)
  local xm,ym = v.x/max,v.y/max
  local ids = {}
  for i=0,max do
    local vx,vy = from.x+(i*xm),from.y+(i*ym)
    local ix = math.floor((vx)/scale)
    local iy = math.floor((vy)/scale)
    local index = (1+ix+(self.width*0.5)) + (((self.height*0.5)-iy-1)*self.width)
    table.insert(ids,index)
  end
  return ids
end

function positionFromIndex(id)
  return win.scene'canvas'.positionFromIndex(id)
end

function crossTargets(self,id)
  local a = {}
  if id%self.width ~= 1 then table.insert(a,id-1) end
  if id%self.width ~= 0 then table.insert(a,id+1) end
  if id > self.width then table.insert(a,id-self.width) end
  if id < self.width*(self.height-1) then table.insert(a,id+self.width) end
  return a
end
function OLayer:fill(id,new)
  if self.locked then return end
--  self:record('fill')
  local old = self:get(id)
  self:setPixel(id,new)
  local search = {id}
  local new_s = {}
  local procc = true
  while procc do
    procc = false
    for k,i in ipairs(search) do
      local targets = crossTargets(self,i)
      for kk,s in pairs(targets) do
        local px = self:get(s)
        if px == old and not(px == new) then
          procc = true
          self:setPixel(s,new)
          table.insert(new_s,s)
        end
      end
    end
    search = new_s
  end
end

function OLayer:fillErase(id)
  if self.locked then return end
  self:record('fill erase')
  self:fill(id,'.')
end

function OLayer:fillByColor(old,new)
  if self.locked then return end
  old = string.byte(old)
  self:record('fill by color')
  for i=1,#self.data do
    if self.data[i]==old then self.data[i]=string.byte(new) end
  end
end

function OLayer:drawLineSquare(id1,id2,c,p)
  if self.locked then return end
  local row1,col1 = self:getXY(id1)
  local row2,col2 = self:getXY(id2)
  local row,col = row2-row1,col2-col1
  p = p == true
  if(p) then
    if(row>col) then row=col end
    if(col>row) then col=row end
  end
  self:record('draw line square')
  for i=1,math.abs(col) do
    local v = i*math.value(col)
    self.data[id1+v] = string.byte(c)
    self.data[id1+(row*self.width)+v] = string.byte(c)
  end
  for i=1,math.abs(row) do
    local v = i*math.value(row)
    self.data[id1+(v*self.width)] = string.byte(c)
    self.data[id1+(v*self.width)+col] = string.byte(c)
  end
  self.data[id1] = string.byte(c)
  
end

function OLayer:drawFullSquare(id1,id2,color,p)
  if self.locked then return end
  local row1,col1 = self:getXY(id1)
  local row2,col2 = self:getXY(id2)
  local row,col = row2-row1,col2-col1
  p = p == true
  if(p) then
    if(row>col) then row=col end
    if(col>row) then col=row end
  end
  self:record('draw full square')
  for c=0,math.abs(col) do
    local cv = c*math.value(col)
    for r=0,math.abs(row) do
      local rv = r*math.value(row)
      self.data[id1+(rv*self.width)+cv] = string.byte(color)
      end
  end
  self.data[id1] = string.byte(color)
end


function OLayer:drawFullCircle(id1,id2,c)
  if self.locked then return end
  local row1,col1 = self:getXY(id1)
  local row2,col2 = self:getXY(id2)
  local h,w = row2-row1,col2-col1
  p = p == true
  if(p) then
    if(h>w) then h=w end
    if(w>h) then w=h end
  end
  if(h<0)then
    h = math.abs(h)
    id1=id1-(h*self.width)
  end
  if(w<0)then
    w = math.abs(w)
    id1=id1-w
  end
  local points = getEllipsePoints(w+1,h+1)
  self:record('draw full circle')
  for x,ys in pairs(points) do
    local min,max = h+1,0
    for y,_ in pairs(ys) do
      y = tonumber(y)
      if(y < min) then min = y end
      if(y > max) then max = y end
    end
    for i=min+1,max-1 do
      ys[tostring(i)] = i
    end
    for y,_ in pairs(ys) do
      local gx = x-1
      local gy = (y*self.width)
      local id = id1+gx+gy
      self.data[id] = string.byte(c)
    end
  end
end

function OLayer:drawLineCircle(id1,id2,c,p)
  if self.locked then return end
  local row1,col1 = self:getXY(id1)
  local row2,col2 = self:getXY(id2)
  local h,w = row2-row1,col2-col1
  p = p == true
  if(p) then
    if(h>w) then h=w end
    if(w>h) then w=h end
  end
  if(h<0)then
    h = math.abs(h)
    id1=id1-(h*self.width)
  end
  if(w<0)then
    w = math.abs(w)
    id1=id1-w
  end
  local points = getEllipsePoints(w+1,h+1)
  self:record('draw line circle')
  for x,ys in pairs(points) do
    for y,_ in pairs(ys) do
      local gx = x-1
      local gy = (y*self.width)
      local id = id1+gx+gy
      self.data[id] = string.byte(c)
    end
  end
end


function getEllipsePoints(w,h)
  local points = {}
  local a = w/2
  local b = h/2
  local tresh = (w+h)*4
  for i=0,tresh do
    local f = i/tresh
    local t = f*(2*math.pi)
    local x = math.clamp(a*math.cos(t),-w/2,(w/2)-0.1)
    local y = math.clamp(b*math.sin(t),-h/2,(h/2)-0.1)
    if(x<0) then
      local v = math.clamp(x+0.3,-w/2,(w/2)-0.1)
      x = math.ceil(v + (w/2))
    else
      local v = math.clamp(x-0.3,-w/2,(w/2)-0.1)
      x = math.ceil(v + (w/2))
    end
    if(y<0) then
      local v = math.clamp(y+0.3,-h/2,(h/2)-0.1)
      y = math.floor(v + (h/2))
    else
      local v = math.clamp(y-0.3,-h/2,(h/2)-0.1)
      y = math.floor(v + (h/2))
    end
    if(not points[x]) then
      points[x] = {}
    end
    if(not points[x][y]) then
      points[x][tostring(y)] = y
    end
  end
  return points
end


function OLayer:record(src)
  if(self.history.pos > 0) then
    for i=0,self.history.pos-1 do table.remove(self.history.data) end
    self.history.pos = 0
  end
  if(#self.history.data >= 10) then
    table.remove(self.history.data,1)
  end
  table.insert(self.history.data,table.fromView(self.data))
  print('recorded',src,'pos: '..self.history.pos,'items: '..#self.history.data)
end
function OLayer:undo()
--  print('undo',self.history.pos, #self.history.data)
  if(self.history.pos < #self.history.data-1) then
    self.history.pos = self.history.pos + 1
    local state = self.history.data[#self.history.data-self.history.pos]
    self.data:set(state)
  end
end
function OLayer:redo()
--  print('redo',self.history.pos, #self.history.data)
  if(self.history.pos>0) then
    self.history.pos = self.history.pos - 1
    local state = self.history.data[#self.history.data-self.history.pos]
    self.data:set(state)
  end
end

 function OLayer:move(x,y)
    local data = table.group(table.fromView(self.data),self.width)
    if y > 0 then
      local l = table.remove(data,#data)
      table.insert(data,1,l)
    elseif y < 0 then
      local l = table.remove(data,1)
      table.insert(data,l)
    end
    if x > 0 then
      for i,r in ipairs(data) do
        local l = table.remove(r,#r)
        table.insert(r,1,l)
      end
    elseif x < 0 then
      for i,r in ipairs(data) do
        local l = table.remove(r,1)
        table.insert(r,l)
      end
    end
    self.data:set(table.iflatten(data))
  end


