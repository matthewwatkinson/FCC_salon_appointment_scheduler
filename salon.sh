#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

#echo $($PSQL "SELECT service_id, name FROM services")

echo -e "~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME;
  do
    echo -e "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU

read SERVICE_ID_SELECTED
MAX_SERVICE=$($PSQL " SELECT MAX(service_id) FROM services")

if [[ $SERVICE_ID_SELECTED > $MAX_SERVICE ]]
then
  echo "I could not find that service. What would you like today?"
  MAIN_MENU
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $GET_CUSTOMER_ID ]]
then
  #it's new so add a customer
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  read SERVICE_TIME
  $($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$NEW_CUSTOMER_ID', '$SERVICE_ID_SELECTED')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
  #existing customer
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$GET_CUSTOMER_ID")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  read SERVICE_TIME
  $($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', '$NEW_CUSTOMER_ID', '$SERVICE_ID_SELECTED')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

fi
