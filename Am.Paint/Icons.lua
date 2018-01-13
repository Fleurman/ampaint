icons = ...

icons.sels = {}

function init_tools()
  select_spec('norm','sbucket')
  select_spec('norm','seraser')
  select_spec('norm','spencil')
  select_tool('pencil')
end

function select_tool(v)
  win.scene"canvas".brush = v
  if icons.sels['s' ..v] then select_spec(icons.sels['s' ..v],'s' ..v) end
  for i,child in win.scene'icons':child_pairs() do
    child'icon'.state = false
  end
  win.scene'icons':all(v)[1]'icon'.state = true
  
  for i,child in win.scene'specs':child_pairs() do
    child'group'.hidden = true
  end
  win.scene'specs':all('s' ..v)[1]'group'.hidden = false
end

function select_spec(s,n)
  icons.sels[n] = s
  win.scene"canvas".spec = s
  for i,child in win.scene(n):child_pairs() do
    child'icon'.state = false
  end
  win.scene(n)(s)'icon'.state = true
end

function icons.node()
  local x,y = win.right-20, win.top-40
  local nod = am.group()^{am.group():tag"icons",am.group():tag"specs"}
  
  function ico(name,lx,ly,col,spec)
    return am.group():tag(name)
           ^ { am.translate(lx,ly)
                ^ am.rect(-15,-15,15,15,Color.white)
                ,GUI.icon(win,
                          lx,ly,26,26,
                          col,
                          Sprites[name],
                          function()
                            if win.scene"canvas" then
                              select_tool(name)
                            end
                          end,spec)
              }
  end
  -- DO GUI.Icon 'spec' objects (array)
  function spe(s,name,lx,ly,col)
    return am.group():tag(s)
           ^ { am.translate(lx,ly)
                ^ am.rect(-9,-9,9,9,Color.white)
                ,GUI.icon(win,
                          lx,ly,16,16,
                          col,
                          Sprites[s],
                          function()
                            if win.scene"canvas" then
                              select_spec(s,name)
                            end
                          end)
              }
  end
  
  local gp = am.group():tag('spencil')
  local list = {'norm','size2','size3'}
  for i=1,3 do
    gp:append(spe(list[i],'spencil',x-7-(i*24),y,vec4(0.9,0.8,0.5,1)))
  end
  gp.hidden = true
  nod'specs':append(gp)
  nod'icons':append(ico('pencil',x,y,vec4(0.8,0.9,0.7,1)))
  
  local ge = am.group():tag('seraser')
  for i=1,3 do
    ge:append(spe(list[i],'seraser',x-7-(i*24),y-35,vec4(0.9,0.8,0.5,1)))
  end
  ge.hidden = true
  nod'specs':append(ge)
  nod'icons':append(ico('eraser',x,y-35,vec4(0.8,0.9,0.7,1)))
  
  local gb = am.group():tag('sbucket')
  list = {'norm','fillerase','bycolor'}
  for i=1,3 do
    gb:append(spe(list[i],'sbucket',x-7-(i*24),y-70,vec4(0.9,0.8,0.5,1)))
  end
  gb.hidden = true
  nod'specs':append(gb)
  nod'icons':append(ico('bucket',x,y-70,vec4(0.8,0.9,0.7,1)))
  
  return nod
end
