local canvas = ...

--[[--------------------------------------------------------------------
                                **TILES**
----------------------------------------------------------------------]]
local function tiles(w,h,spr)
  --spr = '..\n..'
  local state = false
  local inner = am.group()
                ^ { am.translate(-w,-h) ^ spr,
                    am.translate(0,-h) ^ spr,
                    am.translate(w,-h) ^ spr,
                    am.translate(w,0) ^ spr,
                    am.translate(w,h) ^ spr,
                    am.translate(0,h) ^ spr,
                    am.translate(-w,h) ^ spr,
                    am.translate(-w,0) ^ spr }
  --inner'group'.color = vec4(1,1,1,0.9)
  local wrapped = am.wrap(inner):tag('tiles')
  function wrapped:set_sprite(v) 
    --for i,c in inner'group':child_pairs() do c'sprite'.source = v end 
  end
  function wrapped:set_state(v) state = v wrapped:refresh() end
  function wrapped:refresh() for i,c in inner'group':child_pairs() do c.hidden = (not state) end end
  wrapped:refresh()
  function wrapped:trigger() state = (not state) wrapped:refresh() end
  return wrapped
end

--[[--------------------------------------------------------------------
                              **NEW CANVAS**
----------------------------------------------------------------------]]
function canvas.new(w,h,init)
  local width = w
  local height = h
  local scale = math.floor(360/h)
  local mouse = {left=false,right=false}
  local x,y = 0,0
  local brush = {'pencil','norm'}
  local name = ""
  local params = {line = false}
  local dragging = false
  local index = 1
  local last_id = 1
  local layer = 1
  local pixels = init or {}
  local undos = {}
  local cundo = 1
  local sprite = [[..\n..]]
  local flat = [[..\n..]]
  local dummy = { offset=1, line=[[,]] }
  for i=2,width do
    dummy.line = dummy.line .. '.'
  end
  
  
  local buff = am.buffer(4*width*height)
  buff.usage = "dynamic"
  local view = buff:view('ubyte')
  view:set(0)
  local image = am.image_buffer(buff,width,height)
  local texture = am.texture2d(image)
  local spec = {texture= texture,s1= 0,t1= 0,s2= 1,t2= 1,x1= 0,y1= 0,x2= width,y2= height,width= width,height= height,}
  local dsprite = am.rotate(math.rad(180), vec3(1, 0, 0)) ^ am.sprite(spec)
  win.scene'view''sprite'.source = spec
  
  function blankData(w,h)
    local tab = {}
    for i = 1,(w*h) do
      table.insert(tab,'.')
    end
    return tab
  end
  ----------------------------------------------------------------------
  function flat_sprite()
    local tmpa = blankData(width,height)
    view:set(0)
            
    for i = 1,#pixels do
      if pixels[i].visible then
        for d = 1,(width*height) do
            local char = string.char(pixels[i].data[d])
            local vc = ((d-1)*4)+1
            if(am.ascii_color_map[char]) then
              local dat = am.ascii_color_map[char] or vec4(0)
              dat = dat*255
              view:set({dat.r,dat.g,dat.b,dat.a},vc,4)
            end
        end
      end
    end
    
    tmpa = table.group(tmpa,width)
    if tmpa == nil then
      sprite = string.padLeft('',width,'.')
    else
      sprite = toSprite(tmpa)
    end
    setDummy()
    flat = dummy.line .. '\n' .. sprite  .. '\n' .. dummy.line
    return flat
  end
  
  function setDummy()
    local name = Palette.name
    dummy.offset = math.ceil(#Palette.name/width)
    local lim = dummy.offset*width
    dummy.line = wrap(string.padLeft(Palette.name,lim,'.'),width)
  end
  
  function toSprite(a)
    local nsp = ''
    for i,r in ipairs(a) do
      local tl = ''
      for n,l in ipairs(r) do tl = tl .. l end
      nsp = nsp .. tl
    if i < height then nsp = nsp .. '\n' end
    end
    return nsp
  end
  flat_sprite()
  
  ----------------------------------------------------------------------
  local inner = am.translate(x,y):tag"position"
                ^ { am.scale(scale):tag"scale"
                    ^ {
                      am.sprite(Sprites:textured("void",width,height))
                      , tiles(width,height,dsprite)
                      , am.group():tag"layers"
                      , dsprite
                      }
                      , Cursor:node(0,0,1,1,0.1,vec4(0.95,0.95,0.95,1)):tag('norm')
                      , am.line(vec2(0,0),vec2(0,0),0,vec4(1,1,0.5,0.7))
                      , am.square(vec2(0),vec2(0),vec4(1,1,0.5,0.7),scale-6):tag('form-square')
                      , am.disc(vec2(0,0),0,vec4(1,1,0.5,0.7),scale):tag('form-circle')
                  }
  local wrapped = am.wrap(inner):tag"canvas"
  
  ----------------------------------------------------------------------
  function wrapped:addLayer()
    if #pixels > 5 then return end
    local obj = OLayer.new({},width,height)
    for i=1,#pixels do
      pixels[i].level = i
    end
    table.insert(pixels,obj)
    Layers:addLayer()
  end
  if not init then wrapped:addLayer() end
  ----------------------------------------------------------------------
  function wrapped:duplicateLayer()
    if #pixels > 5 then return end
    local obj = pixels[layer]:copy()
    table.insert(pixels,layer+1,obj)
    for i=1,#pixels do
      pixels[i].level = i
    end
    Layers:duplicateLayer(obj)
  end
  ----------------------------------------------------------------------
  function wrapped:removeLayer(id)
    if #pixels == 1 then return end;
    table.remove(pixels,layer)
    for i=1,#pixels do
      pixels[i].level = i
    end
    Layers:removeLayer(layer)
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:moveLayerUp()
    if layer == 1 then return end
    pixels[layer],pixels[layer-1] = pixels[layer-1],pixels[layer]
    for i=1,#pixels do
      pixels[i].level = i
    end
    Layers:moveLayerUp()
    layer = layer-1
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:moveLayerDown()
    if layer == #pixels then return end
    pixels[layer+1],pixels[layer] = pixels[layer],pixels[layer+1]
    for i=1,#pixels do
      pixels[i].level = i
    end
    Layers:moveLayerDown()
    layer = layer+1
    refresh()
  end
  
  ----------------------------------------------------------------------
  function refresh()
    flat_sprite()
    win.scene'view''sprite'.source = spec
  end
  
  function wrapped:redraw()
    refresh()
  end
  ----------------------------------------------------------------------
  function trigger_tiles() inner'tiles'.trigger() end
  
  function positionFromIndex(id)
    local pox = (((id-1)%width)*scale)-((width*scale)/2)+scale/2
    local poy = ((height-math.floor((id-1)/width))*scale)-((height*scale)/2)-scale/2
    return vec2(pox,poy)
  end
  function wrapped:positionFromIndex(id)
    return positionFromIndex(id)
  end
  ----------------------------------------------------------------------
  function draw_lineID(from,target,col)
    if brush[2] == 'size2' then
      pixels[layer]:setCrossLine(from,target,col)
    elseif brush[2] == 'size3' then
      pixels[layer]:setSquareLine(from,target,col)
    else
      pixels[layer]:setPixelLine(from,target,col)
    end
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:get_sprite() flat_sprite() return sprite end
  ----------------------------------------------------------------------
  function wrapped:get_dummy() setDummy() return dummy end
  ----------------------------------------------------------------------
  function wrapped:get_image_buffer() return image end
  ----------------------------------------------------------------------
  function wrapped:get_view() return view end
  ----------------------------------------------------------------------
  function wrapped:get_flatten() return flat_sprite() end
  ----------------------------------------------------------------------
  function wrapped:set_scale(v)
    scale = v
    inner"scale".scale2d = vec2(v,v)
    inner"cursor".scale = v
  end
  ----------------------------------------------------------------------
  function wrapped:get_scale() return scale end
  ----------------------------------------------------------------------
  function wrapped:set_cursor(pos) inner"cursor".x,inner"cursor".y = pos[1],pos[2] end
  ----------------------------------------------------------------------
  function change_cursor(t)
    local s = (t=='size2'or t=='size3') and t or 'norm'
    inner'cursor'.size = s
  end
  ----------------------------------------------------------------------
  function wrapped:get_x() return x end
  ----------------------------------------------------------------------
  function wrapped:set_x(v) x=v inner"position".x=v end
  ----------------------------------------------------------------------
  function wrapped:get_name() return name end
  ----------------------------------------------------------------------
  function wrapped:set_name(v) name = v end
  ----------------------------------------------------------------------
  function wrapped:get_y() return y end
  ----------------------------------------------------------------------
  function wrapped:set_y(v) y=v inner"position".y=v end
  ----------------------------------------------------------------------
  function wrapped:get_rect()
    return vec4((-width*0.5)*scale,(-height*0.5)*scale,(width*0.5)*scale,(height*0.5)*scale)
  end
  ----------------------------------------------------------------------
  function get_pixel(id)
    return string.char(pixels[layer].data[id])
  end
  ----------------------------------------------------------------------
  function wrapped:set_pixel(v)
    if brush[2] == 'size2' then
      pixels[layer]:setCross(index,v)
    elseif brush[2] == 'size3' then
      pixels[layer]:setSquare(index,v)
    else
      pixels[layer]:setPixel(index,v)
    end
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:set_bucket(v)
    local old = string.char(pixels[layer].data[index])
    if brush[2] == 'normal' then
      pixels[layer]:fill(index,v)
    elseif brush[2] == 'fillerase' then
      pixels[layer]:fill(index,'.')
    elseif brush[2] == 'bycolor' then
      pixels[layer]:fillByColor(old,v)
    end
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped.datas() return pixels end
  ----------------------------------------------------------------------
  function wrapped:get_pixels() return pixels end
  ----------------------------------------------------------------------
  function wrapped:set_pixels(v) 
    pixels = v
    refresh() 
  end
  ----------------------------------------------------------------------
  function wrapped:get_undos() return undos end
  ----------------------------------------------------------------------
  function wrapped:set_undos(v) undos = v end
  ----------------------------------------------------------------------
  function wrapped:get_dim() return vec2(width,height) end
  ----------------------------------------------------------------------
  function wrapped:set_brush(v) brush[1] = v end
  ----------------------------------------------------------------------
  function wrapped:get_brush() return brush end
  ----------------------------------------------------------------------
  function wrapped:set_spec(v) brush[2]=v change_cursor(v) end
  ----------------------------------------------------------------------
  function wrapped:get_spec() return brush[2] end
  ----------------------------------------------------------------------
  function wrapped:set_layer(v) layer = v end
  ----------------------------------------------------------------------
  function wrapped:get_layer() return layer end
  ----------------------------------------------------------------------
  function wrapped:rec_undo(src)
    pixels[layer]:record(src)
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:do_undo()
    pixels[layer]:undo()
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:do_redo()
    pixels[layer]:redo()
    refresh()
  end
  ----------------------------------------------------------------------
  function pick_color(click)
    local p = get_pixel(index)
    if p == '.' then else
      Sprites.selected[click] = p
      win.scene("selected" .. click).color = am.ascii_color_map[p]
    end
  end
  ----------------------------------------------------------------------
  function displace(x,y)
    pixels[layer]:move(x,y)
    refresh()
  end
  ----------------------------------------------------------------------
  function emptyDrawing()
    pixels[layer]:empty()
    refresh()
  end
  
  --[[--------------------------------------------------------------------
                                  **ACTION**
  ----------------------------------------------------------------------]]
  wrapped:action(function(scene)
      
    if onSys then return end
    if onGui then
      inner"cursor".hidden = true
      onGui = false 
      return 
    end
    local r = scene.rect
    local mp = win:mouse_pixel_position() - vec2(win.width/2,win.height/2) - vec2(x,y)
    inner"cursor".hidden = true
    if math.within(r,mp) then
      
      if win:mouse_pressed('middle') then
        dragging = true
      elseif win:mouse_released('middle') then
        dragging = false
      elseif win:mouse_pressed('left') then
        mouse.left = true
      elseif win:mouse_released('left') then
        mouse.left = false
      elseif win:mouse_pressed('right') then
        mouse.right = true
      elseif win:mouse_released('right') then
        mouse.right = false
      end
      
      inner"cursor".hidden = false
      local ix = math.floor(mp.x/scale)
      local iy = math.floor((mp.y)/scale)
      scene.cursor = {ix*scale,iy*scale}
      index = (1+ix+(width*0.5)) + (((height*0.5)-iy-1)*width)
      
      inner"line".thickness = 0
      --inner"form-square".radius = vec2(0)
      --inner"form-circle".radius = vec2(0)
      inner"form-square".style = 'none'
      inner"form-circle".style = 'none'
          
      -- FORM MODE ================================================
      if brush[1] == 'form' then
        if mouse.left or mouse.right then
          if win:mouse_pressed("left") or win:mouse_pressed("right") then last_id = index end
          
          if brush[2]=='square' or brush[2]=='squarefull' then

            local sta = positionFromIndex(last_id)
            local cur = sta - positionFromIndex(index)
            sta = sta - cur/2
            
            local rad = math.abs(cur/2)
            local rx = math.abs(rad.x+scale/2)
            local ry = math.abs(rad.y+scale/2)

            inner"form-square".center = sta
            inner"form-square".radius = vec2(rx,ry)
            inner"form-square".thickness = math.max(1,scale)

            if(brush[2]=='squarefull') then
              inner"form-square".style = 'fill'
            else
              inner"form-square".style = 'line'
            end

          elseif brush[2]=='circle' or brush[2]=='circlefull' then
            
            local sta = positionFromIndex(last_id)
            local cur = sta - positionFromIndex(index)
            sta = sta - cur/2
            
            local rad = math.abs(cur/2)
            local rx = math.abs(rad.x+scale/2)
            local ry = math.abs(rad.y+scale/2)

            inner"form-circle".center = sta
            inner"form-circle".radius = vec2(rx,ry)
            inner"form-circle".thickness = math.max(1,scale)
            
            if(brush[2]=='circlefull') then
              inner"form-circle".style = 'fill'
            else
              inner"form-circle".style = 'line'
            end

          end
          
        end
        if win:mouse_released('left') or win:mouse_released('right') then
          
          local c = '.'
          
          if win:mouse_released('left') then
            c = Sprites.selected[1]
          end
          if win:mouse_released('right') then
            c = Sprites.selected[2]
          end
          
          local target = index
          local proportional = false --win:key_down('lshift')
          
          if brush[2]=='square' then
            pixels[layer]:drawLineSquare(last_id,target,c,proportional)
          elseif brush[2]=='squarefull' then
            pixels[layer]:drawFullSquare(last_id,target,c,proportional)
          elseif brush[2]=='circle' then
            pixels[layer]:drawLineCircle(last_id,target,c,proportional)
          elseif brush[2]=='circlefull' then
            pixels[layer]:drawFullCircle(last_id,target,c,proportional)
          end
          refresh()
          
        end
      -- COLOR PICKER MODE ================================================
      elseif Cuts:down('colorpicker') then
        if brush[1] == 'pencil' or
           brush[1] == 'brush' or
           brush[1] == 'eraser' or
           brush[1] == 'bucket' then
          if win:mouse_down("left") then
            pick_color(1)
          elseif win:mouse_down("right") then
            pick_color(2)
          end
        end
        
      -- LINE MODE ================================================
      elseif win:key_down('lshift') then
        if brush[1] == 'pencil' or
           brush[1] == 'brush' or
           brush[1] == 'eraser' then
            params.line = true
            inner"line".thickness = math.max(2,scale/2)
            inner"line".point1 = positionFromIndex(last_id)
            inner"line".point2 = vec2(mp.x-(mp.x%scale),mp.y-(mp.y%scale)) + scale/2
          if win:mouse_released('left') then
            local c = (brush[1]=='eraser') and '.' or Sprites.selected[1]
            draw_lineID(last_id,index,c)
          end
          if win:mouse_released('right') then
            local c = (brush[1]=='eraser') and '.' or Sprites.selected[2]
            draw_lineID(last_id,index,c)
          end
        end
      else
      -- NORMAL MODE ================================================
        if brush[1] == 'pencil' then
          if mouse.left then
            scene.pixel = Sprites.selected[1]
          elseif mouse.right then
            scene.pixel = Sprites.selected[2]
          end
        elseif brush[1] == 'eraser' then
          if mouse.left then
            scene.pixel = '.'
          elseif mouse.right then
            scene.pixel = '.'
          end
        elseif brush[1] == 'bucket' then
          if mouse.left then
            scene.bucket = Sprites.selected[1]
          elseif mouse.right then
            scene.bucket = Sprites.selected[2]
          end
        end
      end
      
      if win:mouse_released('left') or
         win:mouse_released('right') then
        last_id = index
        if brush[1] == 'pencil' or brush[1] == 'eraser' or brush[1] == 'bucket' then
          if(win:key_down('lshift')) then return end
          scene.rec_undo(nil,"mouse up")
        end
      end
    
    end -- END OF MOUSE WITHIN CANVAS -------------------------------------

    if win:mouse_released('left') or win:mouse_released('right') then
      mouse.left,mouse.right = false,false
    end
    if dragging then
      scene.x = scene.x + win:mouse_pixel_delta().x
      scene.y = scene.y + win:mouse_pixel_delta().y
    end
    if Cuts:active('centerview') and not win:mouse_down('middle') then
      scene.x, scene.y,scene.scale = 0,0,math.floor((360)/h)
    elseif Cuts:active('swapcolor') then
      Sprites.selected[1],Sprites.selected[2] = Sprites.selected[2],Sprites.selected[1]
      win.scene"colors""selected1".color = am.ascii_color_map[Sprites.selected[1]]
      win.scene"colors""selected2".color = am.ascii_color_map[Sprites.selected[2]]
    elseif Cuts:active('eraser') then
      select_tool('eraser')
    elseif Cuts:active('pencil') then
      select_tool('pencil')
    elseif Cuts:active('bucket') then
      select_tool('bucket')
    elseif Cuts:active('shapes') then
      select_tool('form')
    elseif Cuts:down('move') then
      if win:key_pressed('left') then
        displace(-1,0)
      elseif win:key_pressed('right') then
        displace(1,0)
      elseif win:key_pressed('up') then
        displace(0,-1)
      elseif win:key_pressed('down') then
        displace(0,1)
      end
    elseif Cuts:active('viewer') then
      viewer.trigger()
    elseif Cuts:active('tiles') then
      trigger_tiles()
    elseif Cuts:active('delete') then
      emptyDrawing()
    elseif Cuts:active('upperlayer') then
      Layers:selectUpperLayer()
    elseif Cuts:active('bottomlayer') then
      Layers:selectBottomLayer()
    elseif Cuts:active('visible') then
      Layers:selectUpperLayer()
    elseif Cuts:active('lock') then
      Layers:selectBottomLayer()
    elseif Cuts:active('undo') then
      scene.do_undo()
    elseif Cuts:active('redo') then
      scene.do_redo()
    elseif Cuts:active('save') then
      menu:autoSave(scene.name)
    elseif Cuts:active('saveas') then
      menu:saveAs(scene.name)
    elseif Cuts:active('export') then
      menu:autoPng(scene.name)
    elseif Cuts:active('exportas') then
      menu:pngAs(scene.name)
    end
    local d = win:mouse_wheel_delta().y
    local s = scene.scale
    local zoom = math.clamp(1,d + s,50)
    if win:mouse_wheel_delta() then
      scene.scale = zoom
    end
  end)
  refresh()
  return wrapped
end