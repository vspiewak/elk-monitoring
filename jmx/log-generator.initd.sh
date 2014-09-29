#!/bin/sh
#
# init script for a Java application
#

# Check the application status
#
# This function checks if the application is running
check_status() {

  # Running ps with some arguments to check if the PID exists
  # -C : specifies the command name
  # -o : determines how columns must be displayed
  # h : hides the data header
  s=`ps -eaf | grep '/opt/log-generator/log-generator.jar' | grep -v grep | awk '{ print $2 }'`

  # If somethig was returned by the ps command, this function returns the PID
  if [ -n "$s" ] ; then
    return $s
  fi

  # In any another case, return 0
  return 0

}

# Starts the application
start() {

  # At first checks if the application is already started calling the check_status
  # function
  check_status

  # $? is a special variable that hold the "exit status of the most recently executed
  # foreground pipeline"
  pid=$?

  if [ $pid -ne 0 ] ; then
    echo "The application is already started"
    exit 1
  fi

  # If the application isn't running, starts it
  echo -n "Starting log-generator: "

  # Redirects default and error output to a log file
  JAVA_OPTS="$JAVA_OPTS -Djavax.management.builder.initial="
  JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
  JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=9010"
  JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.local.only=false"
  JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
  JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"

  java $JAVA_OPTS -jar /opt/log-generator/log-generator.jar -n 10 -r 1000 -e >> /var/log/log-generator/app.log 2>&1 &

  echo "OK"
}

# Stops the application
stop() {

  # Like as the start function, checks the application status
  check_status

  pid=$?

  if [ $pid -eq 0 ] ; then
    echo "Application is already stopped"
    exit 1
  fi

  # Kills the application process
  echo -n "Stopping log-generator: "
  kill -9 $pid &
  echo "OK"
}

# Show the application status
status() {

  # The check_status function, again...
  check_status

  # If the PID was returned means the application is running
  if [ $? -ne 0 ] ; then
    echo "Application is started"
  else
    echo "Application is stopped"
  fi

}

# Main logic, a simple case to call functions
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart|reload)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|reload|status}"
    exit 1
esac

exit 0
