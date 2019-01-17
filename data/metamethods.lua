--[[------------------------------------------------------------------------------
                                  **METAMETHODS**
----------------------------------------------------------------------------------]]
local meta = getmetatable("") meta.__add = function(a,b) return a..b end
meta.__mul = function(a,b) return string.rep(a,b) end
meta.__index = function(a,b) if type(b) ~= "number" then return string[b] end return a:sub(b,b) end
string.translate = function(s,b)
    local new = s
    if b > 0 then
      for i=1,b do
        new = new[#new] + new:sub(0,#new-1)
      end
    else
      for i=1,(b*-1) do
        new = new:sub(1,#new) + new[0]
      end
    end
    return new
end
string.padLeft = function(s,l,c)
    c = c or ' '
    local pad = ''
    if l > #s then
      for i=1,l-#s do
        pad = c .. pad
      end
    end
    return pad .. s
end
string.trimLeft = function(s)
  return string.gsub(s,"^%s*",'')
end
string.trimRight = function(s)
  return string.gsub(s,"%s*$",'')
end
string.trim = function(s)
  return string.trimLeft(string.trimRight(s))
end


string.toNumber = function(s)
  local new = ''
  for i=1,#s do
    new = new .. s:byte(i)
  end
  return new
end


io.exists = function(file)
  return io.open(file) and true or false
end

table.map = function( tab, fn )
    for i,v in ipairs(tab) do
        tab[i] = fn(v)
    end
    return tab
end
table.group = function( t, g )
    local new = {}
    local item = {}
    counter = 0
    for index, value in ipairs(t) do
        table.insert(item,value)
        if(index%g==0) then
            table.insert(new, table.shallow_copy( item ))
            item = {}
            counter = counter + 1
        end
    end
    return new
end
table.delete = function( tab, value )
    for i,v in ipairs(tab) do
        tab[i] = fn(v)
    end
    return tab
end
table.fromView = function(view)
  local tab = {}
  for i=1,#view do
      table.insert(tab,view[i])
  end
  return tab
end
table.flatten = function(data)
  local tab = {}
  local iter = {}
  iter = function(var)
    for i,v in pairs(var) do
      if type(v) == 'table' then
        iter(v)
      else
        tab[i] = v
      end
    end
  end
  iter(data)
  return tab
end
table.iflatten = function(data)
  local tab = {}
  local iter = {}
  iter = function(var)
    for i,v in ipairs(var) do
      if type(v) == 'table' then
        iter(v)
      else
        table.insert(tab,v)
      end
    end
  end
  iter(data)
  return tab
end

local test = {
    [1] = {1,2,3},
    [2] = {4,5,6},
    [3] = {7,8,9},
}
function table.horizontalFlip(s)
  --print(table.tostring(s))
  local mid = math.floor(#s/2)
  for i=1,mid do
    
    s[i],s[#s+1-i] = s[#s+1-i],s[i]
  end
  return s
end
--local view = am.ubyte_array({1,2,3,4,5,6,7,8,9})
--local test2 = table.group(table.fromView(view),3)
--local flat = table.iflatten(table.horizontalFlip(test2))
--print(table.tostring(flat))

--print(table.tostring(table.flatten({
--  a={aa=1,bb=2},
--  b={ab=3},
--  [1] = {[2]=3},
--  c='ok',
--  d={
--    e=10,f=11,
--    z={
--      yolo='cool'
--    }
--  }
--})))
