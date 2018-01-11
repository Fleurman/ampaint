menu = ...

function save_proj(name)
  local t = {}
  t.name = name
  win.scene"canvas".name = name
  t.table = win.scene"canvas".pixels
  t.undos = win.scene'canvas'.undos
  local v = win.scene"canvas".dim
  t.dim = {x = v.x, y = v.y}
  t.colors = Sprites.selected
  t.tool = win.scene"canvas".brush
  local vc = win.scene'view''back'.color
  t.view = {color = {vc.r,vc.g,vc.b,vc.a},
            state = win.scene'view''box'.hidden }
  local js = am.to_json(t)
  local f = io.open('Saves/' .. name .. '.ampt','w+')
  f:write(js)
  f:close()
  local record = io.open('Saves/Files.txt','a+')
  local names = record:read '*a'
  local new = string.find(names,name .. "\n")
  if new then else record:write("\n" .. name) end
  record:close()
end

function verifyFiles()
  local record = io.open('Saves/Files.txt','r+')
  local names = record:read '*a'
  local nstr = ""
  local lyns = s_to_t(names)
  for i=1,#lyns do
    if string.find(nstr,lyns[i]) then else
      if io.open('Saves/' .. lyns[i] .. '.ampt','r') then
        nstr = nstr .. lyns[i]
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

function load_proj(name)
  local f = io.open('Saves/' .. name .. '.ampt','r')
  if f == nil then return end
  local data = f:read '*a'
  f:close()
  local l = am.parse_json(data)
  Sprites.selected = l.colors
  win.scene"colors""selected1".color = am.ascii_color_map[Sprites.selected[1]]
  win.scene"colors""selected2".color = am.ascii_color_map[Sprites.selected[2]]
  win.scene'create'.hidden = true
  if win.scene'canvas' then
    win.scene'here':remove('canvas')
  end
  win.scene"here":append(Canvas.new(l.dim.x,l.dim.y))
  viewer.load(l.view.color,l.view.state)
  win.scene"canvas".pixels = l.table
  win.scene"canvas".undos = l.undos
  win.scene"canvas".name = name
  win.scene"canvas".brush = l.tool
  local tool = type(l.tool[1]) == "table" and l.tool[1][1] or l.tool[1]
  select_tool(tool)
end

function save_txt(name)
  win.scene"canvas".name = name
  local f = io.open('Exports/' .. name .. '.txt','w+')
  f:write(win.scene"canvas".sprite)
  f:close()
end

function export(name)
  win.scene"canvas".name = name
  local dim = win.scene"canvas".dim
  local img = am.image_buffer(dim.x,dim.y)
  local spr = win.scene"canvas".sprite
  local texture = am.sprite(spr).spec.texture
  local buff = am.framebuffer(texture)
  buff:read_back()
  local image = texture.image_buffer
  img:paste(image,1,1)
  img:save_png('Exports/' .. name .. '.png')
  img = nil
end

function menu.node()
  local nod = am.group():tag'menu'
                ^ {
                  GUI.button(win,
                            win.left+30,
                            win.top-10,60,20,
                            vec4(0.95,0.95,0.95,1),
                            "New",
                            function()
                              win.scene:append(Inputs.dimensions(win.left,win.top-5))
                            end)
                  , am.translate(win.left+30,win.top-10) 
                    ^ am.sprite(Sprites.menu_button)
                  ,
                  GUI.button(win,
                            win.left+90,
                            win.top-10,60,20,
                            vec4(0.95,0.95,0.95,1),
                            "Load",
                            function()
                              local files = {}
                              for line in io.lines("Saves/Files.txt") do 
                                files[#files + 1] = line
                              end
                              win.scene:append(
                                Inputs.choice(win.left+60,win.top-5,files,load_proj)
                                --Inputs.name(win.left+60,win.top-5,load_proj)
                              )
                            end)
                  , am.translate(win.left+90,win.top-10) 
                    ^ am.sprite(Sprites.menu_button)
                  ,
                  GUI.button(win,
                            win.left+150,
                            win.top-10,60,20,
                            vec4(0.95,0.95,0.95,1),
                            "Save",
                            function()
                              if win.scene'canvas' then
                                win.scene:append(
                                  Inputs.name(win.left+120,win.top-5,save_proj)
                                )
                              end
                            end)
                  , am.translate(win.left+150,win.top-10) 
                    ^ am.sprite(Sprites.menu_button)
                  ,
                  GUI.button(win,
                            win.left+210,
                            win.top-10,60,20,
                            vec4(0.95,0.95,0.95,1),
                            "Png",
                            function()
                              if win.scene'canvas' then
                                win.scene:append(
                                  Inputs.name(win.left+180,win.top-5,export)
                                )
                              end
                            end)
                  , am.translate(win.left+210,win.top-10) 
                    ^ am.sprite(Sprites.menu_button)
                  ,
                  GUI.button(win,
                            win.left+270,
                            win.top-10,60,20,
                            vec4(0.95,0.95,0.95,1),
                            "Txt",
                            function()
                              if win.scene'canvas' then
                                win.scene:append(
                                  Inputs.name(win.left+240,win.top-5,save_txt)
                                )
                              end
                            end)
                  , am.translate(win.left+270,win.top-10) 
                    ^ am.sprite(Sprites.menu_button)
                }
  return nod
end

function getName() return tostring(os.date(os.time())) end

function menu:autoSave(name)
  local n = #name > 0 and name or getName()
  save_proj(n)
end
function menu:saveAs(name)
  win.scene:append(
    Inputs.name(win.left+120,win.top-5,save_proj)
  )
end