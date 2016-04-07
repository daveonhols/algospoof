show "spoof server is starting";
\l server.q
\t 1000

.z.pg:{[q]
    filterQueries[q];
    value q
  };

.z.ps:{[q]
    filterQueries[q];
    value q
  };


changeState[.state.WAITING_FOR_PLAYERS;whileWaitingForPlayers[.z.z+00:50:00;.z.z+01:00:00]];
