#!/bin/awk -f

BEGIN {
	FS="[ |:]+"
	it=0
	first=1
	in_talp=0
	printf "IT\tNPROCS\tELAPSED\tMPI\tCOMP\tMELAPS\tMMPI\tMCOMP"
}
{
	if ($0 == " TALP REPORTS")
	{
		it++	
		in_talp=1

		elapsed_it=0.0
		max_elapsed_it=0.0
		mpi_it=0.0
		max_mpi_it=0.0
		computation_it=0.0
		max_computation_it=0.0
		nprocs_it=0

		for (node in MAX){
			MAX[node]=0
			AVG[node]=0
		}

	}

	if ($0 == "--| ALYA     SOLVE TEMPER (1)")
	{
		in_talp=0
		
		if ( first == 1 ){
			for (node in MAX){
				printf "\t%s", substr(node,5, 6)
			}

			printf "\n"
			first=0
		}

		printf "%d\t%d\t", it, nprocs_it

		avg_elapsed_it=elapsed_it/nprocs_it
		avg_mpi_it=mpi_it/nprocs_it
		avg_computation_it=computation_it/nprocs_it
		printf "%.4f\t%.4f\t%.4f\t", avg_elapsed_it, avg_mpi_it, avg_computation_it

		avg_max_elapsed_it=avg_elapsed_it/max_elapsed_it
		avg_max_mpi_it=avg_mpi_it/max_mpi_it
		avg_max_computation_it=avg_computation_it/max_computation_it
		printf "%.4f\t%.4f\t%.4f", avg_max_elapsed_it, avg_max_mpi_it, avg_max_computation_it

		for (node in MAX){
			effn = (AVG[node]/48.0) 
			effn = (effn/MAX[node])
			printf "\t%.4f", effn
		}

		printf "\n"
	}

	if ( in_talp == 1)
	{
		if ( $4 == "Elapsed" )
		{
			nprocs_it++
			elapsed_it=elapsed_it+$6
			node=$1

			if (MAX[node] = ""){ MAX[node]=0; AVG[node]=0 }
			if (MAX[node] < $6){ MAX[node]=$6}

			if ( $6 > max_elapsed_it )
			{
				max_elapsed_it=$6
			}
		}else if ( $4 == "MPI" ){
			mpi_it=mpi_it+$6
			if ( $6 > max_mpi_it )
			{
				max_mpi_it=$6	
			}
		}else if ( $4 == "Computation" ){
			computation_it=computation_it+$6	
			if ( $6 > max_computation_it )
			{
				max_computation_it=$6
			}
			
			AVG[node]=AVG[node]+$6
		}
	}
}
END {
}
