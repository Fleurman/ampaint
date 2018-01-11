local Color = ...

Color.red = vec4(1, 0, 0, 1)
Color.white = vec4(1, 1, 1, 1)
Color.black = vec4(0, 0, 0, 1)
Color.over = vec4(0.9, 0.9, 0.9, 1)
Color.pressed = vec4(0.7, 0.7, 0.7, 1)

function Color.new(vls)
  r,g,b = vls[1],vls[2],vls[3]
  a = vls and vls[4] or 1
  return vec4(r,g,b,a)
end

function Color.rand(v)
    local vec = math.randvec4()
    vec = vec{a = v}
    return vec
end

function Color.lighter(c)
  return c * 1.2
end

function Color.darker(c)
  return c * 0.85
end