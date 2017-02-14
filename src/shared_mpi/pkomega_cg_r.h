/*
ISSP Math Library - A library for solving linear systems in materials science
Copyright (C) 2016 Mitsuaki Kawamura

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

For more details, See �eCOPYING.LESSER�f in the root directory of this library.
*/

#include <mpi.h>
#include <complex.h>
#pragma once

void pkomega_cg_r_init(int *ndim, int *nl, int *nz, double *x,
                       double *z, int *itermax, double *threshold,
                       MPI_Comm *comm);
void pkomega_cg_r_restart(int *ndim, int *nl, int *nz, double *x,
                          double *z, int *itermax, double *threshold,
                          MPI_Comm *comm, int *status, int *iter_old, double *v2,
                          double *v12, 
                          double *alpha_save, double *beta_save,
                          double *z_seed, double *r_l_save);
void pkomega_cg_r_update(double *v12, double *v2, double *x,
                         double *r_l, int *status);
void pkomega_cg_r_getcoef(double *alpha_save, double *beta_save,
                          double *z_seed, double *r_l_save);
void pkomega_cg_r_getvec(double *r_old);
void pkomega_cg_r_getresidual(double *res);
void pkomega_cg_r_finalize();