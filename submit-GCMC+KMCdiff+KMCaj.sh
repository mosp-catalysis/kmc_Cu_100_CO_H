#!/bin/bash

shopt -s nullglob
CURDIR=$PWD

# Check for required files
REQUIRED_FILES=("GCMC.exe" "input-forGCMC" "ini.xyz" "gen-random-cov-slab.exe" 
                "kmc.exe" "Total_bulk.xyz" "input-forKMC1diff" "input-forKMC2aj")

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file '$file' is missing!" >&2
        exit 1
    fi
done

# Parameter validation
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; then
    echo "Error: Five parameters are required!"
    echo "Parameters: major cycle start, end; first major cycle diff and aj start, end; whether first major cycle needs GCMC (1 for yes, 0 for no)"
    echo "For a completely new task, set major cycle start to 1; third and fourth parameters to a complete minor cycle starting from 1; fifth parameter to 1"
    exit 1
fi

if [ $4 -le $2 ]; then
    echo "Error: Parameter order may be incorrect!"
    echo "Parameters: major cycle start, end; first major cycle diff and aj start, end; whether first major cycle needs GCMC (1 for yes, 0 for no)"
    echo "For a completely new task, set major cycle start to 1; third and fourth parameters to a complete minor cycle starting from 1; fifth parameter to 1"
    exit 1
fi

# Define function to run GCMC
run_gcmc() {
    local cycle=$1
    mkdir "${cycle}-GCMC"
    cd "${cycle}-GCMC" || exit

    echo "... executing ${cycle}-GCMC ..."
    cp "${CURDIR}/GCMC.exe" ./
    cp "${CURDIR}/input-forGCMC" ./input
    cp "${CURDIR}/ini.xyz" ./
    ./GCMC.exe >> stdout
    echo "${cycle}-GCMC finished!"
    
    # Randomly scatter points based on coverage from GCMC
    cp "${CURDIR}/gen-random-cov-slab.exe" ./
    ./gen-random-cov-slab.exe >> stdout

    cp ./last_one_random.xyz "${CURDIR}/ini.xyz"
    cd ..
}

# Define function to run KMC, including 1diff and 2aj steps
run_kmc() {
    local cycle=$1
    local j=$2

    for step in "1diff" "2aj"; do
        mkdir "${cycle}-KMC-${j}-${step}"
        cd "${cycle}-KMC-${j}-${step}" || exit

        echo "... executing ${cycle}-KMC-${j}-${step} ..."        
        cp "${CURDIR}/kmc.exe" ./
        cp "${CURDIR}/ini.xyz" ./
        cp "${CURDIR}/Total_bulk.xyz" ./
        cp "${CURDIR}/input-forKMC${step}" ./input
        ./kmc.exe >> stdout
        echo "${cycle}-KMC-${j}-${step} finished!"

        cp ./last_one.xyz "${CURDIR}/ini.xyz"
        cd ..
    done
}

# If the fifth parameter is 1, execute the first GCMC
if [ "$5" -eq 1 ]; then
    run_gcmc "$1"
fi

# Process the first major cycle KMC
for j in $(seq "$3" "$4"); do
    run_kmc "$1" "$j"
done

# Process the remaining cycles
for i in $(seq $(($1 + 1)) "$2"); do
    run_gcmc "$i"
    for j in $(seq 1 "$4"); do
        run_kmc "$i" "$j"
    done
done


