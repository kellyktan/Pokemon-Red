/* Pokemon Red, by Kelly Tan. */

:- dynamic i_am_at/1, badge/1, at/2, holding/1, turn_count/1.
:- retractall(badge(_)), retractall(i_am_at(_)), retractall(alive(_)),
        retractall(at(_, _)), retractall(holding(_)).

i_am_at(pallet_town).

turn_count(0).

path(pallet_town, n, viridian_city).
path(pallet_town, s, cinnabar_island).
path(viridian_city, n, pewter_city).
path(viridian_city, s, pallet_town).
path(viridian_city, w, victory_road).
path(pewter_city, e, cerulean_city).
path(pewter_city, s, viridian_city).
path(cerulean_city, s, saffron_city).
path(cerulean_city, w, pewter_city).
path(saffron_city, n, cerulean_city).
path(saffron_city, e, lavender_town).
path(saffron_city, s, vermillion_city).
path(saffron_city, w, celadon_city).
path(lavender_town, s, silence_bridge).
path(lavender_town, w, saffron_city).
path(celadon_city, e, saffron_city).
path(celadon_city, s, cycling_road).
path(vermillion_city, n, saffron_city).
path(vermillion_city, e, silence_bridge).
path(silence_bridge, n, lavender_town).
path(silence_bridge, s, fuschia_city).
path(silence_bridge, w, vermillion_city).
path(cycling_road, n, celadon_city).
path(cycling_road, e, fuschia_city).
path(fuschia_city, n, silence_bridge).
path(fuschia_city, s, seafoam_islands).
path(fuschia_city, w, cycling_road).
path(seafoam_islands, n, fuschia_city).
path(seafoam_islands, w, cinnabar_island).
path(cinnabar_island, n, pallet_town).
path(cinnabar_island, e, seafoam_islands).
path(victory_road, n, indigo_plateau).
path(victory_road, e, viridian_city).
path(indigo_plateau, s, victory_road).

gym(pewter_city).
gym(cerulean_city).
gym(vermillion_city).
gym(celadon_city).
gym(fuschia_city).
gym(saffron_city).
gym(cinnabar_island).
gym(viridian_city).

badge_seq(pewter_city).
badge_seq(cerulean_city) :- badge(pewter_city).
badge_seq(vermillion_city) :- badge(cerulean_city).
badge_seq(celadon_city) :- badge(cerulean_city).
badge_seq(fuschia_city).
badge_seq(saffron_city).
badge_seq(cinnabar_island) :- badge(fuschia_city).
badge_seq(viridian_city) :-
        badge(pewter_city),
        badge(cerulean_city),
        badge(vermillion_city),
        badge(celadon_city),
        badge(fuschia_city),
        badge(saffron_city),
        badge(cinnabar_island).

at(bicycle, cerulean_city).
at(ancient_box, lavender_town).


/* These rules describe how to pick up an object. */

take(X) :-
        holding(X),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(holding(X)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(ancient_box) :-
        holding(ancient_box),
        i_am_at(Place),
        retract(holding(ancient_box)),
        assert(at(pokeflute, Place)),
        write('The box broke open to reveal a pokeflute!'),
        !, nl.

drop(X) :-
        holding(X),
        i_am_at(Place),
        retract(holding(X)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You aren''t holding it!'),
        nl.


/* These rules describe how to battle a gym. */

battle_gym :-
        i_am_at(Place),
        \+ gym(Place),
        write('There''s no gym here.'),
        !, nl.

battle_gym :-
        i_am_at(Place),
        gym(Place),
        badge(Place),
        write('You''ve already beaten this gym!'),
        !, nl.

battle_gym :-
        i_am_at(Place),
        gym(Place),
        \+ badge_seq(Place),
        write('You don''t have enough badges to battle this gym.'),
        !, nl.

battle_gym :-
        i_am_at(Place),
        gym(Place),
        badge_seq(Place),
        assert(badge(Place)),
        write('Congratulations! You beat the '),
        write(Place),
        write(' gym!'),
        !, nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, cycling_road),
        \+ holding(bicycle),
        write('You cannot go on the cycling road without a bicycle.'),
        !, nl, nl, look.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, silence_bridge),
        \+ holding(pokeflute),
        write('There seems to be a large sleeping POKEMON blocking the bridge'),
        write('. Maybe it can be woken with a pokeflute.'),
        !, nl, nl, look.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, cinnabar_island),
        \+ badge(fuschia_city),
        write('You cannot surf across the water without the Fuschia City gym '),
        write('badge.'),
        !, nl, nl, look.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, seafoam_islands),
        \+ badge(fuschia_city),
        write('You cannot surf across the water without the Fuschia City gym '),
        write('badge.'),
        !, nl, nl, look.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, indigo_plateau),
        \+ badge(viridian_city),
        write('You do not have enough gym badges to face the Elite Four.'),
        !, nl, nl, look.

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        retract(turn_count(X)),
        Y is X + 1,
        assert(turn_count(Y)),
        !, look.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        gym_located_at(Place),
        notice_objects_at(Place),
        turn_count(X),
        nl, blue(X),
        nl.


/* This rule tells BLUE's progress. */

blue(_) :-
        i_am_at(indigo_plateau),
        write('BLUE: Why? Why did I lose? Darn it! You''re the new POKEMON '),
        write('LEAGUE champion! Although I don''t like to admit it.'), !, nl.

blue(X) :-
        X > 20,
        write('BLUE: Snooze you lose! I''m became the POKEMON LEAGUE '),
        write('champion first!'),
        !, nl, finish.

blue(X) :-
        X > 15,
        write('BLUE: What''s taking you so long? I already have 8 gym badges!'),
        !, nl.

blue(X) :-
        X > 10,
        write('BLUE: You''re making this too easy!  I''ll definitely become '),
        write('champion before you!'), !, nl.

blue(X) :-
        X > 5,
        write('BLUE: I''m so going to beat you to becoming champion!  I '),
        write('have a bunch of badges already!'), !, nl.

blue(_) :-
        write('BLUE: Hey RED!  Let''s make this more interesting!  We''ll '),
        write('race to see who can become the POKEMON LEAGUE champion first!'),
        !, nl.

/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This checks if there is a gym here. */

gym_located_at(Place) :-
        gym(Place),
        write('There is a POKEMON gym here.'), nl,
        fail.

gym_located_at(_).


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n.  s.  e.  w.     -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('battle_gym.        -- to battle a gym and earn a badge.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('i.                 -- to tell what you are currently holding'),
        nl,write('                      and what badges you have.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


/* Inventory command.  Prints what you're holding as well as the badges you have
   obtained. */

i :-
        describe_holding, nl,
        describe_badges, nl.

describe_holding :-
        write('You are holding the following items:'), nl,
        holding(Item),
        write(Item), nl, fail.

describe_holding.

describe_badges :-
        write('You have the gym badges from the following cities:'), nl,
        badge(Badge),
        write(Badge), nl, fail.

describe_badges.


/* This rule prints out instructions and tells where you are. */

start :-
        write('Hello there! Welcome to the world of POKEMON! My name is OAK! '),
        write('People call me the POKEMON PROF! This world is inhabited by '),
        write('creatures called POKEMON! For some people, POKEMON are pets. '),
        write('Others use them for fights. Myself... I study POKEMON as a '),
        write('profession.'), nl,
        write('So your name is RED? This is my grandson. He''s been your '),
        write('rival since you were a baby. ...Erm, what is his name again? '),
        write('That''s right! I remember now! His name is BLUE! '),
        write('RED! Your very own POKEMON legend is about to unfold! A world '),
        write('of dreams and adventures with POKEMON awaits! Let''s go!'), nl,
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(pallet_town) :-
        write('You are in Pallet Town. Shades of your '),
        write('journey await!'), nl,
        write('Viridian City is to the north and Cinnabar Island is to the '),
        write('south across the water.'), nl.

describe(viridian_city) :-
        write('You are in Viridian City. The Eternally Green Paradise.'), nl,
        write('Pewter City is to the north, Pallet Town is to the south, and '),
        write('Victory Road is to the west.'), nl.

describe(pewter_city) :-
        write('You are in Pewter City. A Stone Gray City.'), nl,
        write('Cerulean City is to the east and Viridian City is to the '),
        write('south.'), nl.

describe(cerulean_city) :-
        write('You are in Cerulean City. A Mysterious, Blue Aura Surrounds '),
        write('It.'), nl,
        write('Saffron City is to the south and Pewter City is to the east.'),
        nl.

describe(celadon_city) :-
        write('You are in Celadon City. The City of Rainbow Dreams.'), nl,
        write('Saffron City is to the east and the Cycling Road is to the '),
        write('south.'), nl.

describe(saffron_city) :-
        write('You are in Saffron City. Shining, Golden Land of Commerce.'), nl,
        write('Cerulean City is to the north, Lavender Town is to the east, '),
        write('Vermillion City is to the south, and Celadon City is to the '),
        write('west.'), nl.

describe(lavender_town) :-
        write('You are in Lavender Town. The Noble Purple Town.'), nl,
        write('Silence Bridge is to the south and Saffron City is to the '),
        write('west.'), nl.

describe(vermillion_city) :-
        write('You are in Vermillion City. The Port of Exquisite Sunsets.'), nl,
        write('Saffron City is to the north and Silence Bridge is to the '),
        write('east.'), nl.

describe(silence_bridge) :-
        write('You are on Silence Bridge. The sport fishing area.'), nl,
        write('Lavender Town is to the north, Fuschia City is to the south, '),
        write('and Vermillion City is to the west.'), nl.

describe(cycling_road) :-
        write('You are on the Cycling Road. A favorite hangout for '),
        write('motorcyclists and bicyclists alike.'), nl,
        write('Celadon City is to the north and Fuschia City is to the east.'),
        nl.

describe(fuschia_city) :-
        write('You are in Fuschia City. Behold! It''s Passion Pink!'), nl,
        write('Silence Bridge is to the north, the Seafoam Islands are to '),
        write('the south across the water, and the Cycling Road is to the '),
        write('west.'), nl.

describe(seafoam_islands) :-
        write('You are on the Seafoam Islands. The Twin Islands.'), nl,
        write('Fuschia City is to the north across the water and Cinnabar '),
        write('Island is to the west across the water.'), nl.

describe(cinnabar_island) :-
        write('You are on Cinnabar Island. The Fiery Town of Burning Desire.'),
        nl,
        write('Pallet Town is to the north across the water and the Seafoam '),
        write('Islands are to the east across the water.'), nl.

describe(victory_road) :-
        write('You are on Victory Road. Traveled by all Trainers aiming for '),
        write('the top.'), nl,
        write('The Indigo Plateau is to the north and Viridian City is to '),
        write('the east.'), nl.

describe(indigo_plateau) :-
        write('You are at the Indigo Plateau! The ultimate goal of Trainers! '),
        write('The highest POKEMON authority!'), nl,
        write('Congratulations!  You are the new POKEMON league champion!'),
        nl, finish.
