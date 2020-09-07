#!/bin/awk -f

#########################################################
#							#		
#	File: talp-proc-info.awk                        #
#	Author: Guillem Ramírez Miranda			#
#	Purpose: Get timming metrics of each process	#
#							#
#########################################################

BEGIN {
	#separate by words " " and dlb fields ":"
	FS="[ |:]+"
	#counter just for debugging purposes
	nprocs=0
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

		nprocs++	
		ELAPSED_P[id]=0
		USEFULL_COMP_P[id]=0
		MPI_P[id]=0
		MPI_R[id]=rank
		COMP_P[id]=0
		NODE_NAME[id]=substr(node, 5, 8)

		ELAPSED_P[id]=$6

	}
	#Update counter for elapsed computation.
	else if( $4 == "Elapsed" && $5 == "computation" ){

		USEFULL_COMP_P[id]=$7
				
	}
	#Update counter for MPI time.
	else if( $4 == "MPI" ){
		
		MPI_P[id]=$6

	}
	#Update counter for computation time.
	else if ($4 == "Computation"){

		COMP_P[id]=$6

	}
}
END {
	#Print the line for each process.
	printf "MPI RANK\tNODE\tELAPSED\tELAPSED COMP\tMPI\tCOMPUTATION\n"
	for (id in COMP_P){
		printf "%d\t%s\t%.4f\t%.4f\t%.4f\t%.4f\n", MPI_R[id], NODE_NAME[id], ELAPSED_P[id], USEFULL_COMP_P[id], MPI_P[id], COMP_P[id] 
	}
}

