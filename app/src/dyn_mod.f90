MODULE dyn_mod
  !
  IMPLICIT NONE
  !
CONTAINS
!
!
!
SUBROUTINE dyn()
  !
  USE shiftk_io, ONLY : input_filename, input_hamiltonian, input_rhs_vector, &
  &                     input_parameter, input_restart_parameter, input_restart_vector, &
  &                     output_result, output_result_debug, output_restart_parameter, output_restart_vector
  USE shiftk_vals, ONLY : alpha, beta, calctype, ndim, nomega, maxloops, iter_old, lBiCG, nl, &
  &                       outrestart, rhs, v12, v2, v14, v4, rhs, r_l, r_l_save, threshold, x, z, z_seed
  !
  USE shifted_cocg, ONLY : COCG_init, COCG_restart, COCG_update, &
  &                        COCG_getcoef, COCG_getvec, COCG_finalize
  USE shifted_bicg, ONLY : BiCG_init, BiCG_restart, BiCG_update, &
  &                        BiCG_getcoef, BiCG_getvec, BiCG_finalize
  !
  USE ham_prod, ONLY : ham_prod_compress
  !
  IMPLICIT NONE
  !
  INTEGER :: &
  & iter,    & ! Counter for Iteration
  & status(3)
  !
  CALL input_hamiltonian()
  CALL input_rhs_vector()
  !
  nl = 1
  !nl = ndim
  CALL input_parameter()
  !
  ALLOCATE(v12(ndim), v2(ndim), r_l(nl), x(nl,nomega))
  IF(lBiCG) ALLOCATE(v14(ndim), v4(ndim))
  !
  IF(TRIM(calctype) == "recalc" .OR. TRIM(calctype) == "restart") THEN
     !
     CALL input_restart_parameter()
     IF(TRIM(calctype) == "restart") CALL input_restart_vector()
     maxloops = MAX(maxloops, iter_old)
     !
     WRITE(*,*)
     WRITE(*,*) "##########  CG Restart  ##########"
     WRITE(*,*)
     !
     IF(outrestart == .TRUE.) THEN
        IF(lBiCG) THEN
           CALL BiCG_restart(ndim, nl, nomega, x, z, maxloops, threshold, status, &
           &                 iter_old, v2, v12, v4, v14, alpha, beta, z_seed, r_l_save)
        ELSE
           CALL COCG_restart(ndim, nl, nomega, x, z, maxloops, threshold, status, &
           &                 iter_old, v2, v12,          alpha, beta, z_seed, r_l_save)
        END IF
     ELSE
        IF(lBiCG) THEN
           CALL BiCG_restart(ndim, nl, nomega, x, z, 0,        threshold, status, &
           &                 iter_old, v2, v12, v4, v14, alpha, beta, z_seed, r_l_save)
        ELSE
           CALL COCG_restart(ndim, nl, nomega, x, z, 0,        threshold, status, &
           &                 iter_old, v2, v12,          alpha, beta, z_seed, r_l_save)
        END IF
     END IF
     DEALLOCATE(alpha, beta, r_l_save)
     !
     IF(iter_old == maxloops .OR. TRIM(calctype) == "recalc") GOTO 10
     !
  ELSE IF(TRIM(calctype) == "normal") THEN
     !
     WRITE(*,*)
     WRITE(*,*) "##########  CG Initialization  ##########"
     WRITE(*,*)
     !
     v2(1:ndim) = rhs(1:ndim)
     !
     IF(outrestart == .TRUE.) THEN
        IF(lBiCG) THEN
           CALL BiCG_init(ndim, nl, nomega, x, z, maxloops, threshold, status)
        ELSE
           CALL COCG_init(ndim, nl, nomega, x, z, maxloops, threshold, status)
        END IF
     ELSE
        IF(lBiCG) THEN
           CALL BiCG_init(ndim, nl, nomega, x, z, 0,        threshold, status)
        ELSE
           CALL COCG_init(ndim, nl, nomega, x, z, 0,        threshold, status)
        END IF
     END IF
     !
  ELSE
     !
     WRITE(*,*) "ERROR ! calctype = ", TRIM(calctype)
     STOP
     !
  END IF
  !
  ! COCG/BiCG Loop
  !
  WRITE(*,*)
  WRITE(*,*) "#####  BiCG Iteration  #####"
  WRITE(*,*)
  !
  DO iter = 1, maxloops
     !
     ! Projection of Residual vector into the space
     ! spaned by left vectors
     !
     IF(ndim == nl) THEN
        r_l(1:ndim) = v2(1:ndim)
     ELSE
        r_l(1) = DOT_PRODUCT(rhs, v2)
     END IF
     !
     ! Matrix-vector product
     !
     CALL ham_prod_compress(v2, v12)
     IF(lBiCG) CALL ham_prod_compress(v4, v14)
     !
     ! Update result x with COCG
     !
     IF(lBiCG) THEN
        CALL BiCG_update(v12, v2, v14, v4, x, r_l, status)
     ELSE
        CALL COCG_update(v12, v2,          x, r_l, status)
     END IF
     !
     WRITE(*,'(a,4i,e13.5)') "  DEBUG : ", iter, status, DBLE(v12(1))
     IF(status(1) /= 0) EXIT
     !
  END DO
  !
  IF(status(1) > 0) THEN
     WRITE(*,*) "  Converged in iteration ", status(1)
  ELSE
     WRITE(*,*) "  Not Converged in iteration ", -status(1)
  END IF
  iter_old = abs(status(1))
  !
10 CONTINUE
  !
  ! Get these vectors for restart in the Next run
  !
  IF(outrestart == .TRUE.) THEN
     !
     ALLOCATE(alpha(iter_old), beta(iter_old), r_l_save(nl, iter_old))
     !
     IF(lBiCG) THEN
        CALL BiCG_getcoef(alpha, beta, z_seed, r_l_save)
        CALL BiCG_getvec(v12,v14)
     ELSE
        CALL COCG_getcoef(alpha, beta, z_seed, r_l_save)
        CALL COCG_getvec(v12)
     END IF
     !
     CALL output_restart_parameter()
     CALL output_restart_vector()
     !
     DEALLOCATE(alpha, beta, r_l_save)
     !     
  END IF
  !
  ! Deallocate all intrinsic vectors
  !
  IF(lBiCG) THEN
     CALL BiCG_finalize()
  ELSE
     CALL COCG_finalize()
  END IF
  !
  ! Output to a file
  !
  IF(ndim == nl) THEN
     CALL output_result_debug()
  ELSE
     CALL output_result()
  END IF
  !
  DEALLOCATE(v12, v2, r_l, x, z)
  IF(lBiCG) DEALLOCATE(v14, v4)
  !
END SUBROUTINE dyn
!
END MODULE dyn_mod
