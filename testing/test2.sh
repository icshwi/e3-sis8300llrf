path=$(pwd)/$(dirname $0)

run() {
    eval "$path/$1"
}


# It must had a pulse before this

# check if there is values reads on AI0 and AI1
echo "*** Check values on AI0 and AI1"
N=$(caget -t $1:AI-SMNM-RBV)

# last value must be different of 0
last_value=$(caget -# $N -t $1:AI0 | cut -d ' ' -f $(($N + 1)))
[ "$last_value" != "0" ] && echo "Pass" ||  echo "***FAIL!!!***"

# last value +1 must be  0
last_plus_1=$(caget -# $(($N + 1)) -t $1:AI0 | cut -d ' ' -f $(($N + 2)))
[ "$last_plus_1" = "0" ] && echo "Pass" ||  echo "***FAIL!!!***"

# last value must be different of 0
last_value=$(caget -# $N -t $1:AI1 | cut -d ' ' -f $(($N + 1)))
[ "$last_value" != "0" ] && echo "Pass" ||  echo "***FAIL!!!***"

# last value +1 must be  0
last_plus_1=$(caget -# $(($N + 1)) -t $1:AI1 | cut -d ' ' -f $(($N + 2)))
[ "$last_plus_1" = "0" ] && echo "Pass" ||  echo "***FAIL!!!***"

# Check attenuator using values with more digits
echo "*** Check attenuator with value 12.78"
caput $1:AI-ATT 12.78 > /dev/null
state=12.5
sleep 2

run "check $state $(caget -t $1:AI0-ATT-RBV) 'Test on attenuator 0 with 12.78'"

run "check $state $(caget -t $1:AI1-ATT-RBV) 'Test on attenuator 1 with 12.78'"

run "check $state $(caget -t $1:AI2-ATT-RBV) 'Test on attenuator 2 with 12.78'"

run "check $state $(caget -t $1:AI3-ATT-RBV) 'Test on attenuator 3 with 12.78'"

run "check $state $(caget -t $1:AI4-ATT-RBV) 'Test on attenuator 4 with 12.78'"

run "check $state $(caget -t $1:AI5-ATT-RBV) 'Test on attenuator 5 with 12.78'"

run "check $state $(caget -t $1:AI6-ATT-RBV) 'Test on attenuator 6 with 12.78'"

run "check $state $(caget -t $1:AI7-ATT-RBV) 'Test on attenuator 7 with 12.78'"

state=12.75
run "check $state $(caget -t $1:AI8-ATT-RBV) 'Test on attenuator 8 with 12.78'"

