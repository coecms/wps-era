all: metgrid
metgrid: .metgrid.done
geogrid: .geogrid.done
ungrib: .ungrib.done

ifndef WPSDIR
    $(error Please run as `make WPSDIR=/path/to/WPS`)
endif

# Get the start and end dates from the namelist
START_DATE:=$(shell sed -n namelist.wps -e 's/.*start_date\s*=\s*'"'"'\([^_]*\).*/\1/p' | tr -d '-')
END_DATE:=$(shell sed -n namelist.wps -e 's/.*end_date\s*=\s*'"'"'\([^_]*\).*/\1/p' | tr -d '-')

# Find the input files
SFC_FILES:=$(shell find "/g/data1/ub4/erai/grib/oper_an_sfc/fullres" -type f | awk 'BEGIN{FS="_"}{if (${START_DATE}<=$$10 && $$9<=${END_DATE}){print $$0}}' )
PL_FILES:=$(shell find "/g/data1/ub4/erai/grib/oper_an_pl/fullres" -type f | awk 'BEGIN{FS="_"}{if (${START_DATE}<=$$10 && $$9<=${END_DATE}){print $$0}}' )
INV_FILES=/g/data1/ub4/erai/grib/invariant/ei_oper_an_sfc_075x075_90N0E90S3585E_invariant

VTABLE=${WPSDIR}/ungrib/Variable_Tables/Vtable.ERA-interim.pl

inv/namelist.wps: namelist.wps
	mkdir -p inv
	cp namelist.wps $@
	# Change the prefix for surface fields
	sed -i $@ -e "s/\(prefix\s*=\).*/\1 'INV'/"
	# Change the dates
	sed -i $@ \
	    -e "/start_date/s/'[^']*'/'1989-01-01_12:00:00'/g" \
	    -e "/end_date/s/'[^']*'/'1989-01-01_12:00:00'/g"

.link_inv.done: inv/namelist.wps
	cd inv && ${WPSDIR}/link_grib.csh ${INV_FILES}
	@touch $@

.ungrib_inv.done: inv/namelist.wps .link_inv.done
	ln -sf ${VTABLE} inv/Vtable
	rm -f inv/inv:*
	cd inv && ${WPSDIR}/ungrib.exe
	@touch $@

# Extract surface level fields
sfc/namelist.wps: namelist.wps
	mkdir -p sfc
	cp namelist.wps $@
	# Change the prefix for surface fields
	sed -i $@ -e "s/\(prefix\s*=\).*/\1 'SFC'/"

.link_sfc.done: sfc/namelist.wps
	cd sfc && ${WPSDIR}/link_grib.csh ${SFC_FILES}
	@touch $@

.ungrib_sfc.done: sfc/namelist.wps .link_sfc.done
	ln -sf ${VTABLE} sfc/Vtable
	rm -f sfc/SFC:*
	cd sfc && ${WPSDIR}/ungrib.exe
	@touch $@

# Extract pressure level fields
pl/namelist.wps: namelist.wps
	mkdir -p pl
	cp namelist.wps $@
	# Use default prefix for pressure level fields
	sed -i $@ -e "s/\(prefix\s*=\).*/\1 'PL'/"

.link_pl.done: pl/namelist.wps
	cd pl && ${WPSDIR}/link_grib.csh ${PL_FILES}
	@touch $@

.ungrib_pl.done: pl/namelist.wps .link_pl.done
	ln -sf ${VTABLE} pl/Vtable
	rm -f pl/PL:*
	cd pl && ${WPSDIR}/ungrib.exe
	@touch $@

# Copy all the ungrib'd files to the top level for metgrid
.ungrib.done: .ungrib_sfc.done .ungrib_pl.done .ungrib_inv.done
	rm -f SFC:* PL:* INV:*
	ln -s pl/PL:* .
	ln -s sfc/SFC:* .
	ln -s inv/INV:* .
	@touch $@

# Run geogrid
.geogrid.done: namelist.wps
	mkdir -p geogrid
	ln -sf ${WPSDIR}/geogrid/GEOGRID.TBL.ERAI geogrid/GEOGRID.TBL
	${WPSDIR}/geogrid.exe
	@touch $@

# Run metgrid
.metgrid.done: namelist.wps .geogrid.done .ungrib.done 
	mkdir -p metgrid
	ln -sf ${WPSDIR}/metgrid/METGRID.TBL.ARW metgrid/METGRID.TBL
	ln -sf /projects/WRF/ERA-Interim/GEO:1989-01-01_12 GEO:1989-01-01_12
	${WPSDIR}/metgrid.exe
	@touch $@

