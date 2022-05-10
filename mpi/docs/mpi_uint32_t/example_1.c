#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <mpi.h>

/**
 * @brief Illustrate how to communicate an unsigned 4-byte int between 2 MPI
 * processes.
 * @details This application is meant to be run with 2 MPI processes: 1 sender
 * and 1 receiver. The former sends an unsigned 4-byte int to the latter, which
 * prints it.
 **/
int main(int argc, char* argv[])
{
	MPI_Init(&argc, &argv);

	// Check that 2 MPI processes are used.
	int size;
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	if(size != 2)
	{
		printf("This application is meant to be run with 2 MPI processes.\n");
		MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
	}

	// Get my rank and do the corresponding job.
	enum role_ranks { SENDER, RECEIVER };
	int my_rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
	switch(my_rank)
	{
		case SENDER:
		{
			// Send the int
			uint32_t intToSend = 123456789;
			printf("[MPI process %d] I send unsigned int: %u.\n", my_rank, intToSend);
			MPI_Ssend(&intToSend, 1, MPI_UINT32_T, RECEIVER, 0, MPI_COMM_WORLD);
			break;
		}
		case RECEIVER:
		{
			// Receive the int
			uint32_t intReceived;
			MPI_Recv(&intReceived, 1, MPI_UINT32_T, SENDER, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
			printf("[MPI process %d] I received unsigned int: %u.\n", my_rank, intReceived);
			break;
		}
	}

	MPI_Finalize();

	return EXIT_SUCCESS;
}
