.raylib.util._easeLinear:{[t] :t };
.raylib.util._easeInQuad:{[t] :t*t };
.raylib.util._easeOutQuad:{[t] :t*(2f-t) };
.raylib.util._easeInOutQuad:{[t] :$[t<0.5f;2f*t*t;-1f+(4f-2f*t)*t] };
.raylib.util._easeInCubic:{[t] :t*t*t };
.raylib.util._easeOutCubic:{[t] :1f+((t-1f)*t*t) };
.raylib.util._easeInOutCubic:{[t] :$[t<0.5f;4f*t*t*t;1f+((t-1f)*(2f*t-2f)*2f)] };
.raylib.util._easeInElastic:{[t] :$[t=0f;0f;$[t=1f;1f;-1f*exp(10f*t-10f)*sin((10f*t-10.75f)*3.14159f*2f%3f)]] };
.raylib.util._easeOutElastic:{[t] :$[t=0f;0f;$[t=1f;1f;exp(-10f*t)*sin((10f*t-0.75f)*3.14159f*2f%3f)+1f]] };
.raylib.util._easeOutBounce:{[t]
  n:7.5625f;
  d:2.75f;
  $[t<1f%d; n*t*t;
    t<2f%d; n*(t-1.5f%d)*t+0.75f;
    t<2.5f%d; n*(t-2.25f%d)*t+0.9375f;
    n*(t-2.625f%d)*t+0.984375f]
 };

.raylib.util.ease:`linear`inQuad`outQuad`inOutQuad`inCubic`outCubic`inOutCubic`inElastic`outElastic`outBounce!(
  .raylib.util._easeLinear;
  .raylib.util._easeInQuad;
  .raylib.util._easeOutQuad;
  .raylib.util._easeInOutQuad;
  .raylib.util._easeInCubic;
  .raylib.util._easeOutCubic;
  .raylib.util._easeInOutCubic;
  .raylib.util._easeInElastic;
  .raylib.util._easeOutElastic;
  .raylib.util._easeOutBounce);

.raylib.util.lerp:{[a;b;t]
  :a+t*(b-a)
 };

.raylib.util.lerpColor:{[c1;c2;t]
  r:"i"$c1[0]*(1f-t)+c2[0]*t;
  g:"i"$c1[1]*(1f-t)+c2[1]*t;
  b:"i"$c1[2]*(1f-t)+c2[2]*t;
  a:"i"$c1[3]*(1f-t)+c2[3]*t;
  :(r;g;b;a)
 };

.raylib.util.clamp:{[val;lo;hi]
  :$[val<lo;lo;$[val>hi;hi;val]]
 };

.raylib.util.wrap:{[val;lo;hi]
  range:hi-lo;
  :$[range=0f;lo;lo+((val-lo)mod range)]
 };

.raylib.util.pingpong:{[t;len]
  :len-abs((t mod (2f*len))-len)
 };

.raylib.util.dist:{[x1;y1;x2;y2]
  dx:x2-x1;
  dy:y2-y1;
  :sqrt (dx*dx)+dy*dy
 };

.raylib.util.distSq:{[x1;y1;x2;y2]
  dx:x2-x1;
  dy:y2-y1;
  :(dx*dx)+dy*dy
 };

.raylib.util.angle:{[x1;y1;x2;y2]
  :atan[y2-y1;x2-x1]
 };

.raylib.util.degToRad:{[deg] :deg*3.14159265f%180f };
.raylib.util.radToDeg:{[rad] :rad*180f%3.14159265f };

.raylib.util.rotatePoint:{[x;y;cx;cy;angle]
  rad:.raylib.util.degToRad angle;
  cosA:cos rad;
  sinA:sin rad;
  dx:x-cx;
  dy:y-cy;
  nx:cx+(dx*cosA)-(dy*sinA);
  ny:cy+(dx*sinA)+(dy*cosA);
  :`x`y!(nx;ny)
 };

.raylib.util.pointInRect:{[px;py;rx;ry;rw;rh]
  :((px>=rx)&(px<=rx+rw))&((py>=ry)&(py<=ry+rh))
 };

.raylib.util.pointInCircle:{[px;py;cx;cy;r]
  :.raylib.util.dist[px;py;cx;cy]<=r
 };

.raylib.util.rectsOverlap:{[x1;y1;w1;h1;x2;y2;w2;h2]
  :((x1<x2+w2)&(x1+w1>x2))&((y1<y2+h2)&(y1+h1>y2))
 };

.raylib.util.rectsContain:{[outerX;outerY;outerW;outerH;innerX;innerY;innerW;innerH]
  :((innerX>=outerX)&(innerX+innerW<=outerX+outerW))&((innerY>=outerY)&(innerY+innerH<=outerY+outerH))
 };

.raylib.util.rectCenter:{[x;y;w;h]
  :`x`y!(x+0.5f*w;y+0.5f*h)
 };

.raylib.util.random:{[lo;hi]
  :lo+(hi-lo)*((.z.t%1000000000f)mod 1f)
 };

.raylib.util.randomInt:{[lo;hi]
  :lo+("i"$(hi-lo+1f)*((.z.t%1000000f)mod 1f))
 };

.raylib.util.randomColor:{
  r:.raylib.util.randomInt[0;255];
  g:.raylib.util.randomInt[0;255];
  b:.raylib.util.randomInt[0;255];
  :(r;g;b;255i)
 };

.raylib.util.randomPastel:{
  r:180+.raylib.util.randomInt[0;75];
  g:180+.raylib.util.randomInt[0;75];
  b:180+.raylib.util.randomInt[0;75];
  :(r;g;b;255i)
 };

.raylib.util.hsvToRgb:{[h;s;v]
  h:((h mod 360f)+360f)mod 360f;
  c:v*s;
  x:c*(1f-abs((h%60f)mod 2f)-1f);
  m:v-c;
  :$[h<60f;(c+m;x+m;m);
    h<120f;(x+m;c+m;m);
    h<180f;(m;c+m;x+m);
    h<240f;(m;x+m;c+m);
    h<300f;(x+m;m;c+m);
    (c+m;m;x+m)]
 };

.raylib.util.rgbToHsv:{[r;g;b]
  r:"f"$r%255f;
  g:"f"$g%255f;
  b:"f"$b%255f;
  maxVal:{max x}each enlist each (r;g;b);
  minVal:{min x}each enlist each (r;g;b);
  d:maxVal-minVal;
  h:$[d=0f;0f;
     maxVal=r;60f*((g-b)%d+$[g<b;6f;0f]);
     maxVal=g;60f*((b-r)%d+2f);
     60f*((r-g)%d+4f)];
  s:$[maxVal=0f;0f;d%maxVal];
  v:maxVal;
  :`h`s`v!(h;s;v)
 };

.raylib.util.darken:{[color;amount]
  r:"i"$color[0]*(1f-amount);
  g:"i"$color[1]*(1f-amount);
  b:"i"$color[2]*(1f-amount);
  :(r;g;b;color 3)
 };

.raylib.util.lighten:{[color;amount]
  r:"i"$color[0]+(255-color[0])*amount;
  g:"i"$color[1]+(255-color[1])*amount;
  b:"i"$color[2]+(255-color[2])*amount;
  :(r;g;b;color 3)
 };

.raylib.util.alpha:{[color;a]
  :(color 0;color 1;color 2;"i"$a*color[3]%255f)
 };

.raylib.util.withAlpha:{[color;a]
  c:.raylib._rgba4 color;
  c[3]:"i"$255f*a;
  :c
 };
