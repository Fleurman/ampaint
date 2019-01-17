Palette = ...

Palette.name = string.toNumber('SNES')
Palette.file = 'SNES'

Palette.transitionMap = {A="C",B="F",C="I",D="L",E="O",F="R",G="U",H="X",I="a",J="d",K="g",L="j",M="m",N="p",O="s",P="v",Q="B",R="E",S="H",T="K",U="N",V="Q",W="T",X="W",Y="Z",Z="c",a="f",b="i",c="l",d="o",e="r",f="u",g="A",h="D",i="G",j="J",k="M",l="P",m="S",n="V",o="Y",p="b",q="e",r="h",s="k",t="n",u="q",v="t"}

function Palette:transformOldNes(data)
  for i,r in ipairs(data) do
    for n,l in ipairs(r) do 
      data[i][n] = Palette.transitionMap[l] or '.'
    end
  end
  return data
end

function Palette:refreshColors()
  win.scene"colors""selected1".color = am.ascii_color_map[Sprites.selected[1]]
  win.scene"colors""selected2".color = am.ascii_color_map[Sprites.selected[2]]
end

function setPalette(name)
  name = name or '???'
  if io.exists('Palettes/'+name+'.png') then
    Palette.file = name
    Palette.name = string.toNumber(name)
    local map = readPalette(name)
    am.ascii_color_map = map
    win.scene'palette_spr'.source = ROOT..'Palettes/'+name+'.png'
    Palette:refreshColors()
    if win.scene'canvas' then win.scene'canvas':redraw() end
  else
    win.scene:append( GUI.log('The palette ' .. name .. ' is not available.') )
  end
end
function Palette:set(name)
  setPalette(name)
end

function Palette.node()
  local index = 1
  local x,y = win.left+26,win.bottom+170
  local scale = 14
  local width,height = 3*scale,16*scale
  
  local nod = am.translate(x,y):tag"palette"
                ^ {
                  am.rect((-width/2)-2,
                          (height/2)+2,
                          (width/2)+2,
                          (-height/2)-2,
                          Color.white)
                  ,am.rect((-width/2)-1,
                           (height/2)+1,
                           (width/2)+1,
                           (-height/2)-1,
                           Color.black)
                  ,
                  GUI.imgbutton( 0,124,
                  Src.flatButton(),
                  Src.gui.hamburger.small,
                  function()
                    local files = table.map(am.glob{"Palettes/*.png", "Palettes/*.jpg"},
                      function(s)
                        return string.match(s,".*/(.+)%..+")
                      end)
                    --print(table.tostring(files))
                    win.scene:append( Inputs.choice(
                      win.left+52,win.bottom+314,files,setPalette,8) )
                  end
                  ):tag("palettes_list"),
                  am.scale(7)
                   ^ am.sprite(Sprites:textured("void",6,32))
                  , 
                  am.scale(scale)
                   ^ am.sprite(Sprites.palette):tag('palette_spr')
                  ,
                  am.square(0,0,scale,scale,1,Color.white)
                  --, am.text('log'):tag'log'
                  }

  local function rect()
    return vec4(-width/2,
                -height/2,
                width/2,
                height/2)
  end
  
  nod:action(function(scene)
    if onAct or onSys then return end
    local r = rect()
    local mp = win:mouse_pixel_position() -
               vec2(win.width/2,win.height/2) -
               vec2(x,y)
    scene"square".hidden = true
    if math.within(r,mp) then
      onGui = true
      scene"square".hidden = false
      local ix = math.floor((mp.x-7)/scale)
      local iy = math.floor(mp.y/scale)
      scene'square'.x,scene'square'.y = (ix*scale)+7,iy*scale
      local nix = (ix+2)%4
      local niy = (iy-7)*-3
      index = 1+nix+niy
      
      if win:mouse_pressed("left") and
         not win:mouse_down('middle') then
        if Sprites.select_color(index,1) then
          win.scene"colors""selected1".color = Sprites.select_color(index,1)
        end
      elseif win:mouse_pressed("right") and
         not win:mouse_down('middle')  then
        if Sprites.select_color(index,2) then
          win.scene"colors""selected2".color = Sprites.select_color(index,2)
        end
      end
    end
  end)
              
  return nod
end