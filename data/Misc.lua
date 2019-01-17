--[[------------------------------------------------------------------------------
                                  **MISC METHODS**
----------------------------------------------------------------------------------]]
function wrap(s,e)e=e or 72 local h=2 return s:gsub("(.)()",function(l,n)if n-h==e then h=n return"\n"..l end end)end
function bounds(window)local w,h = window.pixel_width,window.pixel_height return vec4(-w*0.5,-h*0.5,w*0.5,h*0.5)end
function t_to_s(t) local s = [[]] for i,v in pairs(t) do s =s .. tostring(v) end return s end
function s_to_t(s) local t = {} for w in string.gmatch(s,"[a-zA-Z.0-9-_'()%[%]%%:;]+") do table.insert(t,w) end return t end
function list_to_t(s) local t = {} for w in string.gmatch(s,"[^\n]+") do table.insert(t,w) end return t end
function math.abs(v) 
  if v < 0 then
    v = v*-1
  end
  return v
end
function math.value(v) if v<0 then return -1 elseif v>0 then return 1 end return 0 end
function math.between(min,v,max) if v>min and v<max then return true else return false end end
function math.ult(m,n) return m<n end
function math.ampl(v,d) return v<0 and v-d or v+d end
function math.trint(n)local i,f=math.modf(n) return f<0.5 and math.floor(n) or math.ceil(n) end
function math.round(n, deci)
  deci = 10^(deci or 2)
  return math.floor(n*deci+.5)/deci
end
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end
function math.rsign() return love.math.random(2) == 2 and 1 or -1 end
function math.within(r,p)if p.x>r.r and p.x<r.b and p.y>r.g and p.y<r.a then return true else return false end end
function printTable(t)p=''for k,v in ipairs(t)do p=''..p..k..": "..v ..' 'if k%10==0 then p=p.."\n"end end print(p)end

function isOld(check,ver)
  if not check then return true end
  return check < ver
end

--[[------------------------------------------------------------------------------
                                  **AM SQUARE**
----------------------------------------------------------------------------------]]
function am.square(x,y,width,height,thickness,color,anim)
  local point1, point2 = nil,nil
  if not anim then anim = true end
  local function points()
    return {vec2(x,y), vec2(x,y+height), vec2(x+width,y+height), vec2(x+width,y)} 
  end
  local inner = am.translate(0,0) ^ am.group()
                ^ {am.line(points()[1],points()[2],thickness,color), am.line(points()[2],points()[3],thickness,color),
                   am.line(points()[3],points()[4],thickness,color), am.line(points()[4],points()[1],thickness,color)}
  local wrapped = am.wrap(inner):tag"square"
  function wrapped:refresh()
    for i,c in inner"group":child_pairs() do
      c.point1 = points()[i] 
      local id = i+1
      if(id==5)then id = 1 end
      c.point2 = points()[id]
    end
  end
  function wrapped:get_x() return x end
  function wrapped:set_x(v) 
    inner"translate".x = v 
    x=v 
  end
  function wrapped:get_y() return y end
  function wrapped:set_y(v) 
    inner"translate".y = v 
    y=v 
  end
  function wrapped:get_point1() return vec2(x,y) end
  function wrapped:set_point1(v) 
    --inner"translate".x = v.x 
    x=v.x
    --inner"translate".y = v.y 
    y=v.y
    wrapped:refresh() 
  end
  function wrapped:get_point2() return vec2(width,height) end
  function wrapped:set_point2(v) 
    width = v.x 
    height = v.y 
    wrapped:refresh() 
  end
  function wrapped:get_scale() return height end
  function wrapped:set_scale(v) 
    height,width = v,v
    wrapped:refresh()
  end
  function wrapped:get_thickness() return thickness end
  function wrapped:set_thickness(v) thickness=v for i,c in inner"group":child_pairs()do c.thickness=v end end
  function wrapped:set_color(v) for i,child in inner"group":child_pairs()do child.color=v end end
  if anim then
    wrapped:action(coroutine.create(function(node) while true do
        am.wait(am.delay(0.4)) node.color = vec4(0.9,0.9,0.9,1)
        am.wait(am.delay(0.4)) node.color = vec4(1,1,1,1)
    end end))
  end
  return wrapped
end



--local new = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv'
--local old = 'gQAhRBiSCjTDkUElVFmWGnXHoYIpZJqaKrbLscMtdNueOvfP'

--local rs = {}
--for i=1,#old do
--  rs[old[i]] = new[i]
--end

--print(table.tostring(rs))

--local api,err = am.parse_json(am.load_string('api.json'))
--print(api,err)
--local sapi = table.tostring(api)
--local f = io.open('api.txt','w+')
--f:write(sapi)
--f:close()





