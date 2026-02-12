.raylib.layout._usageFlex:"usage: .raylib.layout.flex[t] where t has x y w h children (optional direction`row`col,gap,pad,align`start`center`end`stretch,wrap)";
.raylib.layout._usageGrid:"usage: .raylib.layout.grid[t] where t has x y cols rows (optional w,h,gapX,gapY,pad,align)";
.raylib.layout._usageStack:"usage: .raylib.layout.stack[t] where t has x y w h children (optional pad)";

.raylib.layout._resolveChild:{[c]
  if[-11h=type c; :.[value;enlist c;{()!()}]];
  :c
 };

.raylib.layout._childSize:{[c]
  cx:.[{x`w};enlist c;{0f}];
  cy:.[{x`h};enlist c;{0f}];
  :`w`h!(cx;cy)
 };

.raylib.layout._alignOffset:{[align;available;size]
  if[align=`start; :0f];
  if[align=`center; :(available-size)*0.5f];
  if[align=`end; :available];
  :0f
 };

.raylib.layout._maxVal:{[lst]
  if[0=count lst; :0f];
  m:first lst;
  i:1;
  while[i<count lst;
    if[lst i>m; m:lst i];
    i+:1];
  :m
 };

.raylib.layout._placeChild:{[c;px;py;pw;ph]
  base:.raylib.layout._resolveChild c;
  if[0=count base; :`x`y`w`h!(px;py;pw;ph)];
  base[`x]:px;
  base[`y]:py;
  if[`w in key base; base[`w]:pw];
  if[`h in key base; base[`h]:ph];
  :base
 };

.raylib.layout._wrapLine:{[widths;maxW;gap]
  lines:((),()),enlist 0;
  lineW:0f;
  wi:0;
  while[wi<count widths;
    wv:"f"$widths wi;
    needGap:$[1<count first lines;gap;0f];
    newW:lineW+wv+needGap;
    shouldBreak:(newW>maxW)&lineW>0f;
    if[shouldBreak;
      lines,:enlist enlist wi;
      lineW:wv];
    if[not shouldBreak;
      lines[(count lines)-1],:enlist wi;
      lineW:newW];
    wi+:1];
  :lines
 };

.raylib.layout.flex:{[t]
  usage:.raylib.layout._usageFlex;
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`children;`w`h`direction`gap`pad`align`wrap;usage];
  n:count rt;
  ri:0;
  results:();
  while[ri<n;
    x:"f"$rt[`x] ri;
    y:"f"$rt[`y] ri;
    w:.[{x`w};(rt;ri);{0f}];
    h:.[{x`h};(rt;ri);{0f}];
    dir:$[`direction in cols rt;rt[`direction] ri;`row];
    gap:"f"$.[{x`gap};(rt;ri);{4f}];
    pad:"f"$.[{x`pad};(rt;ri);{0f}];
    align:$[`align in cols rt;rt[`align] ri;`start];
    wrap:$[`wrap in cols rt;.raylib.ui._bool rt[`wrap] ri;0b];
    children:rt[`children] ri;
    cc:count children;
    if[cc=0; ri+:1; next];
    cx:x+pad;
    cy:y+pad;
    iw:$[w>0f;w-2f*pad;0f];
    ih:$[h>0f;h-2f*pad;0f];
    sizes:.raylib.layout._childSize each children;
    widths:sizes`w;
    heights:sizes`h;
    if[dir=`row;
      maxHeight:.raylib.layout._maxVal heights;
      totalW:sum widths + (cc-1)*gap;
      doWrap:wrap&iw>0f&totalW>iw;
      if[doWrap;
        lines:.raylib.layout._wrapLine[widths;iw;gap];
        lii:0;
        lyy:cy;
        while[lii<count lines;
          lnn:lines lii;
          lww:sum widths lnn + ((count lnn)-1)*gap;
          lxx:cx+.raylib.layout._alignOffset[align;iw;lww];
          ljj:0;
          while[ljj<count lnn;
            cii:lnn ljj;
            chh:children cii;
            cww:"f"$widths cii;
            chhh:"f"$heights cii;
            ayy:.raylib.layout._alignOffset[align;maxHeight;chhh];
            res:.raylib.layout._placeChild[chh;lxx;lyy+ayy;cww;chhh];
            results,:enlist res;
            lxx+:cww+gap;
            ljj+:1];
          lyy+:maxHeight+gap;
          lii+:1]];
      if[not doWrap;
        startX:cx+.raylib.layout._alignOffset[align;iw;totalW];
        cjj:0;
        while[cjj<cc;
          chh:children cjj;
          cww:"f"$widths cjj;
          chhh:"f"$heights cjj;
          ayy:.raylib.layout._alignOffset[align;maxHeight;chhh];
          res:.raylib.layout._placeChild[chh;startX;cy+ayy;cww;chhh];
          results,:enlist res;
          startX+:cww+gap;
          cjj+:1]]];
    if[dir=`col;
      maxWidth:.raylib.layout._maxVal widths;
      totalH:sum heights + (cc-1)*gap;
      startY:cy+.raylib.layout._alignOffset[align;ih;totalH];
      cjj:0;
      while[cjj<cc;
        chh:children cjj;
        cww:"f"$widths cjj;
        chhh:"f"$heights cjj;
        axx:.raylib.layout._alignOffset[align;maxWidth;cww];
        res:.raylib.layout._placeChild[chh;cx+axx;startY;cww;chhh];
        results,:enlist res;
        startY+:chhh+gap;
        cjj+:1]];
    ri+:1];
  :results
 };

.raylib.layout.grid:{[t]
  usage:.raylib.layout._usageGrid;
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`cols`rows;`w`h`gapX`gapY`pad`align;usage];
  n:count rt;
  results:();
  gi:0;
  while[gi<n;
    x:"f"$rt[`x] gi;
    y:"f"$rt[`y] gi;
    gridCols:"i"$rt[`cols] gi;
    gridRows:"i"$rt[`rows] gi;
    w:"f"$.[{x`w};(rt;gi);{0f}];
    h:"f"$.[{x`h};(rt;gi);{0f}];
    gapX:"f"$.[{x`gapX};(rt;gi);{4f}];
    gapY:"f"$.[{x`gapY};(rt;gi);{4f}];
    pad:"f"$.[{x`pad};(rt;gi);{0f}];
    if[(gridCols<1)|(gridRows<1); 'usage];
    cw:$[w>0f;(w-2f*pad-(gridCols-1)*gapX)%gridCols;100f];
    ch:$[h>0f;(h-2f*pad-(gridRows-1)*gapY)%gridRows;100f];
    if[`children in cols rt;
      children:rt[`children] gi;
      cyy:y+pad;
      rii:0;
      while[rii<gridRows;
        cxx:x+pad;
        cjj:0;
        while[cjj<gridCols;
          idx:rii*gridCols+cjj;
          if[idx<count children;
            chh:children idx;
            placed:.raylib.layout._placeChild[chh;cxx;cyy;cw;ch];
            results,:enlist placed];
          cxx+:cw+gapX;
          cjj+:1];
        cyy+:ch+gapY;
        rii+:1]];
    gi+:1];
  :results
 };

.raylib.layout.stack:{[t]
  usage:.raylib.layout._usageStack;
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`w`h`children;()`pad;usage];
  n:count rt;
  results:();
  si:0;
  while[si<n;
    x:"f"$rt[`x] si;
    y:"f"$rt[`y] si;
    w:"f"$rt[`w] si;
    h:"f"$rt[`h] si;
    pad:"f"$.[{x`pad};(rt;si);{0f}];
    children:rt[`children] si;
    sj:0;
    while[sj<count children;
      chh:.raylib.layout._resolveChild children sj;
      if[0<count chh;
        chh[`x]:x+pad;
        chh[`y]:y+pad;
        if[`w in key chh; chh[`w]:w-2f*pad];
        if[`h in key chh; chh[`h]:h-2f*pad];
        results,:enlist chh];
      sj+:1];
    si+:1];
  :results
 };

.raylib.layout.anchor:{[anchor;x;y;w;h;pw;ph]
  if[0=count anchor; :`x`y!(x;y)];
  ax:x;
  if[anchor=`tc; ax:x+0.5f*(pw-w)];
  if[anchor=`tr; ax:x+pw-w];
  if[anchor=`ml; ax:x];
  if[anchor=`mc; ax:x+0.5f*(pw-w)];
  if[anchor=`mr; ax:x+pw-w];
  if[anchor=`bl; ax:x];
  if[anchor=`bc; ax:x+0.5f*(pw-w)];
  if[anchor=`br; ax:x+pw-w];
  ay:y;
  if[anchor=`ml; ay:y+0.5f*(ph-h)];
  if[anchor=`mc; ay:y+0.5f*(ph-h)];
  if[anchor=`mr; ay:y+0.5f*(ph-h)];
  if[anchor=`bl; ay:y+ph-h];
  if[anchor=`bc; ay:y+ph-h];
  if[anchor=`br; ay:y+ph-h];
  :`x`y!(ax;ay)
 };

.raylib.layout.dock:{[t]
  usage:"usage: .raylib.layout.dock[t] where t has x y w h left right top bottom center (each is child or ())";
  rt:.raylib._resolveRefs[t;usage];
  .raylib._schemaValidate[rt;`x`y`w`h;`left`right`top`bottom`center;usage];
  n:count rt;
  results:();
  di:0;
  while[di<n;
    x:"f"$rt[`x] di;
    y:"f"$rt[`y] di;
    w:"f"$rt[`w] di;
    h:"f"$rt[`h] di;
    left:.raylib.layout._resolveChild .[rt;(`left;di);{:()}];
    right:.raylib.layout._resolveChild .[rt;(`right;di);{:()}];
    top:.raylib.layout._resolveChild .[rt;(`top;di);{:()}];
    bottom:.raylib.layout._resolveChild .[rt;(`bottom;di);{:()}];
    center:.raylib.layout._resolveChild .[rt;(`center;di);{:()}];
    lw:$[`w in key left;left`w;0f];
    rw:$[`w in key right;right`w;0f];
    th:$[`h in key top;top`h;0f];
    bh:$[`h in key bottom;bottom`h;0f];
    if[count left;
      left[`x]:x;
      left[`y]:y+th;
      left[`h]:h-th-bh;
      results,:enlist left];
    if[count right;
      right[`x]:x+w-rw;
      right[`y]:y+th;
      right[`h]:h-th-bh;
      results,:enlist right];
    if[count top;
      top[`x]:x+lw;
      top[`y]:y;
      top[`w]:w-lw-rw;
      results,:enlist top];
    if[count bottom;
      bottom[`x]:x+lw;
      bottom[`y]:y+h-bh;
      bottom[`w]:w-lw-rw;
      results,:enlist bottom];
    if[count center;
      center[`x]:x+lw;
      center[`y]:y+th;
      center[`w]:w-lw-rw;
      center[`h]:h-th-bh;
      results,:enlist center];
    di+:1];
  :results
 };
