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
      --print('LAYER '.. i .. ' :','\n'..toSprite(pixels[i].data),'\n',pixels[i].data)
      if pixels[i].visible then
        
        for d = 1,(width*height) do
            local char = string.char(pixels[i].data[d])
            --tmpa[d] = char
            local vc = ((d-1)*4)+1
            --print( vc )
            if(am.ascii_color_map[char]) then
              local dat = am.ascii_color_map[char] or vec4(0)
              dat = dat*255
  --            local oldvec = vec4(view[vc],view[vc+1],view[vc+2],view[vc+3])
  --            local newvec = oldvec+(dat*pixels[i].opacity)
  --            view:set({newvec.r,newvec.g,newvec.b,newvec.a},vc,4)

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
                      --, am.sprite('..\n..'):tag('view')
                      , dsprite
                      }
                      , Cursor:node(0,0,1,1,0.1,vec4(0.95,0.95,0.95,1)):tag('norm')
                      , am.line(vec2(0,0),vec2(0,0),0,vec4(1,1,0.5,0.7))
                      , am.square(0,0,0,0,scale-6,vec4(1,1,0.5,0.7),false):tag('form')
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
    --inner"view".source = flat
    --inner"tiles".sprite = flat
    --win.scene'view''sprite'.source = flat
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
        if v > 0 and v <= (width*height) then
        pixels[layer].data[v] = string.byte(col) 
      end
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
    --local old = pixels[layer].data[r+1][c]
    local old = string.char(pixels[layer].data[index])
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
    
    local data = table.group(table.fromView(pixels[layer].data),width)
    
    if y > 0 then
      local l = table.remove(data,#data)
      table.insert(data,1,l)
    elseif y < 0 then
      local l = table.remove(data,1)
      table.insert(data,l)
    end
    if x > 0 then
      for i,r in ipairs(data) do
        local l = table.remove(r,#r)
        table.insert(r,1,l)
      end
    elseif x < 0 then
      for i,r in ipairs(data) do
        local l = table.remove(r,1)
        table.insert(r,l)
      end
    end
    pixels[layer].data:set(table.iflatten(data))
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
      inner"form".thickness = 0
          
      -- FORM MODE ================================================
      if brush[1] == 'form' then
        if mouse.left or mouse.right then
          if win:mouse_pressed("left") or win:mouse_pressed("right") then last_id = index end
          inner"form".point1 = positionFromIndex(last_id)
          
          local nvec = inner"form".point1 - positionFromIndex(index)
          if win:key_down('lshift') then
            local inv = math.abs(nvec.x)*math.value(nvec.y)
            nvec = vec2(nvec.x,inv)
          end
          
          inner"form".point2 = nvec*-1
          inner"form".thickness = math.max(1,scale/2)
          
        end
        if win:mouse_released('left') then
          local c = Sprites.selected[1]
          local target = index
          if win:key_down('lshift') then
            
          end
          if brush[2]=='squarefull' then
            pixels[layer]:drawFullSquare(last_id,target,c)
          else
            pixels[layer]:drawLineSquare(last_id,target,c)
          end
          refresh()
        end
        if win:mouse_released('right') then
          local c = Sprites.selected[2]
          if brush[2]=='squarefull' then
            pixels[layer]:drawFullSquare(last_id,index,c)
          else
            pixels[layer]:drawLineSquare(last_id,index,c)
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
            print('pick')
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
            local c = (brush[1]=='eraser') and '.' or Sprites.selected[2]
            --draw_line(last_id,mp,c)
            draw_lineID(last_id,index,c)
          end
        --elseif brush[1] == 'bucket' then
        
        end
      else 
      -- NORMAL MODE ================================================
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