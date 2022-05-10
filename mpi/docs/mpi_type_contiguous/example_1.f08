!> @brief Illustrates how to create a contiguous MPI datatype.
!> @details This program is meant to be run with 2 processes: a sender and a
!> receiver. These two MPI processes will exchange a message made of two
!> integers. To that end, they each create a datatype representing that layout.
!> They then use this datatype to express the message type exchanged.
PROGRAM main
    USE mpi_f08

    IMPLICIT NONE

    INTEGER :: size
    TYPE(MPI_Datatype) :: double_int_type
    INTEGER, PARAMETER :: sender_rank = 0
    INTEGER, PARAMETER :: receiver_rank = 1
    INTEGER :: my_rank
    INTEGER :: buffer(0:1)

    CALL MPI_Init()

    ! Get the number of processes and check only 2 processes are used
    CALL MPI_Comm_size(MPI_COMM_WORLD, size)
    IF (size .NE. 2) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 2 processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1)
    END IF

    ! Create the datatype
    CALL MPI_Type_contiguous(2, MPI_INTEGER, double_int_type)
    CALL MPI_Type_commit(double_int_type)

    ! Get my rank and do the corresponding job
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank)
    SELECT CASE (my_rank)
        CASE (sender_rank)
            buffer = [12345, 67890]
            WRITE(*,'(A,I0,A,I0,A,I0,A)') 'MPI process ', my_rank, ' sends values ', buffer(0), ' and ', buffer(1), '.'
            CALL MPI_Send(buffer, 1, double_int_type, receiver_rank, 0, MPI_COMM_WORLD)
        CASE (receiver_rank)
            CALL MPI_Recv(buffer, 1, double_int_type, sender_rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE)
            WRITE(*,'(A,I0,A,I0,A,I0,A)') 'MPI process ', my_rank, ' received values ', buffer(0), ' and ', buffer(1), '.'
    END SELECT

    CALL MPI_Finalize()
END PROGRAM main
