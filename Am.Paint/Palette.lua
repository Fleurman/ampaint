palette = ...

function palette.node()
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
                  am.scale(7)
                   ^ am.sprite(Sprites:textured("void",6,32))
                  , 
                  am.scale(scale)
                   ^ am.sprite(Sprites.palette)
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
      index = (17-(9+iy))%17 + (ix+2)*16
      --scene'log'.text = index
      
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