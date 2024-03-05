#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Title
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_SERVICES() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # List services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-3]) APPOINTMENT_DETAILS ;;
    *) GET_SERVICES "I could not find that service. What would you like today?" ;;
  esac
}

APPOINTMENT_DETAILS() {
  # Get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]; then
    # Get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  # Get appointment details
  # Get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')

  # Get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

  # Get appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  # Insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

GET_SERVICES
