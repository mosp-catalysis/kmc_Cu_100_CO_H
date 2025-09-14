> **Note**  
> This is a demo. Formal version will be released in the future.  

The combination of Grand Canonical Monte Carlo (GCMC) and Environmental kinetic Monte Carlo (EKMC) simulations for Cu(100) surface in eCO<sub>2</sub>RR conditions. 

There is a demo that can be executed in linux environment. Compilation environment: GNU Fortran (GCC) 8.5.0 20210514 (Red Hat 8.5.0-18)  

The parameters required for GCMC and EKMC simulations can be defined in the corresponding **input-for\*** files. The long GCMC+EKMC simulations performed in the article can be executed using the **submit-GCMC+KMCdiff+KMCaj.sh** script. 

**Total_bulk.xyz** is a coordinate file that contains a Cu fcc bulk. This file defines the lattice space, which is the complete set of all possible lattice points used in the EKMC simulation; periodic doundary conditions will be applied in the x and y directions.  

**ini.xyz** is a customizable input structure file that defines which lattice points in the space are occupied by atoms in the intial structure. In this case, the initial structure is a Cu(100) slab model spanning a  35nm × 35nm region.  

**last_one.xyz** is generated after each simulation run and contains the final atomic configuration together with output data. 
- The second line lists, in order: the filename, the number of atomic-jump events, the total steps, and the simulation time (in seconds). For simulations submitted with the **submit-GCMC+KMCdiff+KMCaj.sh** script, these values can be summed to obtain total steps and total time; related post-processing tools will be provided later. 
- The fifth column records the state of the site, where *0* represents an empty surface site, *1* represents a CO-occupied surface site, *2* represents a H-occupied surface site, and *5* means a bulk site. 
