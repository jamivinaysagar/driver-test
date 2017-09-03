#!/bin/sh

FLAG=$1

case $FLAG in
"-i")
    RUN_INTERACTIVE=1
    ;;
"-a")
    RUN_AUTOMATED=1
    ;;
"")
    RUN_INTERACTIVE=1
    RUN_AUTOMATED=1
    ;;
*)
    echo "Usage:"
    echo "    $0 [-i -a]"
    echo "       -i: Interactive tests only"
    echo "       -a: Automated tests only"
    exit 1
esac

DATE=$(date "+%Y%m%d%H%M%S")

LOGDIR=./logs/$DATE/
INTERACTIVELOG=$LOGDIR/interactive.log

Normal='\e[0m'
BGreen='\e[1;32m'
BRed='\e[1;31m'

function run_test
{
    TEST_NAME=$1
    TEST_PATH=$2
    TEST_PARAMS=$3
    TEST_PROMPT_PRE=$4
    TEST_PROMPT_POST=$5
    TEST_COMMAND="$TEST_PATH $TEST_PARAMS"
    TEST_NAME_SAFE=$(echo $TEST_NAME | sed -e 's/ /_/g')
    LOGFILE=$LOGDIR/$TEST_NAME_SAFE.log

    echo "$TEST_NAME" > $LOGFILE
    echo "" >> $LOGFILE
    echo "$(date)" >> $LOGFILE
    echo "============================" >> $LOGFILE

    unset INTERACTIVE

    if [ -n "$TEST_PROMPT_PRE" ]; then
        INTERACTIVE=1
        echo "Interactive Test $TEST_NAME"
        unset RESULT

        while [ -z "$RESULT" ]; do
            echo "   $TEST_PROMPT_PRE"

            if [ -z "$TEST_PROMPT_POST" ]; then
                echo -n "   Press any key to continue"
                read
            else
                sleep 3
            fi

            $TEST_COMMAND >> $LOGFILE 2>&1
            RESULT=$?

            if [ -n "$TEST_PROMPT_POST" ]; then
                echo -n "   $TEST_PROMPT_POST (y/n/r[etry]): "
                read RESPONSE
                if [[ "$RESPONSE" == "y" ]]; then
                    RESULT=0
                elif [[ "$RESPONSE" == "n" ]]; then
                    RESULT=1
                else
                    unset RESULT
                fi
            fi
        done

       echo ""
        printf "%-20s: " "$TEST_NAME" >> $INTERACTIVELOG
    else
        printf "%-20s: " "$TEST_NAME"
        $TEST_COMMAND >> $LOGFILE 2>&1
        RESULT=$?
    fi

    if [ "$RESULT" == 0 ]; then

        echo "============================" >> $LOGFILE
        echo "SUCCESS" >> $LOGFILE

        if [ -n "$INTERACTIVE" ]; then
            echo -en "${BGreen}SUCCESS${Normal}\n" >> $INTERACTIVELOG
            tail -n 1 $INTERACTIVELOG
            echo ""
        else
            echo -en "${BGreen}SUCCESS${Normal}\n"
        fi
    else
        echo "============================" >> $LOGFILE
        echo "FAILURE" >> $LOGFILE

        if [ -n "$INTERACTIVE" ]; then
            echo -en "${BRed}FAILURE${Normal}\n" >> $INTERACTIVELOG
            tail -n 1 $INTERACTIVELOG
            echo ""
        else
            echo -en "${BRed}FAILURE${Normal}\n"
        fi
    fi
}

mkdir -p $LOGDIR

echo "Test Run"
echo "$DATE"
echo ""

if [ -n "$RUN_INTERACTIVE" ]; then
    echo "Interactive Tests"
    echo "================="
    echo ""

    source ./interactive.conf

    echo "Interactive Test Results"
    echo "========================"
    echo ""
    cat $INTERACTIVELOG
fi

if [ -n "$RUN_AUTOMATED" ]; then
    echo ""
    echo "Automated Tests"
    echo "==============="
    echo ""

    source ./automated.conf
fi
