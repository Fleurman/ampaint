local canvas = ...

--[[--------------------------------------------------------------------
                                **TILES**
----------------------------------------------------------------------]]
local function tiles(w,h,spr)
  local state = false
  local inner = am.group()
                ^ { am.translate(-w,-h) ^ am.sprite(spr),
                    am.translate(0,-h) ^ am.sprite(spr),
                    am.translate(w,-h) ^ am.sprite(spr),
                    am.translate(w,0) ^ am.sprite(spr),
                    am.translate(w,h) ^ am.sprite(spr),
                    am.translate(0,h) ^ am.sprite(spr),
                    am.translate(-w,h) ^ am.sprite(spr),
                    am.translate(-w,0) ^ am.sprite(spr) }
  for i,c in inner'group':child_pairs() do c'sprite'.color = vec4(1,1,1,0.9) end
  local wrapped = am.wrap(inner):tag('tiles')
  function wrapped:set_sprite(v) for i,c in inner'group':child_pairs() do c'sprite'.source = v end end
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
  
  ----------------------------------------------------------------------
  function flat_sprite()
    
    local tmpa = blankData(width,height)
    
    for i = 1,#pixels do
      --print('LAYER '.. i .. ' :','\n'..toSprite(pixels[i].data),'\n',pixels[i].data)
      if pixels[i].visible then
        if tmpa == nil then 
          tmpa = table.deep_copy(pixels[i].data)
        else
          for r,l in pairs(pixels[i].data) do
            for c,p in pairs(l) do
              if not(p=='.') then
                tmpa[r][c] = p 
              end
            end 
          end
        end
      end
    end
    
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
                      , tiles(width,height,flat)
                      , am.group():tag"layers"
                        --^ { am.translate(0,0):tag('l1') ^ am.group() ^ am.sprite(flat) }
                      , am.sprite('..\n..'):tag('view')
                      }
                      , Cursor:node(0,0,1,1,0.1,vec4(0.95,0.95,0.95,1)):tag('norm')
                      , am.line(vec2(0,0),vec2(0,0),0,vec4(1,1,0.5,0.7))
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
    inner"view".source = flat
    inner"tiles".sprite = flat
    win.scene'view''sprite'.source = flat
  end
  
  function wrapped:redraw()
    refresh()
  end
  ----------------------------------------------------------------------
  function trigger_tiles() inner'tiles'.trigger() end
  
  function positionFromIndex(id)
    local pox = (((id-1)%width)*scale)-((width*scale)/2)+scale/2
    local poy = ((height-math.floor((id-1)/width))*scale)-((height*scale)/2)-scale/2
--print('ROW: '..poy,'COL: '..pox)
--print('X: '..x,'Y: '..y)
    return vec2(pox,poy)
  end
  ----------------------------------------------------------------------
  function draw_lineID(from,target,col)
    from = positionFromIndex(from)
    target = positionFromIndex(target)
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
      local index = (1+ix+(width*0.5)) + (((height*0.5)-iy-1)*width)
      table.insert(ids,index)
    end
    for i,v in ipairs(ids) do 
      local r = 1+math.floor((v-1)/width)
      local c = ((v-1)%width)+1
      if r <= width and c <= height then pixels[layer].data[r][c] = col end 
    end
    refresh()
  end
  ----------------------------------------------------------------------
  function draw_line(from,target,col)
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
      local index = (1+ix+(width*0.5)) + (((height*0.5)-iy-1)*width)
      table.insert(ids,index)
    end
    for i,v in ipairs(ids) do 
      local r = 1+math.floor((v-1)/width)
      local c = ((v-1)%width)+1
      if r <= width and c <= height then pixels[layer].data[r][c] = col end 
    end
    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:get_sprite() flat_sprite() return sprite end
  ----------------------------------------------------------------------
  function wrapped:get_dummy() setDummy() return dummy end
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
    local r = math.floor((id-1)/width)
    local c = ((id-1)%width)+1
    return pixels[layer].data[r+1][c]
  end
  ----------------------------------------------------------------------
  function wrapped:set_pixel(v)
    --print('CURRENT LAYER: ',layer, #pixels)
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
    if brush[2]=='fillerase'then v='.'end
    local r = math.floor((index-1)/width)
    local c = ((index-1)%width)+1
    local old = pixels[layer].data[r+1][c]
    if brush[2]=='bycolor'then 
      pixels[layer]:fillByColor(old,v) 
      refresh()
      return
    end
    
    pixels[layer]:fill(index,v)
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
  function wrapped:rec_undo()
    if #undos == 21 then table.remove(undos) end
    if cundo > 1 then
      for i=1,cundo-1 do
        table.remove(undos,i)
      end
      cundo = 1
    end
    --table.insert(undos,1,table.deep_copy(pixels[layer].data))
  end
  ----------------------------------------------------------------------
  function wrapped:do_undo()
--    if cundo == #undos then return end
--    cundo = cundo + 1
--    pixels[layer].data = table.deep_copy(undos[cundo])
--    refresh()
  end
  ----------------------------------------------------------------------
  function wrapped:do_redo()
--    if cundo == 1 then return end
--    cundo = cundo - 1
--    pixels[layer].data = table.deep_copy(undos[cundo])
--    refresh()
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
    if y > 0 then
      local l = table.remove(pixels[layer].data,#pixels[layer].data)
      table.insert(pixels[layer].data,1,l)
    elseif y < 0 then
      local l = table.remove(pixels[layer].data,1)
      table.insert(pixels[layer].data,l)
    end
    if x > 0 then
      for i,r in ipairs(pixels[layer].data) do
        local l = table.remove(r,#r)
        table.insert(r,1,l)
      end
    elseif x < 0 then
      for i,r in ipairs(pixels[layer].data) do
        local l = table.remove(r,1)
        table.insert(r,l)
      end
    end
    refresh()
  end
  ----------------------------------------------------------------------
  function emptyDrawing()
    --wrapped:rec_undo()
    --initPixels()
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
      --inner"cursor".color = Color.over
      local ix = math.floor(mp.x/scale)
      local iy = math.floor((mp.y)/scale)
      scene.cursor = {ix*scale,iy*scale}
      index = (1+ix+(width*0.5)) + (((height*0.5)-iy-1)*width)
      --win.scene"log".text = 'x: ' + mp.x + '- y: ' + mp.y 
      
      inner"line".thickness = 0
      
      if Cuts:down('colorpicker') then
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
      elseif win:key_down('lshift') then
        if brush[1] == 'pencil' or
           brush[1] == 'brush' or
           brush[1] == 'eraser' then
          --if win:key_pressed('lshift') and last_id == 0 then last_id = 1 end
            params.line = true
            inner"line".thickness = 3--scale/2
            
            inner"line".point1 = positionFromIndex(last_id)
            
            inner"line".point2 = vec2(mp.x-(mp.x%scale),mp.y-(mp.y%scale)) + scale/2 --mp
          if win:mouse_released('left') then
            local c = (brush[1]=='eraser') and '.' or Sprites.selected[1]
            --draw_line(last_id,mp,c)
            draw_lineID(last_id,index,c)
          end
          if win:mouse_released('right') then
            local c = (brush[1]=='eraser') and '.' or Sprites.selected[1]
            --draw_line(last_id,mp,c)
            draw_lineID(last_id,index,c)
          end
        --elseif brush[1] == 'bucket' then
        
        end
      else 
        if brush[1] == 'pencil' then
          if mouse.left then --win:mouse_pressed("left") then
            scene.pixel = Sprites.selected[1]
          elseif mouse.right then --win:mouse_pressed("right") then
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
      end
    
    else
      
    end
    if win:mouse_released('left') or
       win:mouse_released('right') then
      mouse.left,mouse.right = false,false
      --scene.rec_undo()
    end
    if dragging then
      scene.x = scene.x + win:mouse_pixel_delta().x
      scene.y = scene.y + win:mouse_pixel_delta().y
    end
    if Cuts:active('centerview') and
       not win:mouse_down('middle') then
       scene.x, scene.y,scene.scale = 0,0,math.floor((360)/h)
    elseif Cuts:active('swapcolor') then
       Sprites.selected[1],Sprites.selected[2] = 
       Sprites.selected[2],Sprites.selected[1]
      win.scene"colors""selected1".color = am.ascii_color_map[Sprites.selected[1]]
      win.scene"colors""selected2".color = am.ascii_color_map[Sprites.selected[2]]
    --elseif win:key_pressed('e') then
    elseif Cuts:active('eraser') then
       select_tool('eraser')
    elseif Cuts:active('pencil') then
       select_tool('pencil')
    elseif Cuts:active('bucket') then
       select_tool('bucket')
    elseif Cuts:down('move') then
        if win:key_pressed('left') then
          displace(-1,0)
          --scene.rec_undo()
        elseif win:key_pressed('right') then
          displace(1,0)
          --scene.rec_undo()
        elseif win:key_pressed('up') then
          displace(0,-1)
          --scene.rec_undo()
        elseif win:key_pressed('down') then
          displace(0,1)
          --scene.rec_undo()
        end
    elseif Cuts:active('viewer') then
        viewer.trigger()
    elseif Cuts:active('tiles') then
        trigger_tiles()
    else
--      if win:key_pressed('l') then
--        addLayer()
--      elseif win:key_pressed('k') then
--        removeLayer()
--      end
      if Cuts:active('undo') then
      --if lctrl and win:key_pressed('left') then
        --scene.do_undo()
      elseif Cuts:active('redo') then
        --scene.do_redo()
      elseif Cuts:active('save') then
        menu:autoSave(scene.name)
      elseif Cuts:active('saveas') then
        menu:saveAs(scene.name)
      elseif Cuts:active('export') then
        menu:autoPng(scene.name)
      elseif Cuts:active('exportas') then
        menu:pngAs(scene.name)
      elseif Cuts:active('deleteall') then
        emptyDrawing()
      end
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