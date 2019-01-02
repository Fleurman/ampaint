viewer = ...

function viewer.node(arg)
  
  local dim = vec2(100,100)
  if arg then
    dim = arg + vec2(40,40)
  end
  
  local function bt(x,y,w,h,fn)
    local n = am.rect(-w/2,-h/2,w/2,h/2,Color.black):tag'back'
    n:action(function(node)
      local rect = vec4(x+node'rect'.x1,
                        y+node'rect'.y1,
                        x+node'rect'.x2,
                        y+node'rect'.y2)
      local mp = win:mouse_pixel_position() + vec2(win.left,win.bottom)
      if math.within(rect,mp) then
        onGui = true
        if win:mouse_pressed('left') and not win.scene'view''pbox'.hidden then
          win.scene'view''back'.color = am.ascii_color_map[Sprites.selected[1]]
        elseif win:mouse_pressed('right') and not win.scene'view''pbox'.hidden then
          win.scene'view''back'.color = am.ascii_color_map[Sprites.selected[2]]
        end
      end
    end)
  return n
  end
  
  local nod = am.translate(0,0):tag"view"
              ^ am.group()
                ^ { am.group():tag('pbox')
                  ^ {am.translate(win.right-(dim.x/2)-26, win.bottom+dim.y/2):tag'box'
                      ^ am.group()
                        ^ {am.rect((-dim.x/2)-2, -dim.y/2, (dim.x/2)+2, (dim.y/2)+2)
                          , am.rect((-dim.x/2)-1, -dim.y/1, (dim.x/2)+1, (dim.y/2)+1, Color.black)
                          , bt(win.right-(dim.x/2)-26, win.bottom+dim.y/2, dim.x,dim.y)
                          , am.scale(1) ^ am.sprite(Sprites.drawing)
                        },
                    }
                    ,
                    GUI.button(
                      win.right-10,
                      win.bottom+10,
                      20,20,
                      Color.white,nil,
                      '<',
                      function() viewer.trigger() end
                      ):tag'show'
                  }
  
  local zoom = GUI.imgbutton(
                win.right-11,
                win.bottom+34,
                {normal=Src.buttons.small.normal,
                 hover=Src.buttons.small.hover,
                 active=Src.buttons.small.active},
                Src.zoom.plus,
                function()
                  local s = win.scene'view''box''scale'.scale2d
                  if s.x == 1 then
                    win.scene'view''imgbutton'.icon = Src.zoom.minus
                    win.scene'view''box''scale'.scale2d = vec2(2)
                  elseif s.x == 2 then
                    win.scene'view''imgbutton'.icon = Src.zoom.plus
                    win.scene'view''box''scale'.scale2d = vec2(1)
                  end end )
      
  if dim.x < 80 then
    nod'view''pbox':append(zoom)
  end
  
  nod'pbox'.hidden = true
  
  return nod
end

function viewer.set()
  win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
end

function viewer.load(col,state)
  win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
  local c = vec4(col[1],col[2],col[3],col[4])
  win.scene'view''back'.color = c
  viewer.trigger(state)
end

function viewer.trigger(b)
  if not win.scene then return end
  if not win.scene'canvas' then return end
  b = b and (not b) or win.scene'view''pbox'.hidden
  if b then
    win.scene'view''show'.text = '>'
    win.scene'view''pbox'.hidden = false
  elseif not b then
    win.scene'view''show'.text = '<'
    win.scene'view''pbox'.hidden = true
  end
end