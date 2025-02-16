#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

# echo "Appointments: $($PSQL "delete from appointments")"
# echo "Customers: $($PSQL "delete from customers")"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nServices available:\n"

  SERVICES=$($PSQL "select service_id,name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  # SERVICES_COUNT=$($PSQL "select count(*) from services")

  echo -e "\nPlease choose a service:"
  read SERVICE_ID_SELECTED

  if ! [[ $SERVICE_ID_SELECTED =~ ^1|2|3$ ]] ; then
    MAIN_MENU "The service you chose does not exist."
  else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE

    PHONE_NUMBER_EXISTS=$($PSQL "select * from customers where phone='$CUSTOMER_PHONE'")

    if [[ -z $PHONE_NUMBER_EXISTS ]] ; then
      echo -e "\nYou don't have an account. Please enter your name to create one:"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")      
    fi

    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g')

    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    echo -e "\nPlease enter service time:"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

  fi

}

MAIN_MENU
