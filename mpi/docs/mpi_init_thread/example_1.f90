!> @brief Illustrates how to initialise the MPI environment with multithreading
!> support.
!> @details This application initialised MPI and asks for the
!> MPI_THREAD_FUNNELED thread support level. It then compares it with the
!> thread support level provided by the MPI implementation.
PROGRAM main
    USE mpi

    IMPLICIT NONE

    INTEGER :: provided
    INTEGER :: ierror

    ! Initilialise MPI and ask for thread support
    CALL MPI_Init_thread(MPI_THREAD_FUNNELED, provided, ierror)

    IF (provided .LT. MPI_THREAD_FUNNELED) THEN
        WRITE(*,'(A)') 'The threading support level is lesser than that demanded.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1, ierror)
    ELSE
        WRITE(*,'(A)') 'The threading support level corresponds to that demanded.'
    END IF

    ! Tell MPI to shut down.
    CALL MPI_Finalize(ierror)
END PROGRAM main