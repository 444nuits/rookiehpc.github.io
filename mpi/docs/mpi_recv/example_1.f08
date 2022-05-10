!> @brief Illustrates how to receive a message in a synchronous fashion.
!> @details This program is meant to be run with 2 processes: a sender and a
!> receiver.
PROGRAM main
    USE mpi_f08

    IMPLICIT NONE

    INTEGER :: size
    INTEGER, PARAMETER :: sender_rank = 0
    INTEGER, PARAMETER :: receiver_rank = 1
    INTEGER :: my_rank
    INTEGER :: buffer

    CALL MPI_Init()

    ! Get the number of processes and check only 2 processes are used
    CALL MPI_Comm_size(MPI_COMM_WORLD, size)
    IF (size .NE. 2) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 2 processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1)
    END IF

    ! Get my rank and do the corresponding job
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank)
    SELECT CASE (my_rank)
        CASE (sender_rank)
            ! The 'master' MPI process issues the MPI_Ssend.
            buffer = 12345
            WRITE(*,'(A,I0,A,I0,A)') 'MPI process ', my_rank, ' sends value ', buffer, '.'
            CALL MPI_Ssend(buffer, 1, MPI_INTEGER, receiver_rank, 0, MPI_COMM_WORLD)
        CASE (receiver_rank)
            ! The 'slave' MPI process receives the message.
            CALL MPI_Recv(buffer, 1, MPI_INTEGER, sender_rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE)
            WRITE(*,'(A,I0,A,I0,A)') 'MPI process ', my_rank, ' received value: ', buffer, '.'
    END SELECT

    CALL MPI_Finalize()
END PROGRAM main
