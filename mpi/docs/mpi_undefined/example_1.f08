!> @brief Illustrate how to encounter a situation in which MPI_UNDEFINED is
!> returned.
!> @details This application is meant to be run with 4 processes. It creates a 
!> subgroup that will contain processes 0 and 1 only. Therefore, since processes
!> 2 and 3 do not belong to the subgroup, when they will try to get their rank
!> in that group, MPI_UNDEFINED will be returned.
PROGRAM main
    USE mpi_f08

    IMPLICIT NONE

    INTEGER :: comm_size
    TYPE(MPI_Group) :: world_group
    INTEGER :: ranks_subgroup(0:1)
    TYPE(MPI_Group) :: subgroup
    INTEGER :: my_world_group_rank
    INTEGER :: my_subgroup_rank

    CALL MPI_Init()

    ! Check that 4 MPI processes are used
    CALL MPI_Comm_size(MPI_COMM_WORLD, comm_size)
    IF (comm_size .NE. 4) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 4 MPI processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1)
    END IF

    ! Get the group or processes of the default communicator
    CALL MPI_Comm_group(MPI_COMM_WORLD, world_group)

    ! Create the subgroup
    ranks_subgroup = [0,1]
    CALL MPI_Group_incl(world_group, 2, ranks_subgroup, subgroup)

    ! Get my rank in the world group and the subgroup
    CALL MPI_Group_rank(world_group, my_world_group_rank)
    CALL MPI_Group_rank(subgroup, my_subgroup_rank)

    IF (my_subgroup_rank .EQ. MPI_UNDEFINED) THEN
        WRITE(*,'(A,I0,A)') 'I am process ', my_world_group_rank, ' in world group but I am not part of the subgroup.'
    ELSE
        WRITE(*,'(A,I0,A,A,I0,A)') 'I am process ', my_world_group_rank, ' in world group ', &
                                 'and process ', my_subgroup_rank, ' in subgroup.'
    END IF

    CALL MPI_Finalize()
END PROGRAM main
