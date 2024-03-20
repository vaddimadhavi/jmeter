#!/bin/bash

function print_usage {
    cat <<EOT
        Run JMeter Tests

        Options:
        -h print usage information and exit
        -v print the version information and exit
        -u Opens JMeter in UI with loaded environment variables
        -t Specify .jmx file to run (defaults to ./testAPI.jmx)
        -e [system][nonprod][prod]Environemt to test (defaults to system)
EOT        
}

function set_jmeter_vars() {
    # read envs/$1.json
    filename="$1.env"
    source ./envs/$filename

    if [[-f ./envs/creds.env]]; then
        source ./envs/creds.env
    else
        echo "No client creds available. Please create a creds.env file in your directory." ; exit 1
    fi    
}

function set_test_file() {
    if ! [[-f ./$1 ]]; then
        echo "Specified test file ./$1 does not exist, please check your path"; exit 1
    else 
        JMX_FILE=$1;
    fi    
}

function clean_up () {
    rm -f test-output.log
    rm -rf reports
}

#set defaults
clean_up
unset ENV
set_env 'system'
JMX_FILE='testAPI.jmx'

#set jmeter options
# -e for generating reports
# -n for running CLI mode
JMETER_ARGS=('-e' '-n')

while getopts 'he:ut:' opt; do
    case "${opt}" in
        h) print_usage; exit 1 ;;
        e) set_env $OPTARG ;;
        u) unset JMETER_ARGS[1] ;;
        t) set_test_file $OPTARG ;;
        *) print_usage; exit 1 ;;
    esac
done

#export necessary env variables
set_jmeter_vars $ENV

echo -e "Running Madhavi's JMETER tests using ./$JMX_FILE\n";

jmeter "${JMETER_ARGS[@]}" \
     -JREQUEST_PROTOCOL=$REQUEST_PROTOCOL \
     -JREQUEST_HOST=$REQUEST_HOST \
     -JPATH_PREFIX=$PATH_PREFIX \
     -JENV=$ENV \
     -JAUTH_CLIENT_ID=$CLIENT_ID \
     -JAUTH_CLIENT_SECRET=$CLIENT_SECRET \
     -l test-output.log \
     -o reports \
     -t ./$JMX_FILE

