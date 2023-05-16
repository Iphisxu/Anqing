#!/bin/bash

# Set the path of WRF output files
output_path="/WORK/sysu_fq_1/xuyf/data/wrf"

# Set the start and end dates (in "YYYY-MM-DD" format)
start_date="2023-04-21"
end_date="2023-04-24"

# Convert the start and end dates to Julian date format
start_julian=$(date -d "$start_date" +"%Y%j")
end_julian=$(date -d "$end_date" +"%Y%j")

# Initialize the current date
curr_julian="$start_julian"

# Process between the start and end dates
while [ "$curr_julian" -le "$end_julian" ]; do

    curr_dir="wrf_${curr_julian}"

    # Check if the directory exists
    if [ ! -d "${output_path}/${curr_dir}" ]; then
        echo "Warning: ${output_path}/${curr_dir} does not exist."
    else

        cd "${output_path}/${curr_dir}"

        tmp_script="run_ncap2.sh"

        cat <<EOF > "$tmp_script"
#!/bin/bash

# Process all wrfout files
for wrfout_file in wrfout_d0*; do
    echo "Processing \${wrfout_file}"
    ncap2 -s "U=U/2; V=V/2; U10=U10/2; V10=V10/2" "\$wrfout_file" -A
done

EOF

        chmod +x "$tmp_script"

        # Using Multiple Processors
        { yhrun -N 1 -n 8 "$tmp_script"; } || { echo "Error: yhrun command failed."; exit 1; }
        
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!! Successfully Processed in ${curr_dir} !!"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        rm -f "$tmp_script"

    fi


    # Increment the current date by 3 days and move to the next directory
    curr_julian=$(date -d "${start_date} +$((curr_julian - start_julian + 3)) days" +"%Y%j")
done
