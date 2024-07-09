#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

if [[ ${#USERNAME} -gt 22 ]]; then
  echo "The username must have at most 22 characters."
  exit 1
fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]; then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  GUESSES=$(( GUESSES + 1 ))

  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    echo "Parabéns! Você adivinhou o número secreto em $GUESSES tentativas."
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")

BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
if [[ $GUESSES -eq $BEST_GUESS ]]; then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE games SET best_game='true' WHERE user_id=$USER_ID AND guesses=$GUESSES")
fi