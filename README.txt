# Fiar Clustering for Diverse and Experienced Groups

This code accompanies the paper "Fair Clustering for Diverse and Experienced Groups" by Ilya Amburg, Nate Veldt and Austin Benson.

All code is written in Julia 1.3.1.

### Using the datasets and code.

The folder "datasets" contains the data we analyzed in the paper.

- All files have format "(reviewer id) (category id) (unix timestamp)\n".

- Algebra and geometry datasets have the category identities printed in the files containing "tags".

The folder "text" contains files of results written when running the code.

The folder "plots" contains the plots used in the paper.

The folder "code" contains all the code used to generate the results in the paper.

- The files containing "parsing" in the name were used to parse code from datadumps.

- The file containing "printing" is used to generate all the plots in the paper. The other files are used to generate the results, most notably "fair-categorical-edge-clustering-optimal.jl" which contains the main LP solvers used in all of the experiments for the paper.

### Questions?

For questions, please contact Ilya at ia244@cornell.edu