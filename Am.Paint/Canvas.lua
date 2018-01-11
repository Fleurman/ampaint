local canvas = ...

function canvas.new(w,h)
  local width = w
  local height = h
  local scale = math.floor(360/h)
  local x,y = 0,0
  local brush = {'pencil',''}
  local name = ""
  local params = {line = false,
                  dither = false,
                  bycolor = false}
  local dragging = false
  local index = 1
  local last_id = 1
  local pixels = {}
  local undos = {}
  local cundo = 1
  local sprite = ''
  
  function initPixels()
    local row = {}
    for i=1,width do row[i] = '.' end
    for i=1,height do pixels[i] = table.shallow_copy(row) end
  end
  initPixels()
  table.insert(undos,1,table.deep_copy(pixels))
  
  function get_targets(id)
    local a = {}
    if id%width ~= 1 then table.insert(a,id-1) end
    if id%width ~= 0 then table.insert(a,id+1) end
    if id > width then table.insert(a,id-width) end
    if id < width*(height-1) then table.insert(a,id+width) end
    return a
  end
  
  function fill_pixels(id,bc,nc)
    local search = {id}
    local new_s = {}
    local procc = true
    local loops = 0
    while procc do
      procc = false
      for k,i in pairs(search) do
        local targets = get_targets(i)
        for kk,s in pairs(targets) do
          local px = get_pixel(s)
          if px == bc and px ~= nc then
            procc = true
            local r = math.floor((s-1)/width)
            local c = ((s-1)%width)+1
            pixels[r+1][c] = nc
            table.insert(new_s,s)
          end
        end
      end
      search = new_s
      loops = loops + 1
    end
  end
  
  function set_sprite()
    local nsp = ''
    for i,r in ipairs(pixels) do
      local tl = ''
      for n,l in ipairs(r) do
        tl = tl .. l
      end
      nsp = nsp .. tl
      if i < height then nsp = nsp .. '\n' end
    end
    sprite = nsp
  end
  
  set_sprite()
  
  local inner = am.translate(x,y):tag"position"
                ^ { am.scale(scale):tag"scale"
                    ^ {
                      am.sprite(Sprites:textured("void",width,height))
                      , 
                      am.group():tag"layer"
                        ^ am.translate(0,0)
                          ^ am.sprite(sprite)
                      }
                      , am.square(0,0,scale,scale,1,vec4(0.95,0.95,0.95,1))
                      , am.line(vec2(0,0),vec2(0,0),0,vec4(1,1,0.5,0.7))
                  }
  local wrapped = am.wrap(inner):tag"canvas"
  
  --[[------------------------------------------------
                        **DRAW LINE**
    ------------------------------------------------]]
  function draw_line(from,target,col)
    local v = target - from
    local ratio = vec2(
      math.floor(v.x/scale),
      math.floor(v.y/scale)
    )
    
    --print('-----------------------------------')
--    print('from: ('+from.x+','+from.y+')','to: ('+target.x+','+target.y+')')
      --print('vec: ('+v.x+','+v.y+')')
--    print('move: '.. ratio.x .. '/' .. ratio.y)
    
    local max = math.max(math.abs(math.ampl(ratio.x,1)),math.abs(math.ampl(ratio.y,1)))
    local xm,ym = v.x/max,v.y/max
    local ids = {}
    --print('step:  ('+xm+','+ym+')', 'x '+max)
    for i=0,max do
      local vx,vy = from.x+(i*xm),from.y+(i*ym)
      local ix = math.floor(vx/scale)
      local iy = math.floor(vy/scale)
      local index = (1+ix+(width*0.5)) + (((height*0.5)-iy-1)*width)
      table.insert(ids,index)
    end
    --printTable(ids)
    --print('-----------------------------------')
    --do return false end
    for i,v in ipairs(ids) do 
      local r = 1+math.floor((v-1)/width)
      local c = ((v-1)%width)+1
      if r <= width and c <= height then
        pixels[r][c] = col
      else end
    end
    set_sprite()
    inner"layer""sprite".source = sprite
    
  end
  ----------------------------------------------------------------------
  function wrapped:get_sprite()
    set_sprite()
    return sprite
  end
  function wrapped:set_scale(v)
    scale = v
    inner"scale".scale2d = vec2(v,v)
    inner"square".scale = v
  end
  function wrapped:get_scale()
    return scale --inner"scale".scale2d.x
  end
  function wrapped:set_cursor(pos)
    inner"square".x,inner"square".y = pos[1],pos[2]
  end
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    x = v
    inner"position".x = v
  end
  function wrapped:get_name()
    return name
  end
  function wrapped:set_name(v)
    name = v
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    y = v
    inner"position".y = v
  end
  function wrapped:get_rect()
    return vec4((-width*0.5)*scale,
                (-height*0.5)*scale,
                (width*0.5)*scale,
                (height*0.5)*scale)
  end
  
  function get_pixel(id)
    local r = math.floor((id-1)/width)
    local c = ((id-1)%width)+1
    return pixels[r+1][c]
  end
  
  function wrapped:set_pixel(v)
    if brush[2] == 'size2' then
      wrapped:set_big_pixel(v)
      do return end
    end
    local r = math.floor((index-1)/width)
    local c = ((index-1)%width)+1
    pixels[r+1][c] = v
    set_sprite()
    inner"layer""sprite".source = sprite
  end
  function wrapped:set_big_pixel(v)
    local r = 1+math.floor((index-1)/width)
    local c = ((index-1)%width)+1
    local points = {{r,c}}
    if r-1 > 0 then table.insert(points,{r-1,c}) end
    if r+1 < height then table.insert(points,{r+1,c}) end
    if c-1 > 0 then table.insert(points,{r,c-1}) end
    if c+1 < width then table.insert(points,{r,c+1}) end
    for i,t in ipairs(points) do
      pixels[t[1]][t[2]] = v
    end
    set_sprite()
    inner"layer""sprite".source = sprite
  end
  
  function wrapped:set_bucket(v)
    local r = math.floor((index-1)/width)
    local c = ((index-1)%width)+1
    local old = pixels[r+1][c]
    pixels[r+1][c] = v
    fill_pixels(index,old,v) 
    set_sprite()
    inner"layer""sprite".source = sprite
  end
  function wrapped:get_pixels()
    return pixels
  end
  function wrapped:set_pixels(v)
    pixels = v
    set_sprite()
    inner"layer""sprite".source = sprite
  end
  function wrapped:get_undos()
    return undos
  end
  function wrapped:set_undos(v)
    undos = v
  end
  function wrapped:get_dim()
    return vec2(width,height)
  end
  function wrapped:set_brush(v,s)
    brush[1],brush[2] = v,s
  end
  function wrapped:get_brush()
    return brush
  end
  function wrapped:set_spec(v)
    brush[2] = v
  end
  function wrapped:get_spec()
    return brush[2]
  end
  
  function wrapped:rec_undo()
    --print('undos: ' .. #undos .. ' - cundo: ' .. cundo)
    if #undos == 21 then table.remove(undos) end
    if cundo > 1 then
      for i=1,cundo-1 do
        table.remove(undos,i)
      end
      cundo = 1
    end
    table.insert(undos,1,table.deep_copy(pixels))
  end
  
  function wrapped:do_undo()
    if cundo == #undos then return end
    cundo = cundo + 1
    pixels = table.deep_copy(undos[cundo])
    set_sprite()
    inner"layer""sprite".source = sprite
  end
  function wrapped:do_redo()
    if cundo == 1 then return end
    cundo = cundo - 1
    pixels = table.deep_copy(undos[cundo])
    set_sprite()
    inner"layer""sprite".source = sprite
  end
  
  function pick_color(click)
    local p = get_pixel(index)
    if p == '.' then else
      Sprites.selected[click] = p
      win.scene("selected" .. click).color = am.ascii_color_map[p]
    end
  end
  
  function displace(x,y)
    if y > 0 then
      local l = table.remove(pixels,#pixels)
      table.insert(pixels,1,l)
    elseif y < 0 then
      local l = table.remove(pixels,1)
      table.insert(pixels,l)
    end
    if x > 0 then
      for i,r in ipairs(pixels) do
        local l = table.remove(r,#r)
        table.insert(r,1,l)
      end
    elseif x < 0 then
      for i,r in ipairs(pixels) do
        local l = table.remove(r,1)
        table.insert(r,l)
      end
    end
    set_sprite()
    inner"layer""sprite".source = sprite 
    win.scene'view''sprite'.source = sprite
  end
  
  function emptyDrawing()
    wrapped:rec_undo()
    initPixels()
    set_sprite()
    inner"layer""sprite".source = sprite
    win.scene'view''sprite'.source = sprite
  end
  
  wrapped:action(function(scene)
    if onGui or onSys then 
      inner"square".hidden = true
      onGui = false 
      return 
    end
    local r = scene.rect
    local mp = win:mouse_pixel_position() - vec2(win.width/2,win.height/2) - vec2(x,y)
    inner"square".hidden = true
    if math.within(r,mp) then
      inner"square".hidden = false
      --inner"square".color = Color.over
      local ix = math.floor(mp.x/scale)
      local iy = math.floor((mp.y)/scale)
      scene.cursor = {ix*scale,iy*scale}
      index = (1+ix+(width*0.5)) + (((height*0.5)-iy-1)*width)
      win.scene"log".text = index
      
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
          if win:key_pressed('lshift') then last_id = mp end
            params.line = true
            inner"line".thickness = 3
            inner"line".point1 = last_id
            inner"line".point2 = mp
          if win:mouse_released('left') then
            draw_line(last_id,mp,Sprites.selected[1])
          end
          if win:mouse_released('right') then
            draw_line(last_id,mp,Sprites.selected[2])
          end
        elseif brush[1] == 'bucket' then
        
        end
      elseif win:mouse_pressed('middle') then
        dragging = true
      elseif win:mouse_released('middle') then
        dragging = false
      else 
        if brush[1] == 'pencil' then
          if win:mouse_down("left") then
            scene.pixel = Sprites.selected[1]
          elseif win:mouse_down("right") then
            scene.pixel = Sprites.selected[2]
          end
        elseif brush[1] == 'brush' then
          
        elseif brush[1] == 'eraser' then
          if win:mouse_down("left") then
            scene.pixel = '.'
          elseif win:mouse_down("right") then
            scene.bucket = '.'
          end
        elseif brush[1] == 'bucket' then
          if win:mouse_down("left") then
            scene.bucket = Sprites.selected[1]
          elseif win:mouse_down("right") then
            scene.bucket = Sprites.selected[2]
          end
        end
      end
    end
    if win:mouse_released('left') or
       win:mouse_released('right') then
      win.scene'view''sprite'.source = sprite
      scene.rec_undo()
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
          scene.rec_undo()
        elseif win:key_pressed('right') then
          displace(1,0)
          scene.rec_undo()
        elseif win:key_pressed('up') then
          displace(0,-1)
          scene.rec_undo()
        elseif win:key_pressed('down') then
          displace(0,1)
          scene.rec_undo()
        end
    elseif Cuts:active('viewer') then
        viewer.trigger()
    else
      
      
      if Cuts:active('undo') then
      --if lctrl and win:key_pressed('left') then
        scene.do_undo()
      elseif Cuts:active('redo') then
        scene.do_redo()
      elseif Cuts:active('save') then
        menu:autoSave(scene.name)
      elseif Cuts:active('saveas') then
        menu:saveAs(scene.name)
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
  
  return wrapped
end