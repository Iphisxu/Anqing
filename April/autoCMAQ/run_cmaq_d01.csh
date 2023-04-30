#!/bin/csh

# Print the current date on screen
date

# Set the start and end dates for running CMAQ
set START_DATE = "2023-03-26"
set END_DATE = "2023-04-01"

# Alternative grid names:
set GNAME = "CN27AH_101X101"
# set GNAME = "CN9AH_112X106"
# set GNAME = "CN3AH_135X138"

# Convert YYYY-MM-DD to YYYYDDD
set START_JULIAN = `date -ud "${START_DATE}" +%Y%j`
set END_JULIAN = `date -ud "${END_DATE}" +%Y%j`

# Set the working directory
setenv WORKDIR /WORK/sysu_fq_1/xuyf/Model/CMAQ_aq4/
cd $WORKDIR || exit 1

# Loop through each time interval, with a 3 day step
while ( $START_JULIAN < $END_JULIAN - 3 )
  
  # Define the time period for this run as 6 days
  set START = `datshift ${START_JULIAN} 0`
  set END = `datshift ${START_JULIAN} 5`
  set START_YEAR = `echo $START | cut -c 1-4`
  set START_MON = `echo $START | cut -c 5-6`
  set START_DAY = `echo $START | cut -c 7-8`
  set END_YEAR = `echo $END | cut -c 1-4`
  set END_MON = `echo $END | cut -c 5-6`
  set END_DAY = `echo $END | cut -c 7-8`
  set RUN_START = "${START_YEAR}-${START_MON}-${START_DAY}"
  set RUN_END = "${END_YEAR}-${END_MON}-${END_DAY}"
  
  # Create a new folder for this run and copy the CCTM files
  set CCTM_FOLDER = "cctm_$START"
  set EMIS_FOLDER = "emis_$START"

  if ( ! -d "${CCTM_FOLDER}" ) then
    cp -r CCTM $CCTM_FOLDER || exit 1
  endif
  if ( ! -d "PREP/${EMIS_FOLDER}" ) then
    cp -r PREP/emis_2019 PREP/$EMIS_FOLDER || exit 1
  endif

  cd $CCTM_FOLDER/scripts ||  exit 1

  # Change the CCTM script to point to the new folder and set output directory
  sed -i 's/CCTM\/scripts/'"$CCTM_FOLDER"'\/scripts/g' run_cctm_${GNAME}.csh
  sed -i 's/setenv OUTDIR .*/setenv OUTDIR \${CMAQ_DATA}\/output_'"${CCTM_FOLDER}"'_\${APPL} /' run_cctm_${GNAME}.csh

  # Set the start and end dates for this run in the CCTM script
  sed -i 's/set START_DATE .*/set START_DATE = "'"$RUN_START"'" /' run_cctm_${GNAME}.csh
  sed -i 's/set END_DATE .*/set END_DATE   = "'"$RUN_END"'" /' run_cctm_${GNAME}.csh

  # Set anthropogenic emission directory
  sed -i 's/set EMISpath .*/set EMISpath = \$INPDIR\/'"$EMIS_FOLDER"'/' run_cctm_${GNAME}.csh
  sed -i 's/cd ..\/..\/PREP\/emis_2019/cd ..\/..\/PREP\/'"$EMIS_FOLDER"'/' run_cctm_${GNAME}.csh
  sed -i '/run_\${GRID_NAME}.emis/i\sed -i "s|cd PREP\\/emis_2019|cd PREP\\/'"$EMIS_FOLDER"'|" run_\${GRID_NAME}.emis' run_cctm_${GNAME}.csh
  sed -i '/run_\${GRID_NAME}.emis/i\sed -i '\''s|setenv EMIS_1 .*|setenv EMIS_1 \\${CMAQ_DATA}\\/'"$EMIS_FOLDER"'\\/emis.\\${GRID_NAME}.ncf|'\'' run_\${GRID_NAME}.emis' run_cctm_${GNAME}.csh

  # Print the start and end dates for this run
  echo ${RUN_START} ${RUN_END}

  # Run the CCTM script
  # yhbatch -N 15 -n 300 run_cctm_${GNAME}.csh || exit 1
  cd ../..    

  # Move to the next time interval
  @ START_JULIAN = $START_JULIAN + 3
  echo ${START_JULIAN}
end
