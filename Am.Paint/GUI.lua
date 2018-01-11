GUI = ...

function GUI.cirbutton(x,y,radius,color,text,fn)
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {
                    am.translate(0,0)
                    ^ am.circle(vec2(0,0),radius,color)
                  ,
                    am.translate(0,0)
                    ^ am.text(text,Color.black)
                  }
  local wrapped = am.wrap(inner):tag"button"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_radius()
    return radius
  end
  function wrapped:set_radius(v)
    radius = v
    inner"circle".radius = radius
  end
  function wrapped:get_rect()
    return vec4(x-radius,y-radius,x+radius,y+radius)
  end
  function wrapped:set_color(v)
    color = v
    inner"circle".color = color
  end
  
  wrapped:action(function(scene)
    if busy then return end
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        scene.color = Color.pressed
        do fn() end
      else
        scene.color = Color.over
      end
    else
      scene.color = Color.white
    end
  end)
  
  return wrapped
end

function GUI.button(window,x,y,width,height,color,text,fn)
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {am.rect(-width*0.5,
                            -height*0.5,
                            width*0.5,
                            height*0.5,
                            color)
                  ,
                    am.text(text,Color.red)
                  }
  local wrapped = am.wrap(inner):tag"button"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_text()
    return inner'text'.text
  end
  function wrapped:set_text(v)
    inner"text".text = v
  end
  function wrapped:get_width()
    return width
  end
  function wrapped:set_width(v)
    width = v
    inner"rect".width = width
  end
  function wrapped:get_height()
    return height
  end
  function wrapped:set_height(v)
    height = v
    inner"rect".height = height
  end
  function wrapped:get_rect()
    return vec4(x-(width*0.5),
                y-(height*0.5),
                x+(width*0.5),
                y+(height*0.5))
  end
  function wrapped:set_color(v)
    --color = v
    inner"rect".color = v
  end
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = window:mouse_position()
    local trigger = window:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if window:mouse_down"left" and trigger then
        scene.color = Color.darker(color)
        do fn() end
      else
        scene.color = Color.lighter(color)
      end
    else
      scene.color = color
    end
  end)
  
  return wrapped
end

function GUI.hslider(window,x,y,width,color,fn)
  local height = width*0.15
  local value = 0
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {
                    am.translate(0,-height*0.5)
                    ^ am.rect(0,
                      height*0.2,
                      width,
                      height*0.8,
                      Color.darker(color))
                  ,
                    am.translate(value*width,0):tag"handle"
                    ^ am.circle(vec2(value,0),height*0.5,color,20)
                  }
  local wrapped = am.wrap(inner):tag"hslider"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_pos()
    return vec2(x+(width*value),y)
  end
  function wrapped:get_width()
    return width
  end
  function wrapped:set_width(v)
    width = v
    inner"rect".width = width
  end
  function wrapped:get_height()
    return height
  end
  function wrapped:set_height(v)
    height = v
    inner"rect".height = height
  end
  function wrapped:get_hradius()
    return height*0.5
  end
  function wrapped:set_color(v)
    color = v
    inner"circle".color = color
  end
  function wrapped:set_value(v)
    if v > 1 or v < 0 then return end
    value = v
    inner"handle".x = value*width
  end
  function wrapped:get_value()
    return value
  end
    
  local function get_v(mx)
    local z = (mx-window.width*0.5)-x
    local ratio = z/width
    return ratio
  end
    
  local drag = false
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = window:mouse_position()
    local down = window:mouse_down"left"
    local trigger = window:mouse_pressed"left"
    if math.distance(scene.pos,mouse_pos) < scene.hradius then
      onGui = true
      if window:mouse_down"left" and trigger then
        drag = true
        scene.color = Color.pressed
      else
        scene.color = Color.over
      end
    else
      scene.color = Color.white
    end
    if drag then
      if not down then
        drag = false
      else 
        local vv = get_v(window:mouse_pixel_position().r)
        scene.value = vv
        do fn(value) end
      end
    end
  end)
  
  return wrapped
end

function GUI.icon(window,x,y,width,height,color,spr,fn,spec)
  local state = false
  local basecol = color
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {
                    am.translate(0,0)
                    ^ am.rect(-width*0.5,
                      -height*0.5,
                      width*0.5,
                      height*0.5,
                      color)
                    ,
                    am.translate(0,0)
                    ^ am.sprite(spr)
                  }
  if spec then inner'group':append(am.translate(0,0)^spec) end
  local wrapped = am.wrap(inner):tag"icon"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_width()
    return width
  end
  function wrapped:set_width(v)
    width = v
    inner"rect".width = width
  end
  function wrapped:get_height()
    return height
  end
  function wrapped:set_height(v)
    height = v
    inner"rect".height = height
  end
  function wrapped:get_rect()
    return vec4(x-(width*0.5),
                y-(height*0.5),
                x+(width*0.5),
                y+(height*0.5))
  end
  function wrapped:set_color(v)
    inner"rect".color = v
  end
  function wrapped:get_color()
    return inner"rect".color
  end
--  function wrapped:set_spec(v)
--    for i,child in inner'group''specs':child_pairs() do
--      child'icon'.state = false
--    end
--    inner'specs':all(v)[1]'icon'.state = true
--  end
  --function wrapped:get_specs()
  --  print(inner'specs')
  --  return inner'group''specs':child_pairs()
  --end
  function wrapped:get_color()
    return inner"rect".color
  end
  function wrapped:get_state()
    return state
  end
  function wrapped:set_state(v)
    state = v
    if state == true then
      inner'sprite'.color = vec4(1,1,1,1)
      if spec then inner'specs'.hidden = false end
    elseif state == false then
      inner'sprite'.color = vec4(1,1,1,0.5)
      if spec then inner'specs'.hidden = true end
    end
  end
  
  inner'sprite'.color = vec4(1,1,1,0.5)
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = window:mouse_position()
    local trigger = window:mouse_pressed"left"
    local over = false
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      over = true
      if window:mouse_down"left" and trigger then
        scene.color = Color.darker(color)
        do fn() end
      else
        scene.color = Color.lighter(color)
      end
    end
    if scene.state then
      scene.color = vec4(0.2,0.2,0.5,1)
    elseif over then
      scene.color = Color.lighter(color)
    else
      scene.color = color
    end
  end)
  
  return wrapped
end

function GUI.sys_button(window,x,y,width,height,color,text,fn)
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {
                    am.translate(0,0)
                    ^ am.rect(-width*0.5,
                      -height*0.5,
                      width*0.5,
                      height*0.5,
                      color)
                  ,
                    am.translate(0,0)
                    ^ am.scale(0.95)
                      ^ am.text(text,Color.black)
                  }
  local wrapped = am.wrap(inner):tag"button"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_width()
    return width
  end
  function wrapped:set_width(v)
    width = v
    inner"rect".width = width
  end
  function wrapped:get_height()
    return height
  end
  function wrapped:set_height(v)
    height = v
    inner"rect".height = height
  end
  function wrapped:get_rect()
    return vec4(x-(width*0.5),
                y-(height*0.5),
                x+(width*0.5),
                y+(height*0.5))
  end
  function wrapped:set_color(v)
    --color = v
    inner"rect".color = v
  end
  
  wrapped:action(function(scene)
    local mouse_pos = window:mouse_position()
    local trigger = window:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if window:mouse_down"left" and trigger then
        scene.color = Color.darker(color)
        do fn() end
      else
        scene.color = Color.lighter(color)
      end
    else
      scene.color = color
    end
  end)
  
  return wrapped
end

function GUI.imgbutton(window,x,y,img,text,fn)
  local sprite = am.sprite(img)
  local width,height = sprite.width,sprite.height
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {
                    am.translate(0,0)
                    ^ sprite
                  ,
                    am.translate(0,0)
                    ^ am.text(text,Color.red)
                  }
  local wrapped = am.wrap(inner):tag"imgbutton"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_sprite()
    return inner"sprite".source
  end
  function wrapped:set_sprite(v)
    inner"sprite".source = v
  end
  function wrapped:get_rect()
    return vec4(x-(width*0.5),
                y-(height*0.5),
                x+(width*0.5),
                y+(height*0.5))
  end
  function wrapped:set_color(v)
    --color = v
    inner"sprite".color = v
  end
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = window:mouse_position()
    local trigger = window:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if window:mouse_down"left" and trigger then
        scene.color = Color.pressed
        do fn() end
      else
        scene.color = Color.over
      end
    else
      scene.color = Color.white
    end
  end)
  
  return wrapped
end