--[[------------------------------------------------------------------------------
                                  **MISC METHODS**
----------------------------------------------------------------------------------]]
function wrap(s,e)e=e or 72 local h=2 return s:gsub("(.)()",function(l,n)if n-h==e then h=n return"\n"..l end end)end
function bounds(window)local w,h = window.pixel_width,window.pixel_height return vec4(-w*0.5,-h*0.5,w*0.5,h*0.5)end
function t_to_s(t) local s = [[]] for i,v in pairs(t) do s =s .. tostring(v) end return s end
function s_to_t(s) local t = {} for w in string.gmatch(s,"[a-zA-Z.0-9-_'()%[%]%%:;]+") do table.insert(t,w) end return t end
function list_to_t(s) local t = {} for w in string.gmatch(s,"[^\n]+") do table.insert(t,w) end return t end
function math.abs(v)
  if(type(v)=='number') then
    if v < 0 then
      v = v*-1
    end
  else
    v = vec2(math.abs(v.x),math.abs(v.y))
  end
  return v
end
function math.vav(vec,v)
  local x = (vec.x > 0) and (vec.x + v.x) or (vec.x - v.x)
  local y = (vec.y > 0) and (vec.y + v.y) or (vec.y - v.y)
  return vec2(x,y)
end
function math.vsv(vec,v)
  return math.vav(vec,v*-1)
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
function am.cursor(x,y,width,height,thickness,color)
  local point1, point2 = nil,nil
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
  return wrapped
end

function am.square(center,radius,color,thickness)
  
  local style = 'fill'
  if not thickness then thickness = 1 end
  if not color then color = vec4(1,1,1,1) end

  local inner = am.translate(center):tag('translate')
                ^ am.stencil_test{
                    enabled = true,
                    func_front = "equal",
                    op_zpass_front = "invert",
                }
                ^ am.group{
                    am.rect(0,0,0,0, vec4(0,0,0,0)):tag('inner'),
                    am.rect(-radius.x,-radius.y,radius.x,radius.y, color):tag('outer'),
                }
  local wrapped = am.wrap(inner):tag"disc"
  
  function wrapped:get_center() 
    return point1
  end
  function wrapped:set_center(v)
    center = v
    inner"translate".position2d = v
  end

  function wrapped:get_radius() 
    return radius
  end
  function wrapped:set_radius(v)
    radius = v
    inner"outer".x1 = -v.x
    inner"outer".y1 = -v.y
    inner"outer".x2 = v.x
    inner"outer".y2 = v.y
    if(v.x ~= thickness/2 and v.y ~= thickness/2) then
      inner"inner".x1 = -v.x+thickness
      inner"inner".y1 = -v.y+thickness
      inner"inner".x2 = v.x-thickness
      inner"inner".y2 = v.y-thickness
    end
  end
  
  function wrapped:get_thickness() 
    return thickness 
  end
  function wrapped:set_thickness(v)
    thickness = v
  end
  
  function wrapped:get_style() 
    return style 
  end
  function wrapped:set_style(v)
    style = v
    if style == 'line' then
      inner"outer".hidden = false
      inner"inner".hidden = false
    elseif style == 'fill' then
      inner"outer".hidden = false
      inner"inner".hidden = true
      inner"inner".x1 = 0
      inner"inner".y1 = 0
      inner"inner".x2 = 0
      inner"inner".y2 = 0
    elseif style == 'none' then
      radius = vec2(0)
      inner"outer".hidden = true
      inner"outer".x1 = 0
      inner"outer".y1 = 0
      inner"outer".x2 = 0
      inner"outer".y2 = 0
      inner"inner".hidden = true
      inner"inner".x1 = 0
      inner"inner".y1 = 0
      inner"inner".x2 = 0
      inner"inner".y2 = 0
    end
  end
  
  function wrapped:get_color() 
    return color
  end
  function wrapped:set_color(v) 
    color = v
    inner'outer'.color = v
  end
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                  **AM DISC**
----------------------------------------------------------------------------------]]
function am.disc(center,radius,color,thickness)
  local style = 'fill'
  if not thickness then thickness = 1 end
  if thickness == 0 then thickness = radius end
  if not color then color = vec4(1,1,1,1) end
  
  local innerRadius = math.abs(radius)-thickness/2
  
  local inner = am.translate(center):tag('translate')
                ^ am.stencil_test{
                    enabled = true,
                    func_front = "equal",
                    op_zpass_front = "invert",
                }
                --^ am.translate(center)
                ^ am.group{
                    am.circle(vec2(0, 0), innerRadius, vec4(0,0,0,0)):tag('inner'),
                    am.circle(vec2(0, 0), radius, color):tag('outer'),
                }
  local wrapped = am.wrap(inner):tag"disc"
  
  function wrapped:get_center() 
    return center
  end
  function wrapped:set_center(v)
    center = v
    inner"translate".position2d = v 
  end
  
  function wrapped:get_radius() 
    return radius
  end
  function wrapped:set_radius(v)
    radius = v
    inner"outer".radius = v
    if(v.x ~= thickness/2 and v.y ~= thickness/2) then
      inner"inner".radius = math.abs(v)-thickness
    end
  end
  
  function wrapped:get_thickness() 
    return thickness 
  end
  function wrapped:set_thickness(v)
    thickness = v
  end

  function wrapped:get_style() 
    return style 
  end
  function wrapped:set_style(v)
    style = v
    if style == 'line' then
      inner"outer".hidden = false
      inner"inner".hidden = false
    elseif style == 'fill' then
      inner"outer".hidden = false
      inner"inner".hidden = true
      inner"inner".radius = 0
    elseif style == 'none' then
      radius = vec2(0)
      inner"outer".hidden = true
      inner"outer".radius = 0
      inner"inner".hidden = true
      inner"inner".radius = 0
    end
  end
  
  function wrapped:get_color() 
    return color
  end
  function wrapped:set_color(v) 
    color = v
    inner'outer'.color = v
  end
  
  return wrapped
end


