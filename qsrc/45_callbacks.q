.raylib._callbacks.empty:{[]
  :([] id:`int$(); fn:(); enabled:0#0b)
 };

.raylib._callbacks._idsOrUsage:{[id;usage]
  :$[-6h=type id;enlist "i"$id;$[6h=type id;"i"$id;'usage]]
 };

.raylib._callbacks.on:{[stateSym;nextIdSym;fn]
  id:value nextIdSym;
  nextIdSym set id+1i;
  s:value stateSym;
  s,: ([] id:enlist id; fn:enlist fn; enabled:enlist 1b);
  stateSym set s;
  :id
 };

.raylib._callbacks.off:{[stateSym;id;usage]
  ids:.raylib._callbacks._idsOrUsage[id;usage];
  s:value stateSym;
  keep:not s[`id] in ids;
  stateSym set s where keep;
  :(count s)-sum keep
 };

.raylib._callbacks.clear:{[stateSym]
  stateSym set .raylib._callbacks.empty[];
  :0
 };

.raylib._callbacks.dispatch:{[s;arg]
  i:0;
  while[i<count s;
    if[s[`enabled] i;
      res:.[s[`fn] i;enlist arg;{x}];
      if[10h=type res; 'res]];
    i+:1];
  :arg
 };
