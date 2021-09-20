program main_fortran
    
    ! How to compile:
    ! ifort /traceback /check:bounds /check:stack main_fortran.f90 -o run.exe
implicit none    

! Declare variables
integer :: na, nz, a_c, z_c, howread
real(8) :: alpha, tic, toc
integer, allocatable :: int_params(:)
real(8), allocatable :: real_params(:), a_grid(:), z_grid(:), output(:,:)

! Read parameters and grids from Matlab-generated files

call read_files()

! Display some information on the screen
write(*,*) "alpha = ", alpha
write(*,*) "(na,nz) = ", na, nz
write(*,*) "howread = ", howread


!pause

! Solve the model
allocate(output(na,nz))

do z_c = 1,nz
    do a_c = 1,na
        output(a_c,z_c) = z_grid(z_c)*a_grid(a_c)**alpha
    enddo
enddo

! Write results to files to be read in Matlab
write(*,*) "Now I'm writing files.."
call CPU_TIME(tic)
call write_files()
call CPU_TIME(toc)
write(*,*) "Files written!"
write(*,*) 'Time to write files: ', real(toc-tic)

! Deallocate global arrays
deallocate(a_grid, z_grid, output)

write(*,*) "Program completed successfully!"


    contains
    
    !=================================================================!
    subroutine read_files()
    implicit none
    ! Declare local variables
    integer :: unitno, ierr, i, ii, real_params_dim, int_params_dim
    integer :: dimensions(2)
    
    ! Read dimensions of int_params an real_params into Fortran
    open(newunit=unitno, file="dimensions.txt", status='old', iostat=ierr)
    if (ierr/=0) then
        write(*,*) "Error in read_files: cannot open file dimensions.txt"
		stop 
    endif
    do i = 1,2
        read(unitno,*) dimensions(i)
    enddo
    close(unitno)
    
    real_params_dim = dimensions(1)
	int_params_dim  = dimensions(2)
    
    allocate(int_params(int_params_dim),real_params(real_params_dim))
    
    ! Read integer parameters into Fortran
    open(newunit=unitno, file="int_params.txt", status='old', iostat=ierr)
    if (ierr/=0) then
        write(*,*) "Error in read_files: cannot open file int_params.txt"
		stop 
    endif
    do i = 1,int_params_dim
        read(unitno,*) int_params(i)
    enddo
    close(unitno)
    
    ! Assign integer parameters
    ii = 1
    na = int_params(ii); ii=ii+1
    nz = int_params(ii); ii=ii+1
    howread = int_params(ii)
    
    ! Read real parameters into Fortran
    open(newunit=unitno, file="real_params.txt", status='old', iostat=ierr)
    if (ierr/=0) then
        write(*,*) "Error in read_files: cannot open file real_params.txt"
		stop 
    endif
    do i = 1,real_params_dim
        read(unitno,*) real_params(i)
    enddo
    close(unitno)
    
    ! Assign real parameters
    ii = 1
    alpha = real_params(ii)
    
    ! First allocate grids using the dimensions imported from Matlab
    allocate(a_grid(na),z_grid(nz))
    
    ! Then, read grids into Matlab
    open(newunit=unitno, file="a_grid.txt", status='old', iostat=ierr)
    if (ierr/=0) then
        write(*,*) "Error in read_files: cannot open file a_grid.txt"
		stop 
    endif
    do i = 1,na
        read(unitno,*) a_grid(i)
    enddo
    close(unitno)
    
    open(newunit=unitno, file="z_grid.txt", status='old', iostat=ierr)
    if (ierr/=0) then
        write(*,*) "Error in read_files: cannot open file z_grid.txt"
		stop 
    endif
    do i = 1,nz
        read(unitno,*) z_grid(i)
    enddo
    close(unitno)
    
    
    
    end subroutine read_files
    !=================================================================!
    
    subroutine write_files()
    ! Variables
    integer :: unitno, ierr, i, j
    real(8), allocatable :: output_vec(:)
    ! Body of write_files
    
    output_vec = reshape(output,[na*nz])
    
    if (howread==1) then
        write(*,*) "Txt format"
        
        ! Txt file
        do j = 1,20
            open(newunit=unitno, file='output.txt', status='replace',  iostat=ierr)
            if (ierr/=0) then
                write(*,*) "Error: write_files: cannot open file output.txt"
		        stop 
            endif
            do i = 1,size(output_vec)
                write(unitno,*) output_vec(i)
            enddo
            close(unitno)
        enddo !end j
    
    elseif (howread==2) then
        write(*,*) "Binary format"
        
        ! Binary file
        do j = 1,20
            open(newunit=unitno, file='output.bin', form="unformatted", access="stream", status="unknown", iostat=ierr)
            if (ierr/=0) then
                write(*,*) "Error: write_files: cannot open file output.bin"
                stop 
            endif
            do i = 1,size(output_vec)
                write(unitno) output_vec(i)
            enddo
            close(unitno)
        enddo !end j
    
    endif
    
    end subroutine write_files
    !=================================================================!

end program main_fortran
    