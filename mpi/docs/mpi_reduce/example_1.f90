!> @brief Illustrates how to use a reduce.
!> @details This application consists of a sum reduction every MPI process
!> sends its rank for reduction before the sum of these ranks is stored in the
!> root MPI process. It can be visualised as follows, with MPI process 0 as
!> root:
!>
!> +-----------+ +-----------+ +-----------+ +-----------+
!> | Process 0 | | Process 1 | | Process 2 | | Process 3 |
!> +-+-------+-+ +-+-------+-+ +-+-------+-+ +-+-------+-+
!>   | Value |     | Value |     | Value |     | Value |
!>   |   0   |     |   1   |     |   2   |     |   3   |
!>   +-------+     +-------+     +-------+     +-------+
!>            \         |           |         /
!>             \        |           |        /
!>              \       |           |       /
!>               \      |           |      /
!>                +-----+-----+-----+-----+
!>                            |
!>                        +---+---+
!>                        |  SUM  |
!>                        +---+---+
!>                            |
!>                        +---+---+
!>                        |   6   |
!>                      +-+-------+-+
!>                      | Process 0 |
!>                      +-----------+
PROGRAM main
    USE mpi

    IMPLICIT NONE

    INTEGER :: ierror
    INTEGER :: size
    ! Determine root's rank
    INTEGER, PARAMETER :: root_rank = 0
    INTEGER :: my_rank
    INTEGER :: reduction_result = 0

    CALL MPI_Init(ierror)

    ! Get the size of the communicator
    CALL MPI_Comm_size(MPI_COMM_WORLD, size, ierror)
    IF (size .NE. 4) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 4 MPI processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1, ierror)
    END IF

    ! Get my rank
    CALL MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierror)

    ! Each MPI process sends its rank to reduction, root MPI process collects the result
    CALL MPI_Reduce(my_rank, reduction_result, 1, MPI_INTEGER, MPI_SUM, root_rank, MPI_COMM_WORLD, ierror)

    IF (my_rank .EQ. root_rank) THEN
        WRITE(*,'(A,I0,A)') 'The sum of all ranks is ', reduction_result, '.'
    END IF

    CALL MPI_Finalize(ierror)
END PROGRAM main