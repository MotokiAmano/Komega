#
# Komega library
#
MAINTAINERCLEANFILES = Makefile.in

include_HEADERS = komega.h
nodist_include_HEADERS = komega_bicg.$(FC_MODEXT) komega_cg_c.$(FC_MODEXT) \
						 komega_cg_r.$(FC_MODEXT) komega_cocg.$(FC_MODEXT)

lib_LTLIBRARIES = libkomega.la

libkomega_la_SOURCES = komega_bicg.F90 komega_cg_r.F90 komega_cg_c.F90 komega_cocg.F90 \
                       komega_math.F90 komega_vals.F90

# Clean up modules.
clean-local: clean-modules
clean-modules:
	test -z "$(FC_MODEXT)" || $(RM) *.$(FC_MODEXT)

komega_bicg.lo : komega_bicg.F90 komega_math.lo komega_vals.lo komega_vals.lo komega_vals.lo 
komega_cg_c.lo : komega_cg_c.F90 komega_math.lo komega_vals.lo komega_vals.lo komega_vals.lo 
komega_cg_r.lo : komega_cg_r.F90 komega_math.lo komega_vals.lo komega_vals.lo komega_vals.lo 
komega_cocg.lo : komega_cocg.F90 komega_math.lo komega_vals.lo komega_vals.lo komega_vals.lo 
komega_math.lo : komega_math.F90 komega_vals.lo 
komega_vals.lo : komega_vals.F90 

