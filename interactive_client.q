args:.z.x;
conn:hopen `$.z.x 0;
me:.z.x 1;
conn(`api_join;me);

information:show;
players:{show "players in this round are: ", ", " sv x};
nag_submit_secret:show;
nag_submit_guess:show;

submit_secret:{
    show "submit secret from 0 to max=", string x;
    `respond set sendSecret;
  };

loser:{};
game_over:{show "game over";};
please_guess:{
    show "Previous guesses: ", " " sv {x[1]," guessed ",string x[0]} each x;
    `respond set sendGuess;
  };

round_no_winner:show;
round_winner:{};
you_won_round:show;
all_guesses:{
    show "All guesses: ", " " sv {x[1]," guessed ",string x[0]} each x
  };


reveal:{
    show "All secrets: ", " " sv {x[1]," guessed ",string x[0]} each x
  };

sendSecret:{[num]
  .[{conn(x;y)};(`api_secret;num);{show x}];
  };

sendGuess:{[num]
    .[{conn(x;y)};(`api_guess;num);{show x}];
  };

.z.pc:{exit 1};