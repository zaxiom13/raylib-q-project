/ Complex numbers for all q sessions.
/ Representation: `re`im!(real;imag), both float scalars.

.cx._usage:"usage: complex must be a numeric scalar, numeric pair (re im), or `re`im dictionary";

.cx._isNumericType:{[t]
  ti:"i"$abs t;
  :any ti=1 4 5 6 7 8 9
 };

.cx.from:{[x]
  usage:.cx._usage;
  t:type x;
  if[99h=t;
    k:.[key;enlist x;{`$()}];
    if[all `re`im in k;
      :`re`im!("f"$x`re;"f"$x`im)];
    'usage];
  if[not .cx._isNumericType t; 'usage];
  if[t<0h; :`re`im!("f"$x;0f)];
  if[2=count x; :`re`im!("f"$x 0;"f"$x 1)];
  'usage
 };

.cx.new:{[re;im]
  :`re`im!("f"$re;"f"$im
 )
 };

.cx.z:.cx.new;
.cx.zero:.cx.new[0f;0f];
.cx.one:.cx.new[1f;0f];
.cx.i:.cx.new[0f;1f];

.cx.re:{[z]
  :(.cx.from z)`re
 };

.cx.im:{[z]
  :(.cx.from z)`im
 };

.cx.conj:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  :`re`im!(re;(-1f)*im)
 };

.cx.neg:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  :`re`im!((-1f)*re;(-1f)*im)
 };

.cx.add:{[a;b]
  x:.cx.from a;
  y:.cx.from b;
  xr:x`re;
  xi:x`im;
  yr:y`re;
  yi:y`im;
  :`re`im!(xr+yr;xi+yi)
 };

.cx.sub:{[a;b]
  x:.cx.from a;
  y:.cx.from b;
  xr:x`re;
  xi:x`im;
  yr:y`re;
  yi:y`im;
  :`re`im!(xr+((-1f)*yr);xi+((-1f)*yi))
 };

.cx.mul:{[a;b]
  x:.cx.from a;
  y:.cx.from b;
  xr:x`re;
  xi:x`im;
  yr:y`re;
  yi:y`im;
  r1:xr*yr;
  r2:xi*yi;
  i1:xr*yi;
  i2:xi*yr;
  :`re`im!(
    r1+((-1f)*r2);
    i1+i2
   )
 };

.cx.div:{[a;b]
  x:.cx.from a;
  y:.cx.from b;
  xr:x`re;
  xi:x`im;
  yr:y`re;
  yi:y`im;
  den:(yr*yr)+(yi*yi);
  if[0f=den; '"domain"];
  nre:((xr*yr)+(xi*yi));
  nim:((xi*yr)+((-1f)*(xr*yi)));
  :`re`im!(
    nre%den;
    nim%den
   )
 };

.cx.abs:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  mag2:(re*re)+(im*im);
  :sqrt mag2
 };

.cx.modulus:.cx.abs;

.cx.floor:{[z]
  c:.cx.from z;
  :`re`im!("f"$floor c`re;"f"$floor c`im)
 };

.cx.ceil:{[z]
  c:.cx.from z;
  :`re`im!("f"$ceiling c`re;"f"$ceiling c`im)
 };

.cx.round:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  rr:$[re>=0f;floor (re+0.5f);ceiling (re-0.5f)];
  ri:$[im>=0f;floor (im+0.5f);ceiling (im-0.5f)];
  :`re`im!("f"$rr;"f"$ri)
 };

.cx.frac:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  rr:re-floor re;
  ri:im-floor im;
  :`re`im!(rr;ri)
 };

.cx.mod:{[a;b]
  x:.cx.from a;
  xr:x`re;
  xi:x`im;
  tb:type b;
  if[.cx._isNumericType tb;
    if[tb<0h;
      d:"f"$b;
      if[0f=d; '"domain"];
      :`re`im!(xr mod d;xi mod d)]];
  y:.cx.from b;
  dr:y`re;
  di:y`im;
  if[(0f=dr)|(0f=di); '"domain"];
  :`re`im!(xr mod dr;xi mod di)
 };

.cx.arg:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  pi:acos -1f;
  if[(0f=re)&(0f=im); :0f];
  if[re>0f; :atan im%re];
  if[(re<0f)&(im>=0f); :(atan im%re)+pi];
  if[(re<0f)&(im<0f); :(atan im%re)-pi];
  if[(0f=re)&(im>0f); :pi%2f];
  :(-1f)*pi%2f
 };

.cx.recip:{[z]
  :.cx.div[1f;z]
 };

.cx.normalize:{[z]
  m:.cx.abs z;
  if[0f=m; '"domain"];
  :.cx.div[z;m]
 };

.cx.fromPolar:{[r;theta]
  rr:"f"$r;
  tt:"f"$theta;
  :`re`im!(rr*cos tt;rr*sin tt)
 };

.cx.polar:{[z]
  c:.cx.from z;
  :`r`theta!(.cx.abs c;.cx.arg c)
 };

.cx.exp:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  er:exp re;
  :`re`im!(er*cos im;er*sin im)
 };

.cx.log:{[z]
  c:.cx.from z;
  m:.cx.abs c;
  if[0f=m; '"domain"];
  :`re`im!(log m;.cx.arg c)
 };

.cx.pow:{[a;b]
  :.cx.exp .cx.mul[b;.cx.log a]
 };

.cx.powEach:{[a;b]
  x:.cx.from a;
  xr:x`re;
  xi:x`im;
  tb:type b;
  if[.cx._isNumericType tb;
    if[tb<0h;
      e:"f"$b;
      :`re`im!(xr xexp e;xi xexp e)]];
  y:.cx.from b;
  :`re`im!(xr xexp y`re;xi xexp y`im)
 };

.cx.sqrt:{[z]
  c:.cx.from z;
  p:.cx.polar c;
  :.cx.fromPolar[sqrt p`r;0.5f*p`theta]
 };

.cx.sin:{[z]
  c:.cx.from z;
  a:c`re;
  b:c`im;
  eb:exp b;
  enb:exp ((-1f)*b);
  sh:(eb-enb)%2f;
  ch:(eb+enb)%2f;
  :`re`im!((sin a)*ch;(cos a)*sh)
 };

.cx.cos:{[z]
  c:.cx.from z;
  a:c`re;
  b:c`im;
  eb:exp b;
  enb:exp ((-1f)*b);
  sh:(eb-enb)%2f;
  ch:(eb+enb)%2f;
  :`re`im!((cos a)*ch;((-1f)*(sin a))*sh)
 };

.cx.tan:{[z]
  :.cx.div[.cx.sin z;.cx.cos z]
 };

.cx.str:{[z]
  c:.cx.from z;
  re:c`re;
  im:c`im;
  s:$[im<0f;"-";"+"];
  m:abs im;
  :raze (string re;" ";s;" ";string m;"i")
 };
