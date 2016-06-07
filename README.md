WPS Scripts to run WRF from ERA-Interim
=======================================

This makefile runs the WRF preprocessor to generate boundary conditions from
ERA-Interim data.

To generate the WRF input, edit the `namelist.wps` file as appropriate for your
simulation and then run

    make WPSDIR=/path/to/WPS
