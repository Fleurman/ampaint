inputs = ...

--[[------------------------------------------------------------------------------
                                    **NAME**
----------------------------------------------------------------------------------]]
function inputs.name(x,y,fn)
  local text = #win.scene'canvas'.name > 0 and win.scene'canvas'.name or ''
  local def = #win.scene'canvas'.name > 0 and '' or 'name'
  local nod = am.group():tag'name'
              ^ am.translate(0,0)
                ^ {
                  GUI.frame(x-2,y-63,135,56)
                  ,am.rect(x+2,y-12,x+129,y-38,Color.black)
                  ,am.rect(x+3,y-13,x+128,y-37,Color.white)
                  ,am.translate(x+7,y-25)
                    ^ am.text(text,vec4(0.3,0.3,0.3,1),'left')
                  , am.translate(x+5,y-25):tag('cursor') ^ am.rect(0,8,2,-8,vec4(0,0,0,1))
                  ,am.translate(x+10,y-25):tag'blank'
                    ^ am.text(def,vec4(0.8,0.8,0.8,1),'left')
                  ,GUI.sys_button(x+34,y-50,61,13,
                    Src.flatButton(),Src.gui.confirm.small,'',
                    function() doName() end)
                  ,GUI.sys_button(x+99,y-50,61,13,
                    Src.flatButton(),Src.gui.cancel.small,'',
                    function()
                      onSys = false
                      win.scene:remove('name')
                    end)
                  }
  
  function doName()
    if string.len(text) > 0 then
      fn(text)
      onSys = false
      win.scene:remove('name')
    end
  end
  
  nod'cursor''rect':action(coroutine.create(function(node)
      while true do
        node.color = node.color.r == 0 and vec4(0.6,0.6,0.6,1) or vec4(0,0,0,1)
        am.wait(am.delay(0.3))
      end
  end))
  nod:action(coroutine.create(function(scene)
      onSys = true
      while true do
        local mouse_pos = win:mouse_position()
        local trigger = win:mouse_pressed"left"
        if trigger and not math.within(vec4(x,y-62,x+131,y-15),mouse_pos) then onSys=false win.scene:remove('name') end
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
            elseif v == 'enter' then doName() end
          end
        end
        am.wait(am.delay(0.01))
        scene'text'.text = text
        scene'cursor'.x = (x+7)+(9*#text)
      end
    end))
  onSys = true
  return nod
end

--[[------------------------------------------------------------------------------
                                  **DIMENSIONS**
----------------------------------------------------------------------------------]]
function inputs.dimensions(x,y)
  local texts = {'24','24'}
  local sel = 'x'
  local dim = {}
  
  local function scan()
    dim = {}
    for k,n in ipairs(texts) do local nb = tonumber(n) if nb > 0 and nb%2 == 0 then table.insert(dim,nb) end end
    if #dim == 2 then return true else win.scene:append( GUI.alert('Dimensions Error\nValues must be even') ) end
  end
  
  local nod = am.group():tag'dimensions'
              ^ am.translate(0,0)
                ^ {
                  GUI.frame(x-2,y-63,135,56)
                  --am.rect(x,y-15,x+131,y-62,vec4(0.8,0.8,0.8,1))
                  ,am.rect(x+2,y-10,x+56,y-38,Color.black)
                  ,am.rect(x+3,y-11,x+55,y-37,Color.white):tag('rx')
                  ,am.rect(x+74,y-10,x+129,y-38,Color.black)
                  ,am.rect(x+75,y-11,x+128,y-37,Color.white):tag('ry')
                  ,am.translate(x+61,y-25)
                    ^ am.text('x',vec4(0.3,0.3,0.3,1),'left')
                  ,am.translate(x+7,y-25)
                    ^ am.text(texts[1],vec4(0.3,0.3,0.3,1),'left'):tag('x')
                  ,am.translate(x+79,y-25)
                    ^ am.text(texts[2],vec4(0.3,0.3,0.3,1),'left'):tag('y')
                  , am.translate(x+7,y-25):tag('cursor') ^ am.rect(0,8,2,-8,vec4(0,0,0,1))
                  ,GUI.sys_button(x+34,y-50,61,13,
                    Src.flatButton(),Src.gui.confirm.small,'',
                    function() makeNew() end)
                  ,GUI.sys_button(x+99,y-50,61,13, 
                    Src.flatButton(),Src.gui.cancel.small,'',
                    function() onSys = false win.scene:remove('dimensions') end)
                  }
  
  function makeNew()
    if #texts[1]>0 and #texts[2]>0 and scan() then
      win.scene'create'.hidden = true
      if win.scene'canvas' then win.scene'here':remove('canvas') end
      Layers:reset()
      win.scene"here":append(Canvas.new(dim[1],dim[2]))
      win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
      init_tools()
      onSys = false
      win.scene:remove('dimensions')
    end
  end
  local function rect(v) if v == 0 then 
    return vec4(x+2,y-43,x+56,y-17) elseif v == 1 then return vec4(x+75,y-43,x+129,y-17) end 
  end
  
  nod'cursor''rect':action(coroutine.create(function(node)
      while true do
        node.color = node.color.r == 0 and vec4(0.6,0.6,0.6,1) or vec4(0,0,0,1)
        am.wait(am.delay(0.3))
      end
  end))
  nod:action(coroutine.create(function(scene)
      if onAlt then return end
      onSys = true
      while true do
        local trigger = win:mouse_pressed("left")
        local mouse_pos = win:mouse_position()
        if win:mouse_down("left") and trigger then
          if not math.within(vec4(x,y-62,x+131,y-15),mouse_pos) and not onAlt then onSys=false win.scene:remove('dimensions') end
          if math.within(rect(1),mouse_pos) == true then sel = 'y'
          elseif math.within(rect(0),mouse_pos) == true then sel = 'x' end
        end
        local text = sel == 'x' and texts[1] or texts[2]
        local touches = win:keys_down()
        local kp_nb = nil
        for i,v in ipairs(touches) do
          if win:key_pressed(v) then
            if v == 'backspace' and #text > 0 then
              text = string.sub(text,1,string.len(text)-1)
            elseif (v == '0' or v == '1' or v == '2' or v == '3' or v == '4' or v == '5' or
                   v == '6' or v == '7' or v == '8' or  v == '9') and #text < 3 then
                text = text .. v
            elseif string.match(v,'kp_%d') and #text < 3 then
                text = text .. string.match(v,'kp_(%d)')
            elseif v == 'enter' then
               makeNew()
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
        local xoff = sel == 'x' and 7 or 79
        scene'cursor'.x = (x+xoff)+(9*#text)
      end
    end))
  onSys = true
  return nod
end

--[[------------------------------------------------------------------------------
                                  **CHOICE**
----------------------------------------------------------------------------------]]
function inputs.choice(x,y,texts,fn,limit)
  limit = limit or 15
  local item = 150
  local size = #texts
  local col = size > limit and math.floor(size/limit)+1 or 1
  local height = size > limit and 40+(32*limit) or 40+size*32
  local width = col*item
  
  local nod = am.group():tag'choice'
              ^ {
                --am.rect(x,y-15,x+(col*item),y-height,vec4(0.8,0.8,0.8,1))
                GUI.frame(x,y-height,width,height-10)
                }
  
  nod:action(function()
    local mp = win:mouse_position()
    local t = win:mouse_pressed"left"
    if t and not math.within(vec4(x,y-height,x+(col*item),y-15),mp) then onSys=false win.scene:remove('choice') end
  end)
  
  for i=1,size do
    local curcol = math.floor((i-1)/limit)
    local bx = (x + item*0.5 + (item*curcol))
    local by = y-32-(((i-1)%limit)*32)
    local ratio = ((i-1)%limit)/limit
    nod'choice':append(
      GUI.sys_button(bx,by,item-10,26,
                      vec4(1-ratio,0.8,ratio,1),nil, texts[i],
                      function()
                          fn(texts[i])
                          onSys = false
                          win.scene:remove('choice')
                      end)
    )
  end
  local clw = item*col
  nod'choice':append(GUI.sys_button(x+clw*0.5,y+15-height,clw-10,13,
                            vec4(0.9,0.3,0.2,1),nil,'close',
                            function()
                              onSys = false
                              win.scene:remove('choice')
                            end)
  )
  
  onSys = true
  
  return nod
end