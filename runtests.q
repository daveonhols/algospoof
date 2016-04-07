loadScript:.z.x[0];
value "\\l ",loadScript;
workspaces:`${x where x like "test*"}string key `
testspace:first workspaces except `testutils;

show "testing: ", string testspace;
testfuncs:{x where x like "test*"}key `$".",string testspace;

qualify:{[sp;fn] `$(".",(string sp),"."),string fn};

/ sp:(".",string testspace),".";fn:first string testfuncs
testable:testfuncs where 100h=type each value each qualify[testspace] each testfuncs;
execable:qualify[testspace]each testable;
results:{@[(value x);0;{"failed to execute: ",x}]}each execable;

print:{

    show "---------------------------";
    show "--TEST RESULTS ------------";
    show "--",(string testspace);
    show (string count execable)," tests.  passed:", (string count where pass), ".  failed:", (string count where not pass);
  };

pass:
    {[res]
        $[1h=type first res;
            all first res;
            0b]
  }each results;

print[];
if[all pass;exit 1];

reasons:
    {[res]
        $[10h=type res;
            res;
            "checks failed: ", "\n:: " sv res[1] where not res[0]]
  }each results where not pass;

reasons:": " sv/:flip ((string execable where not pass);(reasons));
show reasons;
exit 0;

