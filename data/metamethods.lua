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
