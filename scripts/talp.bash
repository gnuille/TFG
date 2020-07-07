#!/bin/bash

#Control variables
PROCESS_ITER=0

#Data variables
SUM_ITER=0
NELEM_ITER=0
N_ITER=1
declare -a NODE_AVG
SUM_NODE=0
MAX_ITER=0
N_NODES=0
FIRST_IT=1

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

function divide(){
	echo `echo "scale=3;$1/$2" | bc -l`
}

function update_data(){
	value=`echo $1 | awk '{print $2}'`
	SUM_ITER=$(( SUM_ITER + value ))
	SUM_NODE=$(( SUM_NODE + value ))

	NELEM_ITER=$(( NELEM_ITER + 1 ))


	if [ "$MAX_ITER" -lt "$value" ]; then
		MAX_ITER=$value
	fi	


	if [[ $(( NELEM_ITER % 48 )) == 1 ]]; then
		NODE_AVG+=(`divide $SUM_NODE 48`)
		SUM_NODE=0
		N_NODES=$(( N_NODES + 1 ))
	fi
}

function print_data(){
	
	if [[ $FIRST_IT == 1 ]]; then
		echo -e -n "IT\tAVG\tMAX\tAVG/MAX"
		for i in `seq $N_NODES`; do
			echo -e -n "\t$i"		
		done
		echo 

		FIRST_IT=0
	fi

	avg=`divide $SUM_ITER $NELEM_ITER`
	avgmax=`divide $avg $MAX_ITER`
	echo -e -n "$N_ITER\t$avg\t$MAX_ITER\t$avgmax"
	for i in "${NODE_AVG[@]}"; do
		echo -e -n "\t$i"
	done
	echo
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
			unset NODE_AVG
			declare -a NODE_AVG
			update_data "$line"
		fi
	fi
done < $1
