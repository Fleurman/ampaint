GUI = ...

--[[

-----------------------------------------------
V 09
  [ ] TextInput
  [ ] Thumbnail

]]

require './data/Frame'

--[[------------------------------------------------------------------------------
                                **CIRCLE BUTTON**
----------------------------------------------------------------------------------]]
function GUI.cirbutton(x,y,radius,color,text,fn)
  local inner = am.translate(x,y) ^ am.group()
                  ^ { am.translate(0,0) ^ am.circle(vec2(0,0),radius,color),
                    am.translate(0,0) ^ am.text(text,Color.black) }
  local wrapped = am.wrap(inner):tag"button"
  function wrapped:get_x() return x end
  function wrapped:set_x(v) x = v inner"translate".x = x end
  function wrapped:get_y() return y end
  function wrapped:set_y(v) y = v inner"translate".y = x end
  function wrapped:get_radius() return radius end
  function wrapped:set_radius(v) radius = v inner"circle".radius = radius end
  function wrapped:get_rect() return vec4(x-radius,y-radius,x+radius,y+radius) end
  function wrapped:set_color(v) color = v inner"circle".color = color end
  
  wrapped:action(function(scene)
    if busy then return end
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then onGui = true
      if win:mouse_down"left" and trigger then
        scene.color = Color.pressed do fn() end
      else scene.color = Color.over end
    else scene.color = Color.white
  end end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                  **BUTTON**
----------------------------------------------------------------------------------]]
function GUI.button(x,y,width,height,color,ico,text,fn)
  local active = true
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ {am.rect(-width*0.5,
                            -height*0.5,
                            width*0.5,
                            height*0.5,
                            color)
                    }
  local tx,al = 0,nil
  if ico then
    local x = (-width*0.5) + (ico.width*0.5)
    local y = (height - ico.height)*-0.5
    y = y >= 0 and y or 0
    inner'group':append(am.translate(x,y)^ico:tag('icon'))
    tx = x+2+ico.width*0.5
    al='left'
  end
  inner'group':append( am.translate(tx,0) ^ am.text(text,Color.black,al))
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
  function wrapped:set_icon(v)
    inner'icon'.source = v
  end
  function wrapped:get_active()
    return active
  end
  function wrapped:set_active(v)
    active = v
    if v then
      inner'rect'.color = color
      inner'text'.color = Color.black
    else
      inner'rect'.color = Color.darker(color)
      inner'text'.color = vec4(1,1,1,0.5)
    end
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
    if onAct or onSys or not active then return end
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
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

--[[------------------------------------------------------------------------------
                              **HORIZONTAL SLIDER**
----------------------------------------------------------------------------------]]
function GUI.hslider(x,y,width,color,fn)
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
    local z = (mx-win.width*0.5)-x
    local ratio = z/width
    return ratio
  end
    
  local drag = false
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = win:mouse_position()
    local down = win:mouse_down"left"
    local trigger = win:mouse_pressed"left"
    if math.distance(scene.pos,mouse_pos) < scene.hradius then
      onGui = true
      if win:mouse_down"left" and trigger then
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
        local vv = get_v(win:mouse_pixel_position().x)
        scene.value = vv
        do fn(value) end
      end
    end
  end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                              **VERTICAL SLIDER**
----------------------------------------------------------------------------------]]
function GUI.vslider(x,y,width,height,color,dir,fn)
  --local width = height*0.15
  local value = dir=='down' and 1 or 0
  local inner = am.translate(x,y)
                ^ am.read_uniform("MV"):tag('read')
                ^ am.group()
                  ^ {
                    am.translate(0,0)
                    ^ am.rect(0,0,width,height,color)
                    ,
                    am.translate(0,0)
                    ^ am.rect(2,2,width-2,height-2,Color.whiten(color))
                    ,
                    am.translate(width*0.5,(width*0.5) + value*(height-width)):tag"handle"
                    ^ am.group()
                    ^ { am.rect(-(width*0.4),width*0.4,width*0.4,-width*0.4,Color.black),
                       am.rect(1-(width*0.4),-1+width*0.4,-1+width*0.4,1-width*0.4,
                         Color.white):tag('color') }
                    --^ am.circle(vec2(0,value),width*0.5,color,20)
                  }
  local wrapped = am.wrap(inner):tag"vslider"
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
    return vec2(x,y+value*(height-width))
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
    local vy = y+(value*(height-width))
    return vec4(x,vy,x+width,vy+width)
  end
  function wrapped:set_color(v)
    --color = v
    --inner"circle".color = color
    inner'handle''color'.color = v
  end
  function wrapped:set_value(v)
    v = math.clamp(0,v,1)
    v = dir=='down' and 1-v or v
    value = v
    inner"handle".y = (width*0.5) + value*(height-width)
  end
  function wrapped:get_value()
    return dir=='down' and 1-value or value
  end
  
  local function get_v(my)
    local mv = inner'read'.value[4]
    local yy = mv.y
    local z = (my-win.height*0.5)-yy-width*0.5
    local ratio = z/(height-width)
    ratio = dir=='down' and 1-ratio or ratio
    return math.round(ratio,3)
  end
  
  function wrapped:get_vec()
    local mv = inner'read'.value[4]
    local xx,yy = mv.x,mv.y
    local vy = yy+(value*(height-width))
    return vec4(xx,vy,xx+width,vy+width)
  end
  
  local drag = false
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = win:mouse_position()
    local down = win:mouse_down"left"
    local trigger = win:mouse_pressed"left"
    if math.within(scene.vec,mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        drag = true
      else
        scene.color = Color.blacken(color)
      end
    else
      scene.color = color
    end
    if drag then
      if not down then
        drag = false
      else 
        local vv = get_v(win:mouse_pixel_position().y)
        scene.value = vv
        if fn then do fn(scene.value) end end
      end
    end
  end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                  **LIST** x,y,width,height,color,items
----------------------------------------------------------------------------------]]
function GUI.list()
  local node = am.translate(0,0) ^ am.viewport(win.width-195,win.top-175,170,270)
                ^ am.scale(vec2(win.width/170,win.height/270)) ^ am.group()
                ^ { am.rect(-100,-1000,100,1000,Color.red),
                  am.translate(-85,135):tag('viewpos') ^ am.group()
                  ^ { am.rect(5,-35,165,-5,Color.over),
                      am.rect(5,-70,165,-40,Color.over)}
                  , am.translate(-85,135) ^ am.group()
                  ^ { am.rect(-10,-10,10,10,Color.yellow),am.rect(-1,-1,1,1,Color.black)}
                }
  local bt = GUI.vslider(win.right-20,win.bottom+175,20,275,Color.pressed,'down',
                          function(v)
                            win.scene'log'.text = 200*v
                            win.scene'viewpos'.y= 135 + 200*v 
                          end)
  return am.group() ^ {node,bt}
end

--[[------------------------------------------------------------------------------
                                    **ICON**
----------------------------------------------------------------------------------]]
function GUI.icon(x,y,width,height,color,spr,fn,spec)
  local state = false
  local basecol = color
  local inner = am.translate(x,y)
                ^ am.group()
                  ^ { am.translate(0,0)
                      ^ am.sprite(Src.buttons.medium.normal):tag('back'),
                    am.translate(0,0) ^ am.sprite(spr)
                  }
  if spec then inner'group':append(am.translate(0,0)^spec) end
  local wrapped = am.wrap(inner):tag"icon"
  function wrapped:get_x() return x end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y() return y end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_width() return width end
  function wrapped:set_width(v)
    width = v
    inner"rect".width = width
  end
  function wrapped:get_height() return height end
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
  function wrapped:set_back(v) inner"back".source = v end
  function wrapped:get_state() return state end
  function wrapped:set_state(v)
    state = v
    if state == true then
      inner'back'.color = vec4(1,1,1,1)
      inner'sprite'.color = vec4(1,1,1,1)
      if spec then inner'specs'.hidden = false end
    elseif state == false then
      inner'back'.color = vec4(1,1,1,0.5)
      inner'sprite'.color = vec4(1,1,1,0.5)
      if spec then inner'specs'.hidden = true end
    end
  end
  
  inner'sprite'.color = vec4(1,1,1,0.5)
  
  wrapped:action(function(scene)
    if onAct or onSys then return end
    local mouse_pos = win:mouse_position()
    local over = false
    if math.within(scene.rect,mouse_pos) then
    local trigger = win:mouse_pressed"left"
      onGui = true
      over = true
      if win:mouse_down"left" and trigger then
        scene.back = Src.buttons.medium.active
        do fn() end
      elseif not state then scene.back = Src.buttons.medium.hover
      else scene.back = Src.buttons.medium.normal
      end
    else scene.back = Src.buttons.medium.normal
    end
  end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                **SYSTEM BUTTON**
----------------------------------------------------------------------------------]]
function GUI.sys_button(x,y,width,height,back,ico,text,fn)
  local color = type(back)=='userdata'
  local inner = am.translate(x,y) ^ am.group()
                  ^ { am.translate(0,0) }
  if color then
    inner'group':append(am.rect(-width*0.5, -height*0.5, width*0.5, height*0.5, back):tag('back'))
  else
    inner'group':append(am.sprite(back.normal):tag('back'))
  end
  local tx = 0
  if not (ico == nil) then
    inner'group':append(am.sprite(ico):tag('icon'))
    tx = ico.width + 1
  end
  inner'group':append( am.translate(tx,0) ^ am.scale(0.95) ^ am.text(text,Color.black))
  local wrapped = am.wrap(inner):tag"button"
  function wrapped:get_x() return x end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y() return y end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_width() return width end
  function wrapped:set_width(v)
    width = v
    inner"back".width = width
  end
  function wrapped:get_height() return height end
  function wrapped:set_height(v)
    height = v
    inner"back".height = height
  end
  function wrapped:get_rect()
    return vec4(x-(width*0.5),
                y-(height*0.5),
                x+(width*0.5),
                y+(height*0.5))
  end
  function wrapped:set_color(v) 
    inner"back".color = v
  end
  function wrapped:get_back()
    if color then return end
    return inner"back".source 
  end
  function wrapped:set_back(v)
    if color then return end
    inner"back".source = v 
  end
  
  wrapped:action(function(scene)
    if onAlt then return end
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        
        if color then
          scene.color = Color.darker(back)
        else
          scene.back = back.active
        end
        do fn() end
      else 
        if color then
          scene.color = Color.lighter(back)
        else
          scene.back = back.hover
        end
      end
    else 
      if color then
        scene.color = back
      else
        scene.back = back.normal
      end
    end
  end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                  **FILE ENTRY**
----------------------------------------------------------------------------------]]
function GUI.fileEntry(x,y,width,height,color,text,fn)
  local inner = am.translate(x,y) ^ am.group()
                  ^ { am.translate(0,0) ^ am.rect(-width*0.5, -height*0.5, width*0.5, height*0.5, color) ,
                    am.translate(0,0) ^ am.scale(0.95) ^ am.text(text,Color.black) }
  local wrapped = am.wrap(inner):tag"button"
  function wrapped:get_x() return x end
  function wrapped:set_x(v)
    x = v
    inner"translate".x = x
  end
  function wrapped:get_y() return y end
  function wrapped:set_y(v)
    y = v
    inner"translate".y = x
  end
  function wrapped:get_width() return width end
  function wrapped:set_width(v)
    width = v
    inner"rect".width = width
  end
  function wrapped:get_height() return height end
  function wrapped:set_height(v)
    height = v
    inner"rect".height = height
  end
  function wrapped:get_rect() return vec4(x-(width*0.5), y-(height*0.5), x+(width*0.5), y+(height*0.5)) end
  function wrapped:set_color(v) inner"rect".color = v end
  
  wrapped:action(function(scene)
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        scene.color = Color.darker(color)
        do fn() end
      else scene.color = Color.lighter(color)
      end
    else scene.color = color
    end
  end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                **IMAGE BUTTON**
----------------------------------------------------------------------------------]]
function GUI.imgbutton(x,y,imgs,icon,fn,deb)
  local sprite = am.sprite(imgs.normal)
  local width,height = sprite.width,sprite.height
  local active = true
  local state = false
  local inner = am.translate(x,y) ^ am.read_uniform("MV"):tag('read') ^ am.group()
                  ^ { am.translate(0,0) ^ sprite:tag('back') ,
                      am.translate(-1,1):tag('iconpos')}
  if(icon) then inner'iconpos':append(am.sprite(icon):tag('icon')) end
  local wrapped = am.wrap(inner):tag"imgbutton"
  function wrapped:get_x() return x end
  function wrapped:set_x(v) x = v inner"translate".x = x end
  function wrapped:get_y() return y end
  function wrapped:set_y(v) y = v inner"translate".y = y end
  function wrapped:get_active() return active end
  function wrapped:set_active(v)
    active = v
    local vec = v and vec4(1,1,1,1) or vec4(1,1,1,0.6)
    inner'back'.color = vec
    if(icon) then inner'icon'.color = vec end
  end
  function wrapped:get_state() return state end
  function wrapped:set_state(v)
    state = v
    local vec = v and vec4(0.4,0.6,0,1) or vec4(1,1,1,1)
    inner'back'.color = vec
  end
  function wrapped:get_icon() if(icon) then return inner"icon".source end end
  function wrapped:set_icon(v) 
    if(icon) then 
      inner"icon".source = v 
    else
      icon = v
      inner'iconpos':append(am.sprite(icon):tag('icon')) 
    end 
  end
  function wrapped:get_back() return inner"back".source end
  function wrapped:set_back(v) inner"back".source = v end
  function wrapped:set_click(v) v = v and 0 or 1 inner"iconpos".position2d = vec2(-v,v) end
  function wrapped:get_rect()
    local xx,yy = x,y
    if type(inner'read'.value) == 'userdata' then
      local mv = inner'read'.value[4]
      xx,yy = mv.x,mv.y
    end
    return vec4(xx-(width*0.5), yy-(height*0.5), xx+(width*0.5), yy+(height*0.5)) 
  end
  function wrapped:set_color(v) inner"sprite".color = v end
  local function click(b)wrapped:set_click(b)local i=b and imgs.active or imgs.normal wrapped:set_back(i) end
  
  local clicked = clicked
  wrapped:action(function(scene)
    if onAct or onSys then return end
    if not active then return end
    local mouse_pos = win:mouse_position()
    if win:mouse_released"left" then clicked = false end
    if math.within(scene.rect,mouse_pos) then
      onGui = true
      scene.back = imgs.hover
      if win:mouse_pressed"left" then clicked = true if fn then do fn() end end end
      if win:mouse_down"left" and clicked then click(true)
      else scene.click = false
      end
    else clicked = false click(false)
    end
  end)
  
  return wrapped
end

--[[------------------------------------------------------------------------------
                                      **ALERT**
----------------------------------------------------------------------------------]]
function GUI.alert(text,fn)
  local w,h = 360,120
  local x,y = 0,0
  local node = am.translate(x,y):tag('alert') ^ am.group()
                  ^ {am.rect(x-3-w/2,y-3-h/2,x+3+w/2,y+3+h/2,vec4(0.9,0.6,0.5,1)):tag('border'),
                    am.rect(x-w/2,y-h/2,x+w/2,y+h/2,vec4(0.7,0.7,0.7,1)),
                    am.translate(x,y+25) ^ am.scale(vec2(1.5)) ^ am.text(text,Color.red),
                    am.translate(x,y-35) ^ am.sprite(Src.buttons.big.normal):tag('ok'), 
                    am.translate(x,y-35)^am.text('Ok',Color.black)
                    }
  node'border':action(coroutine.create(function(node) for i=0,3 do
        am.wait(am.delay(0.1)) node.color = vec4(0.7,0.4,0.3,1)
        am.wait(am.delay(0.1)) node.color = vec4(0.9,0.6,0.5,1)
  end end ))
  node'ok':action(function(scene)
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(vec4(x-50,-50,x+50,-20),mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        scene.source = Src.buttons.big.active
        if fn then do fn() end end
        onAlt = false
        win.scene:remove('alert')
      else scene.source = Src.buttons.big.hover
      end
    else scene.source = Src.buttons.big.normal
    end
  end)
  onAlt = true
  return node
end

--[[------------------------------------------------------------------------------
                                  **CONFIRMATION**
----------------------------------------------------------------------------------]]
function GUI.confirmation(text,fn)
  local w,h = 400,120
  local x,y = 0,0
  local node = am.translate(x,y):tag"confirmation"
                ^ am.group()
                  ^ {am.rect(x-2-w/2,y-2-h/2,x+2+w/2,y+2+h/2,vec4(0.9,0.6,0.5,1))
                    ,am.rect(x-w/2,y-h/2,x+w/2,y+h/2,vec4(0.7,0.7,0.7,1))
                  ,
                    am.translate(x,y+25)
                    ^ am.scale(vec2(1.5))
                    ^ am.text(text,Color.red)
                  ,
                    am.translate(x-75,y-35)
                    ^ am.group():tag('okgroup')
                    ^ { am.rect(x-50,15,x+50,-15,vec4(0.3,0.7,0.3,1)):tag('ok')
                        , am.text('Ok',Color.black)}
                  ,
                    am.translate(x+75,y-35)
                    ^ am.group()
                    ^ { am.rect(x-50,15,x+50,-15,Color.red):tag('cancel')
                        , am.text('Cancel',Color.white)}
                  }
  
  node'ok':action(function(scene)
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(vec4(x-125,-50,x-25,-20),mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        scene.color = vec4(0.1,0.5,0.1,1)
        if fn then do fn() end end
        onAlt = false
        win.scene:remove('confirmation')
      else
        scene.color = vec4(0.5,0.9,0.5,1)
      end
    else
      scene.color = vec4(0.3,0.7,0.3,1)
    end
  end)

  node'cancel':action(function(scene)
    local mouse_pos = win:mouse_position()
    local trigger = win:mouse_pressed"left"
    if math.within(vec4(x+25,-50,x+125,-15),mouse_pos) then
      onGui = true
      if win:mouse_down"left" and trigger then
        scene.color = Color.darker(Color.red)
        if fn then do fn() end end
        onAlt = false
        win.scene:remove('confirmation')
      else
        scene.color = Color.lighter(Color.red)
      end
    else
      scene.color = Color.red
    end
  end)
  onAlt = true
  return node
end

--[[------------------------------------------------------------------------------
                                  **LOG MESSAGE**
----------------------------------------------------------------------------------]]
function GUI.log(text,fn)
  local w,h = 600,20
  local logs = #win.scene:all"logbox" + 1
  local sx,sy = 0,win.bottom-20
  local node = am.translate(sx,sy):tag"logbox" ^ am.group()
                ^ {am.read_uniform('MV'):tag('read'),
                  am.translate(-w/2,-h/2) ^ am.rect(0,0,w,h,vec4(0.8,0.2,0.1,1)),
                  am.text(text,Color.whitesmoke) }

  node:action(coroutine.create(function(scene)
    while true do
      am.wait(am.tween(scene'logbox',0.5, { y = sy+10+(logs*(h+5)) }))
      --scene.paused = true
      am.wait(am.delay(2))
      am.wait(am.tween(scene'logbox',0.5, { y = sy }))
      win.scene:remove('logbox')
    end
  end))
--  node:action(function(rect)
--  local mouse_pos = win:mouse_position()
--    local mv = node'read'.value[4]
--    if math.within(vec4(mv.x-90,mv.y-32,mv.x+70,mv.y+0),mouse_pos) then
--      print('hover')
--      onGui = true
--      if win:mouse_pressed"left" then
        
--      end
--    end
--  end)
  
  
  
  return node
end