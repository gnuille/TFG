#!/bin/awk -f
BEGIN {
	it=0
	in_talp=0
	printf "IT\tNPROCS\tELAPSED\tMPI\tCOMP\tMELAPS\tMMPI\tMCOMP\n"
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

	}

	if ($0 == " END TALP REPORTS")
	{
		in_talp=0

		printf "%d\t%d\t", it, nprocs_it

		avg_elapsed_it=elapsed_it/nprocs_it
		avg_mpi_it=mpi_it/nprocs_it
		avg_computation_it=computation_it/nprocs_it
		printf "%.4f\t%.4f\t%.4f\t", avg_elapsed_it, avg_mpi_it, avg_computation_it

		avg_max_elapsed_it=avg_elapsed_it/max_elapsed_it
		avg_max_mpi_it=avg_mpi_it/max_mpi_it
		avg_max_computation_it=avg_computation_it/max_computation_it
		printf "%.4f\t%.4f\t%.4f\n", avg_max_elapsed_it, avg_max_mpi_it, avg_max_computation_it
	}

	if ( in_talp == 1)
	{
		if ( $3 == "Elapsed" )
		{
			nprocs_it++
			elapsed_it=elapsed_it+$6

			if ( $6 > max_elapsed_it )
			{
				max_elapsed_it=$6
			}
		}else if ( $3 == "MPI" ){
			mpi_it=mpi_it+$6
			if ( $6 > max_mpi_it )
			{
				max_mpi_it=$6	
			}
		}else if ( $3 == "Computation" ){
			computation_it=computation_it+$6	
			if ( $6 > max_computation_it )
			{
				max_computation_it=$6
			}
		}
	}
}
END {

}
