show ".."
\l server.q

.testutils.assertEqual:{ enlist (x~y;z)};

msgs:([] who:`long$(); msgType:(); msg:());
msgPlayer:{[h;o;a] insert[`msgs] (h;o;a)};
shufflePlayers:{};

kickPlayers:{};

clean:{
    `.[`init][];
    delete from `msgs;
  };

\d .testserver

testJoining:{

    result:();
    
    `.[`clean][];
    `.[`join]["daivd";1];
    `.[`join]["bob";2];
    `.[`join]["helen";3];
    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    flip result

  };

testStarting:{

    result:();
    
    `.[`clean][];`.[`join]["daivd";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    
    `.[`startGame][];
    result ,: .testutils.assertEqual[3;count `.[`all_players];"three players still in"];
    result ,: .testutils.assertEqual[3;count `.[`active_players];"three players active"];
    result ,: .testutils.assertEqual[3;count `.[`secrets];"waiting for three secerts"];
    result ,: .testutils.assertEqual[1b;all null `.[`secrets][;0];"no secrets yet"];
    
    .result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"waiting for secrets"];

    flip result

  };

testGetGuessesNoWinner:{

    result:();    
    `.[`clean][];`.[`join]["daivd";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    
    `.[`startGame][];
     `.[`submitSecret][3;1]; `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];

    result ,: .testutils.assertEqual[3;count `.[`guesses];"waiting for three guesses"];
    result ,: .testutils.assertEqual[0;count `.[`guessed];"no guesses received"];

    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    
    result ,: .testutils.assertEqual[3;count `.[`guesses];"still waiting for three guesses"];
    result ,: .testutils.assertEqual[0;count `.[`guessed];"still no guesses received"];

    `.[`submitGuess][3;1];
    result ,: .testutils.assertEqual[3;first first `.[`guesses];"guess of three received"];
    result ,: .testutils.assertEqual[3;count `.[`guesses];"guess not handled until timer"];    
    result ,: .testutils.assertEqual[0;count `.[`guessed];"guess not handled until timer"];
    
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[2;count `.[`guesses];"guess processed after timer"];    
    result ,: .testutils.assertEqual[1;count `.[`guessed];"guess processed after timer"];
    result ,: .testutils.assertEqual[3;first first `.[`guessed];"guess of three processed"];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for next guess"];

    `.[`submitGuess][4;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[4;first last `.[`guessed];"guess of four received"];
    result ,: .testutils.assertEqual[1;count `.[`guesses];"guess not handled until timer"];    
    result ,: .testutils.assertEqual[2;count `.[`guessed];"guess not handled until timer"];

    result ,: .testutils.assertEqual[0;count select from `msgs where msgType=`reveal;"nothing revealed yet"];
    / no one is winning....
    `.[`submitGuess][5;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[3;count select from `msgs where msgType=`reveal;"revealed to three players"];
    result ,: .testutils.assertEqual[3;count select from `msgs where msgType=`round_no_winner;"three players informed no winner"];
    
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"round ended, new round, waiting for secrets"];
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players still in"];

    flip result


  };


testGetSecrets:{

    result:();
    
    `.[`clean][];`.[`join]["daivd";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    
    `.[`startGame][];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"waiting for secrets"];
    result ,: .testutils.assertEqual[1b;all null `.[`secrets][;0];"no secrets"];
    
     `.[`submitSecret][3;1];
    result ,: .testutils.assertEqual[1;count where not null `.[`secrets][;0];"one secrets"];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"waiting for secrets"];

     `.[`submitSecret][3;2];
    result ,: .testutils.assertEqual[2;count where not null `.[`secrets][;0];"two secrets"];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"waiting for secrets"];

     `.[`submitSecret][3;3];
    result ,: .testutils.assertEqual[3;count where not null  `.[`secrets][;0];"three secrets"];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];

    
    flip result

  };

testEliminateWinnerLast:{
    
    result:();    
    `.[`clean][];`.[`join]["david";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    
    `.[`startGame][];
     `.[`submitSecret][3;1]; `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];
    `.[`submitGuess][3;1];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][4;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    / player three guessed correctly
    `.[`submitGuess][9;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];

    result ,: .testutils.assertEqual[3;count `.[`all_players];"all players has everyone"];
    result ,: .testutils.assertEqual[2;count `.[`active_players];"winner removed from active players"];
    result ,: .testutils.assertEqual[0b;"helen" in `.[`active_players][;0];"correct winner was removed"];
    result ,: .testutils.assertEqual[1b;all ("david";"bob") in `.[`active_players][;0];"correct winner was removed"];

    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"next round, waiting for secrets"];
    result ,: .testutils.assertEqual[3;count select from `msgs where msgType=`round_winner;"players told of winner"];
    result ,: .testutils.assertEqual[3#`helen;exec `$msg from `msgs where msgType=`round_winner;"players told correct winner"];
    
    newRoundMsgs:(select from `msgs where i > max exec i from `msgs where msgType=`round_winner);
    result ,: .testutils.assertEqual[2;count select from newRoundMsgs where msgType=`players;"two players notified for next round"];
    result ,: .testutils.assertEqual[([] msg:asc each(("bob";"david");("bob";"david")));select asc each msg from newRoundMsgs where msgType=`players;"new players correctly notified"];

    flip result

  };


testEliminateWinnerFirst:{
    
    result:();    
    `.[`clean][];`.[`join]["david";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    
    `.[`startGame][];
     `.[`submitSecret][3;1]; `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];
    `.[`submitGuess][9;1];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][4;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    / player three guessed correctly
    `.[`submitGuess][3;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];

    result ,: .testutils.assertEqual[3;count `.[`all_players];"all players has everyone"];
    result ,: .testutils.assertEqual[2;count `.[`active_players];"winner removed from active players"];
    result ,: .testutils.assertEqual[0b;"david" in `.[`active_players][;0];"correct winner was removed"];
    result ,: .testutils.assertEqual[1b;all ("helen";"bob") in `.[`active_players][;0];"correct winner was removed"];

    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"next round, waiting for secrets"];
    result ,: .testutils.assertEqual[2;count `.[`secrets];"waiting only for secrets from active players"];
    result ,: .testutils.assertEqual[1b;all null `.[`secrets][;0];"secrets not populated for active players"];

    flip result

  };

/ `.[`active_players]
testFinalRound:{
    
    result:();    
    `.[`clean][];`.[`join]["david";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    result ,:.testutils.assertEqual[3;count `.[`all_players];"three players in"];
    
    `.[`startGame][];
     `.[`submitSecret][3;1]; `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];

    /player one (david) guesses correctly
    `.[`submitGuess][9;1];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][4;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][3;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    


    / player one eliminated, new round
    result ,: .testutils.assertEqual[3;count `.[`all_players];"all players has everyone"];
    result ,: .testutils.assertEqual[2;count `.[`active_players];"winner removed from active players"];

     `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][5;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    / player three (helen) guesses correctly
    `.[`submitGuess][6;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    
    result ,: .testutils.assertEqual[3;count select from `msgs where msgType=`loser, msg like "bob";"all players notified there was a loser"];    
    
    flip result

  };


testSubmitSecrets:{
    
    result:();    
    `.[`clean][];`.[`join]["david";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    `.[`startGame][];
     `.[`submitSecret][3;1]; `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];
    `.[`submitGuess][9;1];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][4;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][3;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];

    result ,: .testutils.assertEqual[3;count `.[`all_players];"all players has everyone"];
    result ,: .testutils.assertEqual[2;count `.[`active_players];"winner removed from active players"];
    result ,: .testutils.assertEqual[0b;"david" in `.[`active_players][;0];"correct winner was removed"];
    result ,: .testutils.assertEqual[1b;all ("helen";"bob") in `.[`active_players][;0];"correct winner was removed"];

    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"next round, waiting for secrets"];
    result ,: .testutils.assertEqual[2;count `.[`secrets];"waiting only for secrets from active players"];
    result ,: .testutils.assertEqual[1b;all null `.[`secrets][;0];"secrets not populated for active players"];


    failmsg:.[`.[`submitSecret];(3;1);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: a secret from you is not required";"eliminatd player cannot submit"];
    failmsg:.[`.[`submitSecret];(3;99);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: a secret from you is not required";"unexpected player cannot submit"];
    failmsg:.[`.[`submitSecret];(99;2);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: Your secret must be less than *";"secret must be in range"];
    failmsg:.[`.[`submitSecret];("three";2);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "*secret must be an integer";"secret must be an int"];

    flip result

  };


testSubmitGuesses:{
    
    result:();    
    `.[`clean][];`.[`join]["david";1];`.[`join]["bob";2];`.[`join]["helen";3];    
    `.[`startGame][];
     `.[`submitSecret][3;1]; `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"waiting for first guess"];
    `.[`submitGuess][9;1];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][4;2];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    `.[`submitGuess][3;3];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];

    result ,: .testutils.assertEqual[3;count `.[`all_players];"all players has everyone"];
    result ,: .testutils.assertEqual[2;count `.[`active_players];"winner removed from active players"];
    result ,: .testutils.assertEqual[0b;"david" in `.[`active_players][;0];"correct winner was removed"];
    result ,: .testutils.assertEqual[1b;all ("helen";"bob") in `.[`active_players][;0];"correct winner was removed"];

    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_SECRETS;"next round, waiting for secrets"];
    result ,: .testutils.assertEqual[2;count `.[`secrets];"waiting only for secrets from active players"];
    result ,: .testutils.assertEqual[1b;all null `.[`secrets][;0];"secrets not populated for active players"];

     `.[`submitSecret][3;2]; `.[`submitSecret][3;3];
    `.[`whileWaitingForSecrets][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"next round, waiting for secrets"];

    result ,: .testutils.assertEqual[-2;last first `.[`guesses];"player two to guess first"];
    
    failmsg:.[`.[`submitGuess];(3;1);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: not your turn*";"eliminated player cannot guess"];
    failmsg:.[`.[`submitGuess];(3;3);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: not your turn*";"player cannot guess out of turn"];
    failmsg:.[`.[`submitGuess];(3;99);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: not your turn*";"unxpected player cannot guess"];
    failmsg:.[`.[`submitGuess];("nine";2);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "*guess must be an integer";"guess must be an integer"];
    
    `.[`submitGuess][4;2];    
    failmsg:.[`.[`submitGuess];(5;2);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: cannot guess twice";"cannot guess twice"];
    `.[`whileWaitingForGuess][.z.z+1000;.z.z+2000;.z.z];
    result ,: .testutils.assertEqual[.state.CURRENT;.state.WAITING_FOR_GUESS;"one guessed, next to go"];    
    result ,: .testutils.assertEqual[-3;last first `.[`guesses];"player two to guess first"];

    failmsg:.[`.[`submitGuess];(4;2);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: not your turn*";"player guessed previously"];
    failmsg:.[`.[`submitGuess];(4;3);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "failed: your guess was already taken*";"cannot repeat another players guess"];
    failmsg:.[`.[`submitGuess];(`nine;3);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "*guess must be an integer";"guess must be an integer"];

    flip result

  };

testApiSecurity:{

    result:();
        
    failmsg:@[`.[`filterQueries];"select from t where x = y";{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "*you can only call api functions*";"arbitrary select not allowed"];

    failmsg:@[`.[`filterQueries];(`show;`.[`all_players]);{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "*you can only call api functions*";"can't hack"];

    failmsg:@[`.[`filterQueries];(`jin;"bob");{"failed: ",x}];
    result ,: .testutils.assertEqual[1b;failmsg like "*you can only call api functions*";"can't bypass api"];

    filtered:@[`.[`filterQueries];(`api_join;"bob");{"failed: ",x}];
    result ,: .testutils.assertEqual[(`api_join;"bob");filtered;"api function passed through"];

    flip result

  };


\d .


