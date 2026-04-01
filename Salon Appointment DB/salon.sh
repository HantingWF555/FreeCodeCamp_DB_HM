#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Start with welcome
echo -e "\n~~~~~ MY SALON ~~~~~\n"

customer_info() {
# ASK for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# check our customer's phone number to see if they're existing customers
# If yes, ask for the appointment info and insert to appointments DB
# If not, insert into customers DB and appointments DB

if [[ -z $CUSTOMER_NAME ]]
then
#ask for customer info
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

# Inser the new customer info to customers
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Find the service based on service id and show customer result
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# After checking the existing customer, ask for appointment info
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Since we have already asked the service id at the beginning, query for customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Nice! Since we have all the information and we can insert them and tell our customer
INSERT_APP_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) \
VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")



echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
exit

}

# set the service menu 
service_menu() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?"
  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"

  read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    service_menu "I could not find that service. What would you like today?"
else
customer_info
  fi
}

service_menu

customer_info















