!> @brief Illustrates how to indicate a FORTRAN-like memory ordering.
!> @details This program is meant to be run with 2 processes: a sender and a
!> receiver. These two MPI processes will exchange a message made of six
!> integers. These integers turn out to be a subarray of a 2D array held on the
!> sender. An MPI subarray type will be created to extract that subarray and
!> send it, and the memory layout specified will be that of FORTRAN.
!>
!> In the visualisation below, the leftmost dim (dim(0)) has been chosen as
!> being the one having consecutive elements in memory.
!>
!>                                                 The subarray we
!>               The full array                      want to send
!>
!>       +---------- dim(0) ------->         +--------- dim(0) ------->
!>       | +-----+-----+-----+-----+         | +-----+-----+-----+-----+ 
!>       | |  0  |  1  |  2  |  3  |         | |  -  |  -  |  -  |  -  | ^ Start point in
!>       | +-----+-----+-----+-----+         | +-----+-----+-----+-----+ | dim(1) = 2
!>       | |  4  |  5  |  6  |  7  |         | |  -  |  -  |  -  |  -  | V
!> dim(1)| +-----+-----+-----+-----+   dim(1)| +-----+-----+-----+-----+
!>       | |  8  |  9  |  10 |  11 |         | |  -  |  9  |  10 |  11 | ^ Element count
!>       | +-----+-----+-----+-----+         | +-----+-----+-----+-----+ | in dim(1) = 2
!>       | |  12 |  13 |  14 |  15 |         | |  -  |  13 |  14 |  15 | V
!>       V +-----+-----+-----+-----+         V +-----+-----+-----+-----+
!>                                              <---> <--------------->
!>                                        Start point   Element count
!>                                      in dim(0) = 1   in dim(0) = 3
!>
!> In brief the 3x2 subarray to send starts at (12) in the 4x4 full array.
PROGRAM main
    USE mpi_f08

    IMPLICIT NONE

    INTEGER :: size
    INTEGER, PARAMETER :: sender_rank = 0
    INTEGER, PARAMETER :: receiver_rank = 1
    INTEGER :: my_rank
    INTEGER :: full_array(0:3,0:3)
    INTEGER :: i
    INTEGER :: j
    TYPE(MPI_Datatype) :: subarray_type
    INTEGER :: dimensions_full_array(0:1)
    INTEGER :: dimensions_subarray(0:1)
    INTEGER :: start_coordinates(0:1)
    INTEGER :: received(0:5)

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
            ! Declare the full array
            DO i = 0, 3
                DO j = 0, 3
                    full_array(i,j) = i + j * 4
                END DO
            END DO

            ! Create the subarray datatype
            dimensions_full_array = [4, 4]
            dimensions_subarray = [3, 2]
            start_coordinates = [1, 2]
            CALL MPI_Type_create_subarray(2,  dimensions_full_array, dimensions_subarray, start_coordinates, &
                                          MPI_ORDER_FORTRAN, MPI_INTEGER, subarray_type)
            CALL MPI_Type_commit(subarray_type)

            ! Send the message
            WRITE(*,'(A,I0,A)') 'MPI process ', my_rank, ' sends:'
            WRITE(*,'(A)') ' -  -  -  -'
            WRITE(*,'(A)') ' -  -  -  -'
            DO j = 2, 3
                WRITE(*,'(A,I2,A,I2,A,I2,A)') ' -  ', full_array(1,j), ' ', full_array(2,j), ' ', full_array(3,j)
            END DO
            CALL MPI_Send(full_array, 1, subarray_type, receiver_rank, 0, MPI_COMM_WORLD)
        CASE (receiver_rank)
            ! Receive the message
            CALL MPI_Recv(received, 6, MPI_INTEGER, sender_rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE)
            WRITE(*,'(A,I0,A)', advance='no') 'MPI process ', my_rank, ' receives:'
            DO i = 0, 5
                WRITE(*,'(A,I2)', advance='no') ' ', received(i)
            END DO
            WRITE(*,'(A)') ''
    END SELECT

    CALL MPI_Finalize()
END PROGRAM main
