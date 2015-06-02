subroutine condinit(x,u,dx,nn)
  use amr_parameters
  use hydro_parameters
  implicit none
  integer ::nn                            ! Number of cells
  real(dp)::dx                            ! Cell size
  real(dp),dimension(1:nvector,1:nvar)::u ! Conservative variables
  real(dp),dimension(1:nvector,1:ndim)::x ! Cell center position.
  !================================================================
  ! This routine generates initial conditions for RAMSES.
  ! Positions are in user units:
  ! x(i,1:3) are in [0,boxlen]**ndim.
  ! U is the conservative variable vector. Conventions are here:
  ! U(i,1): d, U(i,2:ndim+1): d.u,d.v,d.w and U(i,ndim+2): E.
  ! Q is the primitive variable vector. Conventions are here:
  ! Q(i,1): d, Q(i,2:ndim+1):u,v,w and Q(i,ndim+2): P.
  ! If nvar >= ndim+3, remaining variables are treated as passive
  ! scalars in the hydro solver.
  ! U(:,:) and Q(:,:) are in user units.
  !================================================================
  integer::ivar
  real(dp),dimension(1:nvector,1:nvar),save::q   ! Primitive variables
  real rmax, rho0,P0,xl,xr,xc,yl,yr,yc,zr,zl,zc,rr
  integer i
  ! Call built-in initial condition generator
  !call region_condinit(x,q,dx,nn)
  q(1:nn,:)=0.
  ! Add here, if you wish, some user-defined initial conditions
  do i=1,nn !looping through all grid numbers
    !Defining the left, right, and center positions of each cells.
     xl=x(i,1)-0.5*dx-boxlen/2.0
     xr=x(i,1)+0.5*dx-boxlen/2.0
     xc=x(i,1)-boxlen/2.0
     yl=x(i,2)-0.5*dx-boxlen/2.0
     yr=x(i,2)+0.5*dx-boxlen/2.0
     yc=x(i,2)-boxlen/2.0
     zl=x(i,3)-0.5*dx-boxlen/2.0
     zr=x(i,3)+0.5*dx-boxlen/2.0
     zc=x(i,3)-boxlen/2.0

     rr=sqrt(xc**2+yc**2+zc**2)
     !G=1 for self gravity
     rmax=1.07483E10
     rho0=7.3403E-27
     P0= 9.14E-11
     !P0=2.46E-8
     !In Larson (1969), pressure is constant
     !Density
     !IF (rr .LE. rmax) THEN
     IF (rr .LE. 1E10) THEN
	q(i,1)=rho0
     ELSE !the rest of the box
        !PRINT *,"Outside box"
        !PRINT *, "Radius: ",rr
        q(i,1)=1.0E-32 !few orders of magnitude less dense (~approx 0?)
     END IF
     !Initially static cloud
     q(i,2)=0.0      ! Velocity x
     q(i,3)=0.0      ! Velocity y
     q(i,4)=0.0      ! Velocity z
     !Pressure (constant radius --> isovolumetric, ideal gas)
     IF (rr .LE. 1E10) THEN
    ! IF (rr .LE. 0.8E10) THEN     
	!q(i,5)=1.0E-25
	q(i,5)=P0
     ELSE
        !q(i,5)=7.3403E-58
	q(i,5)=1.0E-25
     END IF
    !q(i,5)=P0
    !Don't set P as anything in the initial condition let it do its own thing.
  end do 
  !Convert primitive to conservative variables
  ! density -> density
  u(1:nn,1)=q(1:nn,1)
  ! velocity -> momentum
  u(1:nn,2)=q(1:nn,1)*q(1:nn,2)
#if NDIM>1
  u(1:nn,3)=q(1:nn,1)*q(1:nn,3)
#endif
#if NDIM>2
  u(1:nn,4)=q(1:nn,1)*q(1:nn,4)
#endif
  ! kinetic energy
  u(1:nn,ndim+2)=0.0d0
  u(1:nn,ndim+2)=u(1:nn,ndim+2)+0.5*q(1:nn,1)*q(1:nn,2)**2
#if NDIM>1
  u(1:nn,ndim+2)=u(1:nn,ndim+2)+0.5*q(1:nn,1)*q(1:nn,3)**2
#endif
#if NDIM>2
  u(1:nn,ndim+2)=u(1:nn,ndim+2)+0.5*q(1:nn,1)*q(1:nn,4)**2
#endif
  ! thermal pressure -> total fluid energy
  u(1:nn,ndim+2)=u(1:nn,ndim+2)+q(1:nn,ndim+2)/(gamma-1.0d0)
#if NENER>0
  ! radiative pressure -> radiative energy
  ! radiative energy -> total fluid energy
  do ivar=1,nener
     u(1:nn,ndim+2+ivar)=q(1:nn,ndim+2+ivar)/(gamma_rad(ivar)-1.0d0)
     u(1:nn,ndim+2)=u(1:nn,ndim+2)+u(1:nn,ndim+2+ivar)
  enddo
#endif
#if NVAR>NDIM+2+NENER
  ! passive scalars
  do ivar=ndim+3+nener,nvar
     u(1:nn,ivar)=q(1:nn,1)*q(1:nn,ivar)
  end do
#endif

end subroutine condinit
