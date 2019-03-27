WPS Scripts to run WRF from ERA-Interim
=======================================

This makefile runs the WRF preprocessor to generate boundary conditions from
ERA-Interim data.

Previous to WRF v4.0.2:
-----------------------
You need to use the version tagged `before_v4.0.2`.
It uses the metgrid table, METGRID.TBL.ERAI. This table is not distributed with WRF.
If you have the WRF code ported to NCI, this table is already in the WPS/metgrid directory.
Else it is provided in this repository, please copy it to your WPS/metgrid directory before starting.

After WRF v4.0.2:
-----------------
You need to use the newest version. It uses the metgrid table METGRID.TBL.ARW distributed with WRF.
In previous versions, we had issues with SST for high resolution domains. It seems these are solved now but please check your input data.

To generate the WRF input, edit the `namelist.wps` file provided in the wps-era/ directory as appropriate for your
simulation and from within wps-era/, run

    make WPSDIR=/path/to/WPS
