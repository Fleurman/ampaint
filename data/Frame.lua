--[[------------------------------------------------------------------------------
                                      **FRAME**
----------------------------------------------------------------------------------]]

function GUI.frame(x,y,w,h)
  local src = am.sprite(Src.gui.frame).spec.texture
  local q = am.quads(1, {"vert", "vec2", "uv", "vec2"})
  
  function getXY(id)
    id = id-1
    local x,y = id%3,math.floor(id/3)
    return x,y
  end
  function getUV(id)
    local x,y = getXY(id)
    local x1,y1 = (1/3)*x,(1/3)*y
    local x2,y2 = x1+(1/3),y1+(1/3)
    return {  vec2(x1, y2), vec2(x1, y1), vec2(x2, y1), vec2(x2, y2) }
  end
  function getDim(id)
    local x,y = getXY(id)
    local nw = x == 1 and w-16 or 8
    local nh = y == 1 and h-16 or 8
    return nw,nh
  end
  function getPos(id)
    local x,y = getXY(id)
    local nx,ny = 0,0
    if x == 1 then nx = 8 elseif x == 2 then nx = w-8 end
    if y == 1 then ny = 8 elseif y == 2 then ny = h-8 end
    return nx,ny
  end
  
  for i=1,9 do
    local qx,qy = getPos(i)
    local qw,qh = getDim(i)
    local uv = getUV(i)
    q:add_quad{
      vert = {vec2(qx, qy+qh), vec2(qx,qy),vec2(qx+qw,qy), vec2(qx+qw,qy+qh)},uv = uv
    }
  end

  local p = am.program([[
      precision highp float;
      attribute vec2 vert;
      attribute vec2 uv;
      uniform mat4 MV;
      uniform mat4 P;
      varying vec2 v_uv;
      void main() {
          v_uv = uv;
          gl_Position = P * MV * vec4(vert, 0.0, 1.0);
      }
  ]],
  [[
      precision mediump float;
      uniform sampler2D tex;
      varying vec2 v_uv;
      void main() {
          gl_FragColor = texture2D(tex, v_uv);
      }
  ]])

  local node = am.translate(x,y) 
                ^ am.blend"premult"
                ^ am.use_program(p)
                ^ am.bind{tex = src}
                ^ q
  
  return node
  
end
