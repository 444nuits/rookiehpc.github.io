!> @brief Illustrates how to use the non-blocking variable version of an all
!> gather.
!> @details This application is meant to be run with 3 MPI processes. Every MPI
!> process begins with a value, each process will gather all these values and
!> moves on doing another job while the gather progresses. Once complete, they
!> print the data collected. The example is designed to cover all cases:
!> - Different displacements
!> - Different receive counts
!> It can be visualised as follows:
!>
!> +-----------+ +-----------+ +-------------------+ 
!> | Process 0 | | Process 1 | |     Process 2     |
!> +-+-------+-+ +-+-------+-+ +-+-------+-------+-+
!>   | Value |     | Value |     | Value | Value |
!>   |  100  |     |  101  |     |  102  |  103  |
!>   +-------+     +-------+     +-------+-------+
!>      |                |            |     |
!>      |                |            |     |
!>      |                |            |     |
!>      |                |            |     |
!>      |                |            |     |
!>      |                |            |     |
!>   +-----+-----+-----+-----+-----+-----+-----+
!>   | 100 |  0  |  0  | 101 |  0  | 102 | 103 |
!>   +-----+-----+-----+-----+-----+-----+-----+
!>   |              Each process               |
!>   +-----------------------+-----+-----+-----+
PROGRAM main
    USE mpi_f08

    IMPLICIT NONE

    INTEGER :: size
    INTEGER :: my_rank
    ! Define the receive counts
    INTEGER, PARAMETER :: counts(0:2) = [1, 1, 2]
    ! Define the displacements
    INTEGER, PARAMETER :: displacements(0:2) = [0, 3, 5]
    ! Buffer in which receive the data collected
    INTEGER :: buffer(0:6) = 0
    ! Buffer containing our data to send
    INTEGER, ALLOCATABLE :: my_values(:)
    INTEGER :: my_values_count
    TYPE(MPI_Request) :: request
    INTEGER :: i

    CALL MPI_Init()

    ! Get number of processes and check only 3 processes are used
    CALL MPI_Comm_size(MPI_COMM_WORLD, size)
    IF (size .NE. 3) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 3 processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1)
    END IF

    ! Get my rank
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank)

    SELECT CASE (my_rank)
        CASE (0)
            ! Define my values
            my_values_count = 1
            ALLOCATE(my_values(0:my_values_count-1))
            my_values(0) = 100
            WRITE(*,'(A,I0,A,I0,A)') 'Value sent by process ', my_rank, ': ', my_values(0), '.'
        CASE (1)
            ! Define my values
            my_values_count = 1
            ALLOCATE(my_values(0:my_values_count-1))
            my_values(0) = 101
            WRITE(*,'(A,I0,A,I0,A)') 'Value sent by process ', my_rank, ': ', my_values(0), '.'
        CASE (2)
            ! Define my values
            my_values_count = 2
            ALLOCATE(my_values(0:my_values_count-1))
            my_values(0) = 102
            my_values(1) = 103
            WRITE(*,'(A,I0,A,I0,A,I0,A)') 'Values sent by process ', my_rank, ': ', my_values(0), ' and ', my_values(1)
    END SELECT

    CALL MPI_Iallgatherv(my_values, my_values_count, MPI_INTEGER, &
                         buffer, counts, displacements, MPI_INTEGER, MPI_COMM_WORLD, request)

    ! Do another job while the non-blocking variable all gather progresses
    ! ...

    ! Wait for the completion
    CALL MPI_Wait(request, MPI_STATUS_IGNORE)
    WRITE(*,'(A,I0,A)', advance='no') 'Values gathered in the buffer on process ', my_rank, ':'
    DO i = 0, 6
        WRITE(*,'(A,I0)', advance='no') ' ', buffer(i)
    END DO
    WRITE(*,'(A)') ''
    DEALLOCATE(my_values)

    CALL MPI_Finalize()
END PROGRAM main
