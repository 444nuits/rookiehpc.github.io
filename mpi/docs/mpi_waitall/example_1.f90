!> @brief Illustrates how to wait for the completion of multiple non-blocking
!> operations.
!> @details This program is meant to be run with 3 processes: a sender and two
!> receivers.
PROGRAM main
    USE mpi

    IMPLICIT NONE

    INTEGER :: ierror
    INTEGER :: size
    INTEGER :: my_rank
    INTEGER, ALLOCATABLE :: buffer(:)
    INTEGER :: buffer_length
    INTEGER :: requests(0:1)

    CALL MPI_Init(ierror)

    ! Get the number of processes and check only 3 processes are used
    CALL MPI_Comm_size(MPI_COMM_WORLD, size, ierror)
    IF (size .NE. 3) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 3 processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1, ierror)
    END IF

    ! Get my rank
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierror)

    IF (my_rank == 0) THEN
        ! The 'master' MPI process sends the message.
        buffer_length = 2
        ALLOCATE(buffer(0:buffer_length-1))
        buffer = (/12345, 67890/)
        WRITE(*,'(A,I0,A,I0,A,I0,A)') 'MPI process ', my_rank, ' sends the values ', buffer(0), ' ', buffer(1), '.'
        CALL MPI_Isend(buffer(0), 1, MPI_INTEGER, 1, 0, MPI_COMM_WORLD, requests(0), ierror)
        CALL MPI_Isend(buffer(1), 1, MPI_INTEGER, 2, 0, MPI_COMM_WORLD, requests(1), ierror)

        ! Wait for both routines to complete
        CALL MPI_Waitall(2, requests, MPI_STATUSES_IGNORE, ierror)
        WRITE(*,'(A,I0,A)') 'Process ', my_rank, ': both messages have been sent.'
    ELSE
        ! The 'slave' MPI processes receive the message.
        buffer_length = 1
        ALLOCATE(buffer(0:buffer_length-1))
        CALL MPI_Recv(buffer, 1, MPI_INTEGER, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierror)
        WRITE(*,'(A,I0,A,I0,A)') 'Process ', my_rank, ' received value ', buffer(0), '.'
    END IF
    DEALLOCATE(buffer)

    CALL MPI_Finalize(ierror)
END PROGRAM main