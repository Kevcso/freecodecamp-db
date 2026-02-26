#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Display services
  echo "Welcome to My Salon, how can I help you?"
  echo ""
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done
  echo ""

  # Get service selection
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      # Get name and insert new customer
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
    fi

    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Get appointment time
    echo -e "\nWhat time would you like your $(echo $SERVICE | xargs), $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment
    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

    echo -e "\nI have put you down for a $(echo $SERVICE | xargs) at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU