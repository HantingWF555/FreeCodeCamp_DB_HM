#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

####### Check if it is existing user ######
echo -e "\nEnter your username:"
read NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username ='$NAME'")

if [[ -z $USER_ID ]]
then
# Add first time user name
  echo "Welcome, $NAME! It looks like this is your first time here."
  NAME_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")

else
# Find the record for old user
  GAME_PLAY=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guess) FROM games WHERE user_id = $USER_ID")

  echo -e "Welcome back, $NAME! You have played $GAME_PLAY games, and your best game took $BEST_GAME guesses."
fi

######## Grab the user_id again for the first time users #########
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username ='$NAME'")

######### Time to guess number ###########
SECRET=$(( (RANDOM% 1000) + 1 ))
GUESS_COUNT=0

echo -e "\nGuess the secret number between 1 and 1000:\n"

while true 
do
  read GUESS_NUM

# Check if input is integer
  if [[ ! $GUESS_NUM =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

# Add one to guess count each time 
  ((GUESS_COUNT++))

# If the input is integer, then start check the guess 
  if [[ $GUESS_NUM -eq $SECRET ]]
  then
    break
  elif [[ $GUESS_NUM -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  else 
    echo "It's higher than that, guess again:"
  fi
done

####### Congratulations ########
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job!"

###### After the guess we need to insert the info to games ########
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(guess, user_id) VALUES($GUESS_COUNT, $USER_ID)")