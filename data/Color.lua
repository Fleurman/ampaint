local Color = ...

Color.red = vec4(0.8, 0.2, 0, 1)
Color.yellow = vec4(0.8, 0.9, 0, 1)
Color.white = vec4(1, 1, 1, 1)
Color.whitesmoke = vec4(0.94, 0.94, 0.94, 1)
Color.black = vec4(0, 0, 0, 1)
Color.grey = vec4(0.5, 0.5, 0.5, 1)
Color.dimgrey = vec4(0.3, 0.3, 0.3, 1)
Color.lightgrey = vec4(0.8, 0.8, 0.8, 1)
Color.over = vec4(0.9, 0.9, 0.9, 1)
Color.pressed = vec4(0.7, 0.7, 0.7, 1)

Color.node = am.translate(win.left+21,win.bottom+31)
              ^ am.group():tag"colors"
                ^ {
                  am.group()
                  ^ { am.translate(0,0) ^ am.rect(-17,-17,17,17,Color.white)
                    , am.translate(10,-10) ^ am.rect(-17,-17,17,17,Color.white)
                    , am.translate(0,0) ^ am.rect(-16,-16,16,16,Color.black)
                    , am.translate(10,-10) ^ am.rect(-16,-16,16,16,Color.black)
                    }
                ,
                  am.group()
                  ^ { am.translate(10,-10)
                      ^ am.scale(5) ^ am.sprite(Sprites:textured("void",3,3))
                    , am.translate(10,-10)
                      ^ am.rect(-15,-15,15,15,Color.white):tag"selected2"
                    }
                ,
                am.group()
                  ^ { am.translate(0,0)
                      ^ am.scale(5) ^ am.sprite(Sprites:textured("void",3,3))
                    , am.translate(0,0)
                      ^ am.rect(-15,-15,15,15,Color.black):tag"selected1"
                    }
                }

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

function Color.lighter(c) local v = c * 1.2 return v{a=1} end
function Color.darker(c) local v = c * 0.85 return v{a=1} end

function Color.whiten(c) return vec4(c.r+0.5,c.g+0.5,c.b+0.5,c.a) end
function Color.blacken(c) return vec4(c.r-0.5,c.g-0.5,c.b-0.5,c.a) end

function Color.translucid(c)
  return vec4(c.r,c.g,c.b,0.7)
end