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
      if math.within(rect,mp) and win:mouse_pressed('left') and
         not win.scene'view''box'.hidden then
        win.scene'view''back'.color = am.ascii_color_map[Sprites.selected[1]]
        onGui = true
      end
    end)
  return n
  end
  
  local nod = am.translate(0,0):tag"view"
              ^ am.group()
                ^ {am.translate(win.right-(dim.x/2)-20,
                                 win.bottom+dim.y/2):tag'box'
                    ^ am.group()
                      ^ {am.rect((-dim.x/2)-2,
                                  -dim.y/2,
                                  (dim.x/2)+2,
                                  (dim.y/2)+2)
                        , am.rect((-dim.x/2)-1,
                                  -dim.y/1,
                                  (dim.x/2)+1,
                                  (dim.y/2)+1,
                                  Color.black)
                        , bt(win.right-(dim.x/2)-20,
                           win.bottom+dim.y/2,
                           dim.x,dim.y)
                        , am.scale(1)
                          ^ am.sprite(Sprites.drawing)
                        }
                    ,
                    GUI.button(
                      win,
                      win.right-10,
                      win.bottom+10,
                      20,20,
                      Color.white,
                      '<',
                      function()
                        if not win.scene'canvas' then return end
                        if win.scene'view''box'.hidden == true then
                          win.scene'view''show'.text = '>'
                          win.scene'view''box'.hidden = false
                        elseif win.scene'view''box'.hidden == false then
                          win.scene'view''show'.text = '<'
                          win.scene'view''box'.hidden = true
                        end
                      end
                      ):tag'show'
                  }
  
  
  local zoom = 
  am.translate(-win.right+(dim.x/2)+20,
                -win.bottom-dim.y/2)
    ^ GUI.button(
      win,
      win.right-10,
      win.bottom+30,
      20,20,
      Color.white,
      'x1',
      function()
        local s = win.scene'view''box''scale'.scale2d
        if s.x == 1 then
          win.scene'view''box''button'.text = 'x2'
          win.scene'view''box''scale'.scale2d = vec2(2)
        elseif s.x == 2 then
          win.scene'view''box''button'.text = 'x1'
          win.scene'view''box''scale'.scale2d = vec2(1)
        end end )
      
  if dim.x < 80 then
    nod'view''box':append(zoom)
  end
  
  nod'box'.hidden = true
  
  return nod
end

function viewer.set()
  win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
end

function viewer.load(col,state)
  win.scene:replace('view',viewer.node(win.scene'canvas'.dim))
  local c = vec4(col[1],col[2],col[3],col[4])
  win.scene'view''back'.color = c
  if state == false then
    win.scene'view''show'.text = '>'
    win.scene'view''box'.hidden = false
  elseif state == true then
    win.scene'view''show'.text = '<'
    win.scene'view''box'.hidden = true
  end
end

function viewer.trigger()
  if not win.scene'canvas' then return end
  if win.scene'view''box'.hidden == true then
    win.scene'view''show'.text = '>'
    win.scene'view''box'.hidden = false
  elseif win.scene'view''box'.hidden == false then
    win.scene'view''show'.text = '<'
    win.scene'view''box'.hidden = true
  end
end