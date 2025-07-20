#!/bin/bash

set -e
DOTENV_FILE="$HOME/.env"
# create empty dot env file
echo "" > $DOTENV_FILE

while IFS='=' read -r -d '' n v; do
    if [[ $n == TASK_WEB_* ]]; then
        echo "${n/TASK_WEB_/}=\"$v\"" >> $DOTENV_FILE
    fi
done < <(env -0)

# check if taskrc exists.
if [[ ! -f "$TASKRC" ]]; then
    echo "yes" | task || true
fi

# Start taskwarrior-web
cd $HOME/bin
exec ./taskwarrior-web &

# Set up task sync to run every 3 mins
while true; do /usr/bin/task sync; sleep 180; done &
# pid=$!
# trap 'kill -SIGTERM $pid; wait $pid' SIGTERM
# wait $pid

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
