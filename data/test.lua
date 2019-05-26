math.clamp = function(v,min,max)
  return math.max(min,math.min(max,v))
end
math.truncate = function(v,d)
  if(d)then v = v*(10^d) end
  local t = tostring(v):gsub('%..+','')
  v = tonumber(t)
  if(d)then v = v/(10^d) end
  return v
end
math.round = function(v,d)
    v = v*(10^d)
    local r = tostring( math.truncate(v*10) )
    r = tonumber(r:sub(#r,#r))
    if r < 5 then
      v = math.floor(v) / (10^d)
    else
      v = math.ceil(v) / (10^d)
    end
    return v
end


math.ellipsePerimeter = function(a,b)
  
  return math.pi * math.sqrt( 2*(a^2+b^2) - (a-b)^2 )
  
end

print(math.ellipsePerimeter(3,3))


function getEllipsePoints(w,h)
  
  self.width,self.height = w,h
  
  local points = {}
  
  local a = w/2
  local b = h/2

  local small = a < b and a or b
  local big = a > b and a or b

--  local tresh = math.ellipsePerimeter(small+1,big+1)
  local tresh = (w+h)*4

  for i=0,tresh do
    
    local f = i/tresh
    local t = f*(2*math.pi)
    
    local x = math.clamp(a*math.cos(t),-w/2,(w/2)-0.1)
    local y = math.clamp(b*math.sin(t),-h/2,(h/2)-0.1)
  
    print(i,'x: '..x,'\ty: '..y)
    
    local _,dx = math.modf(x)
    local __,dy = math.modf(y)
    
    print(math.truncate(math.abs(dx),1))
    
    if((math.round(math.abs(x),10)==math.round(math.abs(y),10)) or
      (math.truncate(math.abs(dy),1) == 0.3) or (math.truncate(math.abs(dy),2) == 0.1))then
      
    else
    
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
    
    print('','   '..x,'\t\t\t   '..y+1,'\n')
    
    if(not points[x]) then
      points[x] = {}
    end
    
    if(not points[x][y]) then
      points[x][tostring(y)] = y
    end
    
    end
      
  end
  
  return points
  
end




function ellipse()
  
  local w,h = 24,24
  
  self = {}
  self.width,self.height = w,h
  
  local grid = {}
  for i=1,(w*h) do table.insert(grid,'.') end
  
  local view = ''
  
  local points = getEllipsePoints(w,h)
  
  local count = 0
  
  for x,ys in pairs(points) do
    for y,_ in pairs(ys) do
    
      local gx = x
      local gy = (y*self.width)
      local id = gx+gy
      
      grid[id] = 'o'--count
      
      count = count + 1
      
    end
  
  end
  
  for i,c in ipairs(grid) do
    view = view .. c
    if(i%w==0) then view = view .. '\n' end
  end
  
  print(view)
  
end

ellipse()



