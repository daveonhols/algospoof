
.state.WAITING_FOR_PLAYERS:"Waiting for players";
.state.WAITING_FOR_SECRETS:"Waiting for secrets";
.state.WAITING_FOR_GUESS:"Waiting for guess";
.state.NO_STATE:"";

.state.CURRENT:.state.NO_STATE;

init:{
    show "in init";
    `maxitems set 3;
    `all_players set ();
    `active_players set ();
    `guessed set ();
    `guesses set ();
    `secrets set ();
  };

dead:{[msg]
    '"dead=",msg;
  };

filterQueries:{[val]
    if[not (count val) within (1;3);'"you can only call api functions"];
    if[not val[0] in `api_join`api_guess`api_secret;'"you can only call api functions"];
    val
  };


whileWaitingForPlayers:{[warnTime;critTime;t]
    show "Waiting for players.  Currently have ",  ", " sv all_players[;0]    
  };

whileWaitingForSecrets:{[warnTime;critTime;t]
    show "secrets: ", -3!secrets;
    if[all not null secrets[;0];:nextGuess[]];
    if[.z.z>critTime;:dead["out of time waiting for secrets"]];
    if[.z.z>warnTime;
        msgPlayer[;`information;"Hurry up, we are waiting for your secret!"]each secrets[;2] where null secrets[;0];
        msgPlayer[;`nag_submit_secret;maxitems]each secrets[;2] where null secrets[;0]];
  };

whileWaitingForGuess:{[warnTime;critTime;t]
    show "guesses: ", -3!guesses;
    show "guessed: ", -3!guessed;

    if[.z.z>critTime;:dead["out of time waiting for guess"]];
    if[.z.z>warnTime;
        msgPlayer[;`information;"Hurry up, we are waiting for your guess!"]each secrets[;2] where null secrets[;0];
        msgPlayer[;`nag_submit_guess;guessed]each secrets[;2] where null secrets[;0]];
    
    if[not null guesses[0][0];
        handleGuess[]];
  };


handleGuess:{

    guessed ,:: enlist first guesses;
    `guesses set 1_guesses;
    nextGuess[];

  };

api_guess:{[guess]
    submitGuess[guess;.z.w];
  };

/ guess:5;hdl:2
submitGuess:{[guess;hdl]
    
    validateType[guess;-7h;"guess must be an integer"];
    if[not hdl=neg last first guesses;'"not your turn to guess"];
    if[not null first first guesses;'"cannot guess twice"];
    if[guess in guessed[;0];'"your guess was already taken"];
    guesses[0;0]:guess;

  };

/ secret:3;hdl:1
submitSecret:{[secret;hdl]
    validateType[secret;-7h;"secret must be an integer"];
    whoidx:first where hdl = abs secrets[;2];
    if[null whoidx;'"a secret from you is not required"];
    who:secrets[;1][whoidx];
    if[not null secrets[;0][whoidx];'"You already submitted, please wait"];
    if[not secret within (0;maxitems);'"Your secret must be less than ",string maxitems];
    secrets[whoidx;0]:secret;
  };

api_secret:{[secret]
    submitSecret[secret;.z.w];
  };

startRound:{
    `secrets set {(0N,x)}each active_players;
    if[1=count active_players;
        :loser[]];
    `guesses set {(0N,x)}each active_players;
    `guessed set ();
    msgActive[`players;active_players[;0]];
    msgActive[`submit_secret;maxitems];

    changeState[.state.WAITING_FOR_SECRETS;whileWaitingForSecrets[.z.z+00:00:20;.z.z+00:00:30]];

  };

kickPlayers:{
    show "kicking ... ";
    {x"";hclose x}each neg all_players[;1];
  };

loser:{[]
    show "dealing with loser";
    msgPlayer[active_players[0;1];`information;"You lost"];
    msgAll[`information;"the last remaining player was ",active_players[0;0]];
    msgAll[`loser;active_players[0;0]];
    msgAll[`game_over;"game over"];
    kickPlayers[];
    init[];
    changeState[.state.WAITING_FOR_PLAYERS;whileWaitingForPlayers[.z.z+00:55:00;.z.z+01:00:00]];
  };

nextGuess:{[]
    if[0=count guesses;:endRound[]];
    msgPlayer[guesses[0][2];`information;"your turn to guess, guesses before you: ",-3!2#/:guessed];
    msgPlayer[guesses[0][2];`please_guess;2#/:guessed];
    changeState[.state.WAITING_FOR_GUESS;whileWaitingForGuess[.z.z+00:00:20;.z.z+00:00:30]];

  };

endRound:{[]
    msgAll[`all_guesses;-1_/:guessed];
    msgAll[`reveal;-1_/:secrets];
    secret_total:sum secrets[;0];
    correct:where guessed[;0]=secret_total;
    if[1<count correct;dead["somehow we had more than one correct answer"]];
    $[1=count correct;
        roundWinner[first correct];
        roundNoWinner[]];
    startRound[];    
 };


roundNoWinner:{[]

    msgAll[`information;"The round finished wit no winner.  Continuing"];
    msgAll[`round_no_winner;"no winner"];

  };

roundWinner:{[winner]
    winnerName:first active_players[winner];
    winnerHdl:last active_players[winner];
    msgPlayer[winnerHdl;`information;"You won and are eliminated.  No gloating"];
    msgPlayer[winnerHdl;`you_won_round;"no gloating"];
    `active_players set active_players[(til count active_players)except winner];
    msgAll[`information;winnerName, " won the round, well done"];
    msgAll[`round_winner;winnerName];
    
    
  };

validateType:{[val;expectedType;reason]
    if[not expectedType = type val;'"wrong type passed: ", reason]
  };

join:{[user;hdl]
    validateType[user;10h;"user name must be a string"];
    if[any all_players[;0] ~\: user;'"Your user name was already taken, please choose another"];
    all_players ,:: enlist (user;neg hdl);    
 };

api_join:{[user]
    join[user;.z.w];
  };

shufflePlayers:{
    `all_players set (neg count all_players)?all_players;
  };

msgAll:{[operation;argument]
    msgPlayer[;operation;argument] each all_players[;1];
  };

msgActive:{[operation;argument]
    msgPlayer[;operation;argument] each active_players[;1];
  };

msgPlayer:{[hdl;operation;argument]
    hdl(operation;argument)
  };

changeState:{[state;timer]
    show "changing state: ", state;
    .state.CURRENT:state;
    `.z.ts set timer;
  };


startGame:{
    shufflePlayers[];
    
    `active_players set all_players;
    
    msgAll[`information;"The game is starting with players ", ", " sv active_players[;0]];
    msgAll[`information;"You have thirty seconds to submit the secret number of coins you are holding"];
    
    startRound[];
    
  };

init[];
