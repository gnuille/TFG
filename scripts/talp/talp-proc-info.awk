#!/bin/awk -f

#########################################################
#							#		
#	File: talp-proc-info.awk                        #
#	Author: Guillem Ramírez Miranda			#
#	Purpose: Get timming metrics of each process	#
#							#
#########################################################

#Check if array is empty then assign value
#If array used then add the value
function check_add(arr, node, val){
  if(arr[node] == ""){
    arr[node]=val
  }else{
    arr[node]+=val
  }
}

#Check if array is empty or new value is maximum and assign value
function check_max(arr, node, val){
  if(arr[node] == "" || arr[node] < val){
    arr[node]=val
  }
}

#Check if array field is empty and inc counter
function check_inc(arr, node, cnt){
  if(arr[node] == "") cnt=cnt+1
  return cnt
}

#Find the maximum uint in the array arr, store the maximum in ret
function find_max(arr){
  ret=0
  for (i in arr){
    if(arr[i] > ret) ret=arr[i] 
  }
  return ret
}

#Sum up all the values of array and return
function sum_arr(arr){
  sum=0
  for (i in arr){
    sum=sum+arr[i]
  }
  return sum
}

BEGIN {
	#separate by words " " and dlb fields ":"
	FS="[ |:]+"
	#counter for POP metrics
	nprocs=0
  nnodes=0
}
{

	#Node is first dlb field.
	node=$1
	#Rank is the second dlb field.
	rank=$2

	#Unique id
	id=$1 $2

	#Elapsed time is always the first for each process.
	#We set to zero each metric counter. 
	#We update the elapsed time counter for the process.
	if( $4 == "Elapsed" && $5 == "time"){

    #init vars for the process
		nprocs++	
		ELAPSED_P[id]=0
		USEFUL_COMP_P[id]=0
		MPI_P[id]=0
		MPI_R[id]=rank
		COMP_P[id]=0
		NODE_NAME[id]=substr(node, 5, 8)

    #update values
		ELAPSED_P[id]=$6

    nnodes = check_inc(ELAPSED_NODES, NODE_NAME[id], nnodes)

    check_add(ELAPSED_NODES, NODE_NAME[id], $6)
    check_max(ELAPSED_MAX_NODES, NODE_NAME[id], $6)
	}
	#Update counter for elapsed computation.
	else if( $4 == "Elapsed" && $5 == "computation" ){

		USEFUL_COMP_P[id]=$7
    check_add(USEFUL_COMP_NODES, NODE_NAME[id], $7)
    check_max(USEFUL_COMP_MAX_NODES, NODE_NAME[id], $7)
				
	}
	#Update counter for MPI time.
	else if( $4 == "MPI" ){
		
		MPI_P[id]=$6
    check_add(MPI_NODES, NODE_NAME[id], $6)
    check_max(MPI_MAX_NODES, NODE_NAME[id], $6)

	}
	#Update counter for computation time.
	else if ($4 == "Computation"){

		COMP_P[id]=$6
    check_add(COMP_NODES, NODE_NAME[id], $6)
    check_max(COMP_MAX_NODES, NODE_NAME[id], $6)

	}
}
END {
	#Print the line for each process.
#	printf "MPI RANK\tNODE\tELAPSED\tELAPSED COMP\tMPI\tCOMPUTATION\n"
#	for (id in COMP_P){
#		printf "%d\t%s\t%.4f\t%.4f\t%.4f\t%.4f\n", MPI_R[id], NODE_NAME[id], ELAPSED_P[id], USEFUL_COMP_P[id], MPI_P[id], COMP_P[id] 
#	}

  #calc and print POP metrics
  
  #calcs
  max_sum_cj = find_max(COMP_NODES)
  max_tui = find_max(USEFUL_COMP_MAX_NODES)
  sum_ci = sum_arr(COMP_NODES)
  T = find_max(ELAPSED_MAX_NODES)

  #LB_IN
  LB_IN=(max_sum_cj*nnodes)/(max_tui*nprocs)*100

  #LB_OUT
  LB_OUT=(sum_ci/(max_sum_cj*nnodes))*100
  
  #COMM
  COMM=(max_tui/T)*100

  #LB
  LB=(sum_ci/(max_tui*nprocs))*100

  #PAR_EFF
  PAR_EFF=(sum_ci/(nprocs*T))*100

  # Print metrics summary
  printf "POP_METRICS\n"
  printf "----------------------\n"
  printf "PAR_EFF=%.4f\n", PAR_EFF
  printf "LB=%.4f\n", LB
  printf "COMM=%.4f\n", COMM
  printf "LB_IN=%.4f\n", LB_IN
  printf "LB_OUT=%.4f\n", LB_OUT
  printf "LB_IN*LB_OUT=%.4f\n", LB_IN*LB_OUT/100
}

