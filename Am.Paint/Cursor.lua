local Cursor = ...

function Cursor:node(x,y,ow,oh,thickness,color)
  local w = ow
  local h = oh
  local size = 'norm'
  local function points()
    if size == 'norm' then
      return {vec2(x,y), vec2(x,y+h), vec2(x+w,y+h), vec2(x+w,y)}
    elseif size == 'size2' then
      return {vec2(x,y), vec2(x-w,y), vec2(x-w,y+h), vec2(x,y+h),
              vec2(x,y+h*2),vec2(x+w,y+h*2),vec2(x+w,y+h),
              vec2(x+w*2,y+h),vec2(x+w*2,y),vec2(x+w,y),
              vec2(x+w,y-h),vec2(x,y-h)}
    elseif size == 'size3' then
      return {vec2(x-w*2,y-h*2), vec2(x-w*2,y+h*3), vec2(x+w*3,y+h*3), vec2(x+w*3,y-h*2)}
    end
  end
  
  local size2 = am.group():tag('size2')
  size = 'size2'
  for i=1,12 do
    local p2 = i==12 and 1 or i+1
    size2:append(am.line(points()[i],points()[p2],thickness,color))
  end

  size = 'size3'
  local size3 = am.group():tag('size3')
                ^ {am.line(points()[1],points()[2],thickness,color),
                   am.line(points()[2],points()[3],thickness,color),
                   am.line(points()[3],points()[4],thickness,color),
                   am.line(points()[4],points()[1],thickness,color)}
                  
  size = 'norm' 
  local inner = am.translate(0,0)
                ^ am.scale(1)
                ^ am.group() ^ {
                  am.group():tag('norm')
                  ^ {am.line(points()[1],points()[2],thickness,color),
                     am.line(points()[2],points()[3],thickness,color),
                     am.line(points()[3],points()[4],thickness,color),
                     am.line(points()[4],points()[1],thickness,color)}
                  }
  inner'group':append(size2)
  inner'group':append(size3)
  
  local wrapped = am.wrap(inner):tag('cursor')
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    inner"translate".x = v
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    inner"translate".y = v
  end
  function wrapped:set_size(v)
    size = v
    for i,child in inner'group':child_pairs() do
      child.hidden = true
    end
    inner(v).hidden = false
  end
  function wrapped:get_scale()
    return h
  end
  function wrapped:set_scale(v)
    inner'scale'.scale2d = vec2(v,v)
    wrapped:set_thickness(1/v)
  end
  function wrapped:get_thickness()
    return thickness
  end
  function wrapped:set_thickness(v)
    thickness = v
    for i,child in ipairs(inner:all('line')) do
      child.thickness = v
    end
  end
  function wrapped:set_color(v)
    for i,child in ipairs(inner:all('line')) do
      child.color = v
    end
  end
  
  return wrapped
end