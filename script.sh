#!/bin/sh
################################################### Script for Single-point Jobs Post MD Simulation #########################################################
-----------------------------------------------------------------------------------------------------------------------------------
# What this Bash script does:
 # Pulls atomic coordinates step-by-step from a .mol file of the completed MD simulation job.
 # Catenates coordinates of each step with a file called 'head' containing the keywords required to run a single point calculation.
 # Collects the new .out and .mol files after the single point calculation is completed.  
# What this Bash script can double down as:
 # Atomic coordinate-puller from a .mol file after a deMon2k MD simulation job is completed.
 # Job submission automator on an HPC cluster.

## NOTE 1: This script was written for the deMon2k software package but can be generalized.
## NOTE 2: The directory architecture for this script needs to be tweaked as per convenience.
-----------------------------------------------------------------------------------------------------------------------------------
for ((a = 1 ; a <=16000; a=a+20)) # 'a' is an indicator of the line number in the .mol file. 16000, here, happened to be the number of lines in my .mol file.
do
c=$((a * 6)) # 'c' is the variable for updating the number of lines we are reading from the top of the .mol file. Will depend on number of atoms in the MD simulation, for instance, here it is 6.
head -$c deMon.mol | tail -4 >> /tmp/prayag/coordinates/deMon.xyz.$a # Collecting the first 'c' lines from top, piping it, collecting the last 4 lines of those 'c' lines. These are the coordinates, saved in a folder called 'coordinates' (lol). Why last 4, tho?Because that was just the structure of my .mol file 
cat head /tmp/prayag/coordinates/deMon.xyz.$a > /tmp/prayag/inputs/deMon.inp.$a # Catenating the coordinates with a file called 'head' containing the keywords for the deMon2k job. Saving the joint files inside a folder called 'inputs'.
cp /tmp/prayag/inputs/deMon.inp.$a /tmp/prayag/running/deMon.inp # Since, deMon2k accepts inputs in the form of 'deMon.inp', a copy of each input file of the form 'deMon.inp.index' is made and saved in a folder called 'running'. This folder will have be the one inside which the jobs will run. It should contain the necessary files (like AUXIS, BASIS, ECPS, MCPS, FFDS etc.) required to run the job.
cd ../running # Since we need to run the job, we need to get inside the folder with deMon.inp, basis files, etc. This line is completely dependent on one's directory architecture.
mpirun -np 12 /home1/shashank/deMon/deMon.5.0/deMon/5.0/object.mpi/deMon.5.0.mpi > outfile # Calling deMon2k to start the job.
cp /tmp/prayag/running/deMon.mol /tmp/prayag/mols/deMon.mol.$a # After job completion, the new .mol file, of the completed job, is saved in a separate folder 'mols'.
cp /tmp/prayag/running/deMon.out /tmp/prayag/outputs/deMon.out.$a # After job completion, the .out file is saved in a separate folder 'outputs'.
cd ../JOB # Re-navigating into the folder contaning the initial .mol file from which coordinates had to be pulled.
#echo $b
done
