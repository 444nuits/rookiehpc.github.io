!> @brief Illustrate how to check if a group is empty.
!> @details This application is meant to be run with 4 processes. It creates two 
!> disjoint groups, named A and B, which contain processes 0,2 and 1,3
!> respectively. It then creates a group that is the intersection of groups A
!> and B. Therefore, the final group created is guaranteed to be empty, which is
!> what we need here to illustrate the MPI_GROUP_EMPTY constant.
PROGRAM main
    USE mpi_f08

    IMPLICIT NONE

    INTEGER :: comm_size
    TYPE(MPI_Group) :: world_group
    TYPE(MPI_Group) :: group_a
    INTEGER :: ranks_group_a(0:1)
    TYPE(MPI_Group) :: group_b
    INTEGER :: ranks_group_b(0:1)
    TYPE(MPI_Group) :: group_intersection

    CALL MPI_Init()

    ! Check that 4 MPI processes are used
    CALL MPI_Comm_size(MPI_COMM_WORLD, comm_size)
    IF (comm_size .NE. 4) THEN
        WRITE(*,'(A)') 'This application is meant to be run with 4 MPI processes.'
        CALL MPI_Abort(MPI_COMM_WORLD, -1)
    END IF
    
    ! Get the group or processes of the default communicator
    CALL MPI_Comm_group(MPI_COMM_WORLD, world_group)

    ! Create the group A
    ranks_group_a = [0, 2]
    CALL MPI_Group_incl(world_group, 2, ranks_group_a, group_a)

    ! Create the group B
    ranks_group_b = [1, 3]
    CALL MPI_Group_incl(world_group, 2, ranks_group_b, group_b)

    ! Create the intersection of groups A and B
    CALL MPI_Group_intersection(group_a, group_b, group_intersection)

    IF (group_intersection .EQ. MPI_GROUP_EMPTY) THEN
        WRITE(*,'(A)') 'The intersection group created is empty.'
    ELSE
        WRITE(*,'(A)') 'The intersection group created is not empty.'
    END IF

    CALL MPI_Finalize()
END PROGRAM main
