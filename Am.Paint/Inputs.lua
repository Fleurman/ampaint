inputs = ...

function inputs.name(x,y,fn)
  local text = #win.scene'canvas'.name > 0 and win.scene'canvas'.name or ''
  local def = #win.scene'canvas'.name > 0 and '' or 'name'
  local nod = am.group():tag'name'
              ^ am.translate(0,0)
                ^ {am.rect(x,y-15,x+131,y-62,vec4(0.8,0.8,0.8,1))
                  ,am.rect(x+2,y-17,x+129,y-43,Color.white)
                  ,am.translate(x+5,y-30)
                    ^ am.text(text,vec4(0.3,0.3,0.3,1),'left')
                  , am.translate(x+5,y-30):tag('cursor') ^ am.rect(0,10,2,-10,vec4(0,0,0,1))
                  ,am.translate(x+7,y-30):tag'blank'
                    ^ am.text(def,vec4(0.8,0.8,0.8,1),'left')
                  ,GUI.sys_button(win,x+34,y-52,61,13,
                    vec4(0.4,0.9,0.4,1),'ok',
                    function() 
                      if string.len(text) > 0 then 
                        fn(text)
                        onSys = false
                        win.scene:remove('name')
                      end
                    end)
                  ,GUI.sys_button(win,x+99,y-52,61,13,
                    vec4(0.9,0.3,0.2,1),'cancel',
                    function()
                      onSys = false
                      win.scene:remove('name')
                    end)
                  }
  nod'cursor''rect':action(coroutine.create(function(node)
      while true do
        node.color = node.color.r == 0 and vec4(0.5,0.5,0.5,1) or vec4(0,0,0,1)
        --node.x2 = node.x2 == 1 and 2 or 1
        am.wait(am.delay(0.3))
      end
  end))
  nod:action(coroutine.create(function(scene)
      onSys = true
      while true do
        local touches = win:keys_down()
        for i,v in ipairs(touches) do
          if win:key_pressed(v) then
            if v == 'backspace' and
               string.len(text) > 0 then
              text = string.sub(text,1,string.len(text)-1)
            elseif v == 'space' and
                   string.len(text) < 13 then
              text = text .. ' '
            elseif string.len(v) < 2 and
                   string.len(text) < 13 then
                scene'blank'.hidden = true
                text = text .. v
            end
          end
        end
        am.wait(am.delay(0.01))
        scene'text'.text = text
        scene'cursor'.x = (x+5)+(9*#text)
      end
    end))
  
  return nod
end

function inputs.dimensions(x,y)
  local texts = {'16','16'}
  local sel = 'x'
  local dim = {}
  
  local function scan()
    dim = {}
    for k,n in ipairs(texts) do
      local nb = tonumber(n)
      if nb > 0 and nb%2 == 0 then
        table.insert(dim,nb)
      end
    end
    if #dim == 2 then return true end
  end
  
  local nod = am.group():tag'dimensions'
              ^ am.translate(0,0)
                ^ {am.rect(x,y-15,x+131,y-62,vec4(0.8,0.8,0.8,1))
                  ,am.rect(x+2,y-17,x+56,y-43,Color.white):tag('rx')
                  ,am.rect(x+75,y-17,x+129,y-43,Color.white):tag('ry')
                  ,am.translate(x+61,y-30)
                    ^ am.text('x',vec4(0.3,0.3,0.3,1),'left')
                  ,am.translate(x+5,y-30)
                    ^ am.text(texts[1],vec4(0.3,0.3,0.3,1),'left'):tag('x')
                  ,am.translate(x+77,y-30)
                    ^ am.text(texts[2],vec4(0.3,0.3,0.3,1),'left'):tag('y')
                  , am.translate(x+5,y-30):tag('cursor') ^ am.rect(0,10,2,-10,vec4(0,0,0,1))
                  ,GUI.sys_button(win,x+34,y-52,61,13,
                    vec4(0.4,0.9,0.4,1),'ok',
                    function() 
                      if #texts[1] > 0 and #texts[2] > 0 and
                         scan() then 
                        if not win.scene'canvas' then
                          win.scene'create'.hidden = true
                          win.scene"here":append(Canvas.new(dim[1],dim[2]))
                          win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
                          select_tool('pencil')
                        else
                          win.scene'create'.hidden = true
                          win.scene'here':remove('canvas')
                          win.scene"here":append(Canvas.new(dim[1],dim[2]))
                          win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
                          select_tool('pencil')
                        end
                        onSys = false
                        win.scene:remove('dimensions')
                      end
                    end)
                  ,GUI.sys_button(win,x+99,y-52,61,13,
                    vec4(0.9,0.3,0.2,1),'cancel',
                    function()
                      onSys = false
                      win.scene:remove('dimensions')
                    end)
                  }
  
  local function rect(v) if v == 0 then 
    return vec4(x+2,x+56,y-43,y-17) elseif v == 1 then
    return vec4(x+75,x+129,y-43,y-17) end end
  
  nod'cursor''rect':action(coroutine.create(function(node)
      while true do
        node.color = node.color.r == 0 and vec4(0.5,0.5,0.5,1) or vec4(0,0,0,1)
        --node.x2 = node.x2 == 1 and 2 or 1
        am.wait(am.delay(0.3))
      end
  end))
  nod:action(coroutine.create(function(scene)
      onSys = true
      
      while true do
        
        local trigger = win:mouse_pressed("left")
        
        if win:mouse_down("left") and trigger then
          if math.within(rect(1),win:mouse_position()) == true then
            sel = 'y'
            --text = texts[2]
          elseif math.within(rect(0),win:mouse_position()) == true then
            sel = 'x'
            --text = texts[1]
          end
        end
        local text = sel == 'x' and texts[1] or texts[2]
        
        
        local touches = win:keys_down()
        for i,v in ipairs(touches) do
          if win:key_pressed(v) then
            if v == 'backspace' and
               #text > 0 then
              text = string.sub(text,1,string.len(text)-1)
            --[[elseif v == 'x' and
                   string.len(text) < 7 and
                   string.len(text) > 0 then
              text = text .. 'x']]
            elseif (v == '0' or v == '1' or v == '2' or
                   v == '3' or v == '4' or v == '5' or
                   v == '6' or v == '7' or v == '8' or 
                   v == '9') and #text < 3 then
                --scene'blank'.hidden = true
                text = text .. v
            end
          end
        end
        am.wait(am.delay(0.01))
        if sel=='x' then 
          scene'x'.text = text 
          texts[1] = text
        else 
          scene'y'.text = text 
          texts[2] = text
        end
        local xoff = sel == 'x' and 5 or 77
        scene'cursor'.x = (x+xoff)+(9*#text)
      end
    end))
  
  return nod
end

function inputs.choice(x,y,texts,fn)
  local limit = 15
  local item = 150
  local size = #texts
  local height = size > limit and 40+(32*limit) or 40+size*32
  local col = size > limit and math.floor(size/limit)+1 or 1
  
  local nod = am.group():tag'choice'
              ^ {am.rect(x,y-15,x+(col*item),y-height,vec4(0.8,0.8,0.8,1))}
  
  for i=1,size do
    local curcol = math.floor((i-1)/limit)
    local bx = (x + item*0.5 + (item*curcol))
    local by = y-32-(((i-1)%limit)*32)
    local ratio = ((i-1)%limit)/limit
    nod'choice':append(
      GUI.sys_button(win,bx,by,item-10,26,
                      --vec4(0.8,0.8,0.5,1), texts[i],
                      vec4(1-ratio,0.8,ratio,1), texts[i],
                      function()
                          fn(texts[i])
                          onSys = false
                          win.scene:remove('choice')
                      end)
    )
  end
  local clw = item*col
  nod'choice':append(GUI.sys_button(win,x+clw*0.5,y+15-height,clw-10,13,
                            vec4(0.9,0.3,0.2,1),'close',
                            function()
                              onSys = false
                              win.scene:remove('choice')
                            end)
  )
  
  onSys = true
  
  return nod
end