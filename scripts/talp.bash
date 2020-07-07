#!/bin/bash

#Control variables
PROCESS_ITER=0

#Data variables
SUM_ITER=0
NELEM_ITER=0
N_ITER=1
MAX_ITER=0

function line_is_talp(){
	if echo $1 | awk '{print $1}' | grep TALP 2>1 &>/dev/null; then
		echo 1
	else
		echo 0
	fi
}

function line_is_cantera(){
	if echo $1 | awk '{print $1}' | grep Cantera 2>1 &>/dev/null; then
		echo 1
	else
		echo 0
	fi
}

function update_data(){
	value=`echo $1 | awk '{print $2}'`

	SUM_ITER=$(( SUM_ITER + value ))
	NELEM_ITER=$(( NELEM_ITER + 1 ))

	if [[ $MAX_ITER < $value ]]; then
		MAX_ITER=$value
	fi	
}

function print_data(){
	avg=`echo "scale=3;$SUM_ITER/$NELEM_ITER" | bc -l`
	avgmax=`echo "scale=3;$avg/$MAX_ITER" | bc -l`
	echo "$N_ITER $avg $MAX_ITER $avgmax"
}

while read line; do
	if [[ $PROCESS_ITER == 1 ]]; then
		if [[ $(line_is_talp "$line") == 1 ]]; then
			update_data "$line"
				
		elif [[ $(line_is_cantera "$line") == 1 ]]; then
			continue
		else
			PROCESS_ITER=0;
			print_data 
			N_ITER=$(( N_ITER + 1 ))
		fi
	else
		if [[ $(line_is_talp "$line") == 1 ]]; then
			PROCESS_ITER=1;
			SUM_ITER=0
			NELEM_ITER=0
			MAX_ITER=0

			update_data "$line"
		fi

	fi
done < $1
