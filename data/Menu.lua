menu = ...

--[[

V 08.5

SAVE:
  [X] transform OLayers into tables
  [X] save Palette

LOAD:
  [X] transform tables into OLayers
  [X] retrocomptability

-----------------------------------------------
V 09

EXPORT:
  [ ] .txt 'with layers' options

IMPORT:
  [ ] import .txt
  [ ] import .png (choose Palette)

() Rename projects ?

]]


--[[------------------------------------------------------------------------------
                                **SAVE A PROJECT**
----------------------------------------------------------------------------------]]
function save_proj(name)
  win.scene:append( GUI.log('Saved as \'' .. name .. '.ampt\'') )
  local t = {}
  t.version = VERSION
  t.name = name
  win.scene"canvas".name = name
  local pixels = win.scene"canvas".pixels
  
  t.table = {}
  for i=1,#pixels do
    table.insert(t.table,pixels[i]:toTable())
  end
  t.undos = win.scene'canvas'.undos
  t.layer = win.scene'canvas'.layer
  local v = win.scene"canvas".dim
  t.dim = {x = v.x, y = v.y}
  t.colors = Sprites.selected
  t.layerOpen = Layers.opened
  t.palette = Palette.file
  t.tool = win.scene"canvas".brush
  t.icsels = icons.sels
  local vc = win.scene'view''back'.color
  t.view = {color = {vc.r,vc.g,vc.b,vc.a},
            state = win.scene'view''box'.hidden }
  local js = am.to_json(t)
  local f = io.open('Saves/' .. name .. '.ampt','w+')
  f:write(js)
  f:close()
  local record = io.open('Saves/Files.txt','a+')
  local names = record:read '*a'
  local new = names:find(name .. "\n")
  new = names:find(name)
  if new then else 
	  record:write("\n" .. name)
  end
  record:close()
  
end

--[[------------------------------------------------------------------------------
                            **CORRECT THE FILES LIST**
----------------------------------------------------------------------------------]]
function verifyFiles()
  local record = io.open('Saves/Files.txt','r+')
  local names = record:read '*a'
  local nstr = ""
  local list = {}
  local lyns = list_to_t(names)
  for i=1,#lyns do
  --print(table.tostring(names))
--print(lyns[i])
    if list[lyns[i]] then else
      if io.open('Saves/' .. lyns[i] .. '.ampt','r') then
        nstr = nstr .. lyns[i]
        list[lyns[i]] = true
        if i<#lyns then nstr = nstr .. "\n" end
      end
    end
  end
  if not (names==nstr) then
    record:close()
    record = io.open('Saves/Files.txt','w')
    record:write(nstr)
  end
  record:close()
end
verifyFiles()

function loadOld(data)
  data.name = data.name or getName()
  win.scene'create'.hidden = true
  if win.scene'canvas' then
    win.scene'here':remove('canvas')
  end
  local LayerData = {
    visible= true,
    locked= false,
    data= Palette:transformOldNes(data.table),
    name = 'layer 1',
    level = 1,
    selected = true
    }
  local pixels = {
    [1]=OLayer:create(data.dim.x,data.dim.y,LayerData)
  }
  win.scene"here":append(Canvas.new(data.dim.x,data.dim.y,pixels))
  Layers:init({data.table})
  Sprites.selected = data.colors
  win.scene"colors""selected1".color = am.ascii_color_map[Sprites.selected[1]]
  win.scene"colors""selected2".color = am.ascii_color_map[Sprites.selected[2]]
  viewer.load(data.view.color,data.view.state)
  win.scene"canvas":redraw()
  --win.scene"canvas".undos = data.undos
  win.scene"canvas".name = data.name .. '_new'
  win.scene"canvas".brush = data.tool
  data.icsels = data.icsels or {}
  data.icsels.spencil = data.icsels.spencil or "normal"
  data.icsels.seraser = data.icsels.seraser or "normal"
  data.icsels.sbucket = data.icsels.sbucket or "normal"
  if data.icsels then icons.sels = data.icsels end
  local tool = type(data.tool[1]) == "table" and data.tool[1][1] or data.tool[1]
  select_tool(tool)
  win.scene:append( GUI.log('Loaded \'' .. data.name .. '.ampt\' in compatibility mode') )
  --menu:autoSave(data.name..'_new')
end

--[[------------------------------------------------------------------------------
                                **LOAD A PROJECT**
----------------------------------------------------------------------------------]]
function load_proj(name)
  local f = io.open('Saves/' .. name .. '.ampt','r')
  if f == nil then return end
  local raw = f:read '*a'
  f:close()
  local data = am.parse_json(raw)
  
  if isOld(data.version,VERSION) then
    data.name = data.name or name
    loadOld(data)
  else
    win.scene'create'.hidden = true
    if win.scene'canvas' then
      win.scene'here':remove('canvas')
    end
    local pixels = {}
    for i=1,#data.table do
      table.insert(pixels,OLayer:create(data.dim.x,data.dim.y,data.table[i]))
    end
    win.scene"here":append(Canvas.new(data.dim.x,data.dim.y,pixels))
    Layers:init(data.table)
    Layers:open((data.layerOpen))
    Palette:set(data.palette)
    Sprites.selected = data.colors
    win.scene"colors""selected1".color = am.ascii_color_map[Sprites.selected[1]]
    win.scene"colors""selected2".color = am.ascii_color_map[Sprites.selected[2]]
    viewer.load(data.view.color,data.view.state)
    win.scene"canvas":redraw()
    win.scene"canvas".layer = data.layer
    win.scene"canvas".undos = data.undos
    win.scene"canvas".name = name
    win.scene"canvas".brush = data.tool
    if data.icsels then icons.sels = data.icsels end
    local tool = type(data.tool[1]) == "table" and data.tool[1][1] or data.tool[1]
    select_tool(tool)
    win.scene:append( GUI.log('Loaded \'' .. name .. '.ampt\'') )
  end
end

--[[------------------------------------------------------------------------------
                                  **SAVE A TXT**
----------------------------------------------------------------------------------]]
function save_txt(name)
  win.scene"canvas".name = name
  local f = io.open('Exports/' .. name .. '.txt','w+')
  f:write(win.scene"canvas".sprite)
  f:close()
  win.scene:append( GUI.log('Exported as \'' .. name .. '.txt\'') )
end

--[[------------------------------------------------------------------------------
                                **EXPORT AS PNG**
----------------------------------------------------------------------------------]]
function export(name)
  win.scene"canvas".name = name
  local dim = win.scene"canvas".dim
  local img = am.image_buffer(dim.x,dim.y)
  local dummy = win.scene"canvas".dummy
  local spr = dummy.line .. '\n' .. win.scene"canvas".sprite
  local texture = am.sprite(spr).spec.texture
  local buff = am.framebuffer(texture)
  buff:read_back()
  local image = texture.image_buffer
  img:paste(image,1,1)
  img:save_png(ROOT..'Exports/' .. name .. '.png')
  img = nil
  win.scene:append( GUI.log('Exported as \'' .. name .. '.png\'') )
end

--[[------------------------------------------------------------------------------
                                  **MENU NODE**
----------------------------------------------------------------------------------]]
function menu.node()
  local nod = am.group():tag('menu')
              ^ {GUI.imgbutton(win.left+16,win.top-16,
                              {normal=Src.buttons.small.normal,
                               hover=Src.buttons.small.hover,
                               active=Src.buttons.small.active},
                              Src.file.new,
                              function()
                                win.scene:append(Inputs.dimensions(win.left+5,win.top-22))
                              end),
                GUI.imgbutton(win.left+41,win.top-16,
                              {normal=Src.buttons.small.normal,
                               hover=Src.buttons.small.hover,
                               active=Src.buttons.small.active},
                              Src.file.open,
                              function()
                                local files = {}
                                for line in io.lines("Saves/Files.txt") do
                                  if line then files[#files + 1] = line end
                                end
                                win.scene:append( Inputs.choice(
                                  win.left+30,win.top-20,files,load_proj) )
                              end),
                GUI.imgbutton(win.left+66,win.top-16,
                              {normal=Src.buttons.small.normal,
                               hover=Src.buttons.small.hover,
                               active=Src.buttons.small.active},
                              Src.file.save,
                              function()
                                if win.scene'canvas' then
                                  win.scene:append(
                                    Inputs.name(win.left+55,win.top-22,save_proj)
                                  )
                                end
                              end),
                GUI.imgbutton(win.left+91,win.top-16,
                              {normal=Src.buttons.small.normal,
                               hover=Src.buttons.small.hover,
                               active=Src.buttons.small.active},
                              Src.export,
                              function()
                                if win.scene'canvas' then
                                  win.scene:append(
                                    Inputs.name(win.left+80,win.top-22,export)
                                  )
                                end
                              end),
                GUI.imgbutton(win.left+116,win.top-16,
                              {normal=Src.buttons.small.normal,
                               hover=Src.buttons.small.hover,
                               active=Src.buttons.small.active},
                              Src.txt,
                              function()
                                if win.scene'canvas' then
                                  win.scene:append( Inputs.name(
                                      win.left+105,win.top-22,save_txt) )
                                end
                              end)
                            }

  nod:action(function()
      if not win.scene'canvas' then
        if nod:all('imgbutton')[3].active then
          nod:all('imgbutton')[3].active = false
          nod:all('imgbutton')[4].active = false
          nod:all('imgbutton')[5].active = false
        end
      else
        if not nod:all('imgbutton')[3].active then
          nod:all('imgbutton')[3].active = true
          nod:all('imgbutton')[4].active = true
          nod:all('imgbutton')[5].active = true
        end
      end
  end)
  return nod
end

--[[------------------------------------------------------------------------------
                            **CREATE A UNIQUE NAME**
----------------------------------------------------------------------------------]]
function getName() return tostring(os.date("%m%d%y-%H%M%S")) end

--[[------------------------------------------------------------------------------
                              **AUTO SAVE/EXPORT**
----------------------------------------------------------------------------------]]
function menu:autoSave(name)
  local n = #name > 0 and name or getName()
  save_proj(n)
end
function menu:saveAs(name)
  win.scene:append(
    Inputs.name(win.left+55,win.top-22,save_proj)
  )
end
function menu:autoPng(name)
  local n = #name > 0 and name or getName()
  export(n)
end
function menu:pngAs(name)
  win.scene:append(
    Inputs.name(win.left+80,win.top-22,export)
  )
end