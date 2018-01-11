icons = ...

function select_tool(v)
  win.scene"canvas".brush = v
  for i,child in win.scene'icons':child_pairs() do
    child'icon'.state = false
  end
  win.scene'icons':all(v)[1]'icon'.state = true
end

-- Select & Memorise spec in GUI.Icon
function select_spec(s)
  win.scene"canvas".spec = s
  win.scene'icons':all(v)[1]'icon'.spec = s
end

function icons.node()
  local x,y = win.right-20, win.top-40
  local nod = am.group():tag"icons"
  
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
  function spe(spr,name,lx,ly,col)
    return am.group():tag(name)
           ^ { am.translate(lx,ly)
                ^ am.rect(-9,-9,9,9,Color.white)
                ,GUI.icon(win,
                          lx,ly,16,16,
                          col,
                          Sprites[spr],
                          function()
                            if win.scene"canvas" then
                              select_spec(name)
                            end
                          end)
              }
  end
  
--  local gp = am.group():tag('specs')
--  local list = {'size1','size2','size3'}
--  for i=1,3 do
--    gp:append(spe(list[i],list[i],-7-(i*24),0,vec4(0.9,0.8,0.5,1)))
--  end
--  gp.hidden = true
  nod'icons':append(ico('pencil',x,y,vec4(0.8,0.9,0.7,1)))
  
--  local ge = am.group():tag('specs')
--  --list = {'size1','size2','size3'}
--  for i=1,3 do
--    ge:append(spe(list[i],list[i],-7-(i*24),0,vec4(0.9,0.8,0.5,1)))
--  end
--  ge.hidden = true
  nod'icons':append(ico('eraser',x,y-35,vec4(0.8,0.9,0.7,1)))
  
--  local gb = am.group():tag('specs')
--  list = {'size1','size2','size3'}
--  for i=1,3 do
--    gb:append(spe(list[i],list[i],-7-(i*24),0,vec4(0.9,0.8,0.5,1)))
--  end
--  gb.hidden = true
  nod'icons':append(ico('bucket',x,y-70,vec4(0.8,0.9,0.7,1)))
  
  return nod
end