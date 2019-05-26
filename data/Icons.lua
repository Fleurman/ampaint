icons = ...

icons.sels = {}

function init_tools()
  select_spec('square','sform')
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
  if s == 'norm' then s = 'normal' end
  icons.sels[n] = s
  win.scene"canvas".spec = s
  for i,child in win.scene(n):child_pairs() do
    child'imgbutton'.state = false
  end
  win.scene(n)(s)'imgbutton'.state = true
end

function icons.node()
  local x,y = win.right-20, win.top-40
  local nod = am.group()^{am.group():tag"icons",am.group():tag"specs"}
  
  function ico(name,spr,lx,ly,col,spec)
    return am.group():tag(name)
           ^ { GUI.icon(lx,ly,26,26,
                          col,
                          spr,
                          function()
                            if win.scene"canvas" then
                              select_tool(name)
                            end
                          end,spec)
              }
  end
  function spe(spr,s,name,lx,ly,col)
    return am.translate(0,0):tag(s)^GUI.imgbutton(lx,ly,
                        {normal=Src.buttons.small.normal,
                         hover=Src.buttons.small.hover,
                         active=Src.buttons.small.active},
                        spr,
                        function()
                          if win.scene"canvas" then
                            select_spec(s,name)
                          end
                        end,'specs')
  end
  
  local gp = am.group():tag('spencil')
  local list = {'normal','size2','size3'}
  for i=1,3 do
    gp:append(spe(Src.specs[list[i]],list[i],'spencil',x-7-(i*24),y,vec4(0.9,0.8,0.5,1)))
  end
  nod'specs':append(gp)
  nod'icons':append(ico('pencil',Src.tools.pencil,x,y,vec4(0.8,0.9,0.7,1)))
  gp.hidden = true
  
  local ge = am.group():tag('seraser')
  for i=1,3 do
    ge:append(spe(Src.specs[list[i]],list[i],'seraser',x-7-(i*24),y-35,vec4(0.9,0.8,0.5,1)))
  end
  nod'specs':append(ge)
  nod'icons':append(ico('eraser',Src.tools.eraser,x,y-35,vec4(0.8,0.9,0.7,1)))
  ge.hidden = true
  
  local gb = am.group():tag('sbucket')
  list = {'normal','fillerase','bycolor'}
  for i=1,3 do
    gb:append(spe(Src.specs[list[i]],list[i],'sbucket',x-7-(i*24),y-70,vec4(0.9,0.8,0.5,1)))
  end
  nod'specs':append(gb)
  nod'icons':append(ico('bucket',Src.tools.bucket,x,y-70,vec4(0.8,0.9,0.7,1)))
  gb.hidden = true
  
  local gb = am.group():tag('sform')
  list = {'square','squarefull','circle','circlefull'}
  for i=1,4 do
    gb:append(spe(Src.specs[list[i]],list[i],'sform',x-7-(i*24),y-105,vec4(0.9,0.8,0.5,1)))
  end
  nod'specs':append(gb)
  nod'icons':append(ico('form',Src.tools.form,x,y-105,vec4(0.8,0.9,0.7,1)))
  gb.hidden = true
  
  
  
  return nod
end