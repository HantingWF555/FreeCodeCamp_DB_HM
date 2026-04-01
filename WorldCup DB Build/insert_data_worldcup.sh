#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# This code is aiming at inserting data from game.csv file to games and teams DB.

#Clear the data in each table first.
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

cat games.csv | while IFS=',' read YEAR ROUND WIN OPPO WIN_G OPPO_G
do
  if [[ $YEAR != "year" ]]
  then
  # Try to find team_id for winner
  WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
  
  # If nothing has found then we need to insert new values
    if [[ -z $WIN_ID ]]
    then 
    INSERT_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WIN')")

    #Show the insert result if there's inserting
      if [[ $INSERT_NAME_RESULT == "INSERT 0 1" ]]
      then
      echo "Team name '$WIN' has been inserted."
      fi

    # Update the team_id after inserting
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
    fi

    # Same logic, we need to find the team_id for opponents
    OPPO_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPO'")

    #Again, if there's no value then we need to insert again
    if [[ -z $OPPO_ID ]]
    then
      INSERT_OPPO_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPO')")

      # Show the inserting result if there's inserting
      if [[ $INSERT_OPPO_RESULT == "INSERT 0 1" ]]
      then
      echo "Team name '$OPPO' has been inserted."
      fi

      # Update the opponent ID after inserting:
      OPPO_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPO'")
    fi

    #OK, let's get into games DB
    #The first step is to find win/oppo team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPO'")

    #And then add the data to games DB
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, \
winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WIN_G, $OPPO_G, $WINNER_ID, $OPPONENT_ID)")

    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
    echo "Game $YEAR $ROUND has been inserted."
    fi

  fi

done
