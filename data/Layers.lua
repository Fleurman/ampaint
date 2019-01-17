Layers = ...

Layers.count = 1
Layers.selected = 1
Layers.bank = am.group():tag('layers')
Layers.actif = nil
Layers.opened = false

local function layerNode(i,args)
  local object = {}
  local visible = true
  if args and args.visible == false then visible = false end
  local locked = args and args.locked or false
  local selected = args and args.selected or false
  local name = args and args.name or 'layer '..Layers.count
  local id = i
  --print('NEW LAYER: ',i)
  local node = am.group() ^ {
                  am.read_uniform('MV'):tag('read'),
                  am.translate(8,-16)^am.group()^{
                    am.translate(-20,0)^am.text(name,Color.black,'left')
                  }
                }
  local frame = am.rect(-92,-34,72,2,vec4(0.2,0.2,0.2,1))
  frame.hidden = true
  local wrapped = am.wrap(node):tag('layer')
  wrapped:append(frame)
  wrapped:append(am.rect(-90,-32,70,0,vec4(0.8,0.8,0.8,1)):tag('back'))
  
  function triggerShow(n,id,v)
    bt = n'show'
    n.visible = v or (not n.visible)
    win.scene'canvas'.datas()[id].visible = n.visible
    win.scene'canvas'.redraw()
    if n.visible then
      bt.icon = Src.layers.visible.on
    else
      bt.icon = Src.layers.visible.off
    end
  end
  function triggerLock(n,id,v)
    bt = n'lock'
    n.locked = v or (not n.locked)
    win.scene'canvas'.datas()[id].locked = n.locked
    win.scene'canvas'.redraw()
    if n.locked then
      bt.icon = Src.layers.locked.on
    else
      bt.icon = Src.layers.locked.off
    end
  end
  
  local btshow = GUI.imgbutton( -80,0,
                  Src.smallButton(),
                  Src.layers.visible.on,
                  function() triggerShow(wrapped,id) end):tag("show")
  if not visible then btshow.icon = Src.layers.visible.off end
  local btlock = GUI.imgbutton(-50,0,
                  Src.smallButton(),
                  Src.layers.locked.off,
                  function() triggerLock(wrapped,id) end):tag("lock")
  wrapped:append(am.translate(8,-16)^am.group()^{btshow,btlock})
  if locked then btlock.icon = Src.layers.locked.on end
  
  function wrapped:set_id(v)
    id = v
  end
  function wrapped:get_id()
    return id
  end
  function wrapped:get_selected()
    return selected
  end
  function wrapped:set_selected(v)
    selected = v
    frame.hidden = (not v)
  end
  function wrapped:set_visible(v)
    visible = v
  end
  function wrapped:get_visible()
    return visible
  end
  function wrapped:set_name(v)
    name = v
    node'text'.text = v
  end
  function wrapped:get_name()
    return name
  end
  function wrapped.rename(n)
    wrapped:set_name(n)
    win.scene'canvas'.datas()[id].name = n
  end
  wrapped:action(function(nod)
    if onAct or onSys then return end
    local mouse_pos = win:mouse_position()
    local mv = node'read'.value[4]
    if math.within(vec4(mv.x-90,mv.y-32,mv.x+70,mv.y+0),mouse_pos) then
      node'back'.color = vec4(0.7,0.7,0.7,1)
      onGui = true
      if win:mouse_pressed"left" and
      math.within(vec4(mv.x-25,mv.y-32,mv.x+70,mv.y+0),mouse_pos) then
        Layers:selectLayer(id)
--        nod.selected = true
--        Layers.actif = nod
        --wrapped:set_selected(true)
      elseif win:mouse_pressed"right" and
      math.within(vec4(mv.x-25,mv.y-32,mv.x+70,mv.y+0),mouse_pos) then
          local pos = vec2(mv.x-60,mv.y+10)
          local args = {
            placeholder = 'name',
            default = name or ''
          }
          win.scene:append(Inputs.name(pos,args,nod.rename))
      end
    else
      node'back'.color = vec4(0.8,0.8,0.8,1)
    end
  end)
  return wrapped
end

function Layers:selectLayer(id)
  Layers.selected = id
  for i,c in Layers.bank:child_pairs() do
    if i == id then
      c'layer'.selected = true
      Layers.actif = c'layer'
    else
      c'layer'.selected = false
    end
  end
  if win.scene'canvas' then win.scene'canvas'.layer = id end
  --print("Selected : "..Layers.selected)
end
function Layers:selectUpperLayer()
  local id = math.max(1,Layers.selected-1)
  Layers:selectLayer(id)
end
function Layers:selectBottomLayer()
  local id = math.min(Layers.selected+1,Layers.bank.num_children)
  Layers:selectLayer(id)
end

function Layers:addLayer()
  local i = Layers.bank.num_children
  local y = i*-40
  Layers.bank:append(am.translate(0,y+260)^layerNode(i+1))
  Layers.count = Layers.count + 1
  Layers:selectLayer(i+1)
end

function Layers:refresh()
  for i,c in Layers.bank:child_pairs() do
    c'layer'.id = i
    c.y = 300+(i*-40)
  end
end

function Layers:removeLayer(id)
  local node = nil
  for i,c in Layers.bank:child_pairs() do
    if c'layer'.id == id then node = c end
  end
  Layers.bank:remove(node)
  Layers:selectLayer( (id>1) and (id-1) or 1 )
  Layers:refresh()
end

function Layers:reset()
  
  Layers.count = 1
  Layers.bank:remove_all()
  Layers.selected = 1
  
end
function Layers:init(data)
  
  Layers.count = #data
  Layers.bank:remove_all()
  
  for i,t in ipairs(data) do
    local y = (i-1)*-40
    Layers.bank:append(am.translate(0,y+260)^layerNode(i,t))
    if t.selected then Layers:selectLayer(i) end
  end
  
end

function Layers:moveLayerUp()
  Layers:moveLayer(-1)
end
function Layers:moveLayerDown()
  Layers:moveLayer(1)
end
function Layers:moveLayer(d)
  local sel,target
  if d > 0 then   -- MOVE UP
    if Layers.selected == Layers.bank.num_children then return end
    
    sel = Layers.bank:child(Layers.selected)
    target = Layers.bank:child(Layers.selected+1)
    Layers.bank:replace(target,sel)
    Layers.bank:replace(sel,target)
    
    Layers.selected = Layers.selected + 1
  else            -- MOVE DOWN
    if Layers.selected == 1 then return end
    
    sel = Layers.bank:child(Layers.selected)
    target = Layers.bank:child(Layers.selected-1)
    Layers.selected = Layers.selected - 1
    Layers.bank:replace(sel,target)
    Layers.bank:replace(target,sel)
    
  end
  Layers:refresh()
end

function Layers.node(arg)
  local w,h = 200,300
  local x,y = win.right-(w/2)+200,-50
  local back = am.rect(-w/2,h/2,w/2,-h/2)
  local open = am.rect(-w/2,h/2,(-w/2)-10,-h/2,vec4(0.8,0.8,0.8,1)):tag('open')
  local scroll = am.rect((w/2)-20,h/2,w/2,-(h/2)+25,vec4(0.5,0.5,0.5,1))
  
  local function scale() return vec2(win.width/170,win.height/270) end
  local node =  am.translate(x,y):tag('layerwin')
                ^ am.group()
                ^ { back,
                  am.translate(0,-125):tag('tl'),
                  --^ am.group():tag('layers')^{ },
                  open,scroll}
  node'layerwin''tl':append(Layers.bank)
  local bt = am.translate(-40,-134)^GUI.imgbutton(1,1,Src.smallButton(),Src.arrows.up.medium,
    function()
      if win.scene'canvas' then win.scene'canvas'.moveLayerUp() end
    end)
  node:append(bt)
  bt = am.translate(-8,-134)^GUI.imgbutton(1,1,Src.smallButton(),Src.arrows.down.medium,
    function()
      if win.scene'canvas' then win.scene'canvas'.moveLayerDown() end
    end)
  node:append(bt)
  bt = am.translate(24,-134)^GUI.imgbutton(1,1,Src.smallButton(),Src.layers.new,
    function()
      if win.scene'canvas' then win.scene'canvas'.addLayer() end
    end)
  node:append(bt)
  bt = am.translate(56,-134)^GUI.imgbutton(1,1,Src.smallButton(),Src.dustbin.delete,
    function()
      if win.scene'canvas' then win.scene'canvas'.removeLayer() end
    end)
  node:append(bt)
  
  function Layers:open(v)
    local op = win.right-(w/2)
    if v then
      Layers.opened = true
      node.x = op+20
    else
      Layers.opened = false
      node.x = op+200 
    end
  end
  
  node:action(function(nod)
    local w,h = 200,300
    local r = vec4(nod.x-(w/2)-10,y-(h/2),nod.x-(w/2),y+(h/2))
    local mp = win:mouse_pixel_position() + vec2(win.left,win.bottom)
    
    if math.within(r,mp) then
      nod'open'.color = vec4(1,0.8,0.7,1)
      if win:mouse_pressed('left') then
        local op = win.right-(w/2)
        if nod.x == op+20 then 
          Layers:open(false)
        else
          Layers:open(true)
        end
      end
    else
      nod'open'.color = vec4(0.8,0.8,0.8,1)
    end
  end)

  return node
end