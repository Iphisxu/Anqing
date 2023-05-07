#!/bin/csh

# ======================= IOAPI-3.2 M3Tools ======================
#
# Usage: ./create_gridmask.csh >&! gridmask.log &
# 
# Author: Evan
# Date: 2023-05-04
# 
# ================================================================

# Set variables for directories
set HOME = /WORK/sysu_fq_1/xuyf/Model/CMAQ_aq4/PREP/mask
set WORKDIR = /WORK/sysu_fq_1/xuyf/software/ioapi_3.2/Linux2_x86_64ifort
set MCIP = /WORK/sysu_fq_1/xuyf/data/mcip

set INPDIR = ${HOME}/input
set OUTDIR = ${HOME}/output

# Define the list of input filenames
set region_list = (Anqing Hefei Chizhou Tongling Jiujiang Wuhu Maanshan)

# ============================ M3MASK ============================

set GRID_NAME = CN3AH_135X138
set YYYYDDD = 2023100

setenv COLROW Y                                                        # "Y" for col-row input, "N" for Lat-Lon input
setenv LLFILE ${MCIP}/${GRID_NAME}/${YYYYDDD}/GRIDCRO2D_${YYYYDDD}.nc  # path-name for M3IO gridded input file, e.g. GRIDCRO2D

cat << EOF > ${HOME}/mask.inp
y
EOF

cd ${WORKDIR}

foreach REGION (${region_list})
    setenv MASKDATA ${INPDIR}/df_${REGION}.csv                         # path-name for ASCII mask   input file
    if (! -f ${MASKDATA}) then
        echo "Error: Input file ${MASKDATA} does not exist"
        exit 1
    endif
    setenv MASKFILE ${OUTDIR}/${REGION}.nc                             # path-name for M3IO output file
    
    echo "Processing ${REGION}.nc"
    
    ./m3mask < ${HOME}/mask.inp >&! ${HOME}/m3mask.log
    
    if ($status != 0) then
        echo "Error: m3mask failed with status $status"
        exit 1
    endif
    
end

echo "M3MASK program completed successfully"

# =========================== M3MERGE ============================

set OUTFILE = GRIDMASK_int.nc

# Create input control file
cat << EOF > ${HOME}/merge.inp
y
EOF

foreach REGION (${region_list})
  # Add entry for each input file to control file
  cat << EOF >> ${HOME}/merge.inp
${REGION}.nc
n
1
${REGION}
0
EOF
end

# Add final entries to control file
cat << EOF >> ${HOME}/merge.inp
NONE
0
0
0
0
${OUTFILE}
EOF

# Check that input files exist
foreach FILE (${region_list})
    if (! -f ${OUTDIR}/${FILE}.nc) then
        echo "Error: Input file ${FILE}.nc does not exist"
        exit 1
    endif
    cp ${OUTDIR}/${FILE}.nc .
end

# Execute m3merge and log output
./m3merge < ${HOME}/merge.inp >&! ${HOME}/m3merge.log

if ($status != 0) then
    echo "Error: m3merge failed with status $status"
    exit 1
endif

# Move the output file to the output directory
mv ${OUTFILE} ${OUTDIR}

# Remove input files
rm *.nc

echo "M3MERGE program completed successfully"

# ==================== Convert int to float =====================

cd ${OUTDIR}

set command_str = ""
foreach region ($region_list)
  set command_str = "${command_str}${region}=float(${region}); "
end

ncap2 -s "${command_str}" GRIDMASK_int.nc GRIDMASK.nc

echo "int convert to float completed successfully"