# LOL

- [repo contents](#repo-contents)
- [installation guide](#installation-guide)
- [reproduction instructions](#reproduction-instructions)

For pseudocode for all algorithms, see Appendix of draft in `Draft`.


## Repo Contents:

- [**Code**](https://github.com/neurodata-papers/LOL/tree/master/Code): folder containing MATLAB & R code to reproduce all results in the manuscript
- [**Draft**](https://github.com/neurodata-papers/LOL/tree/master/Draft): contains tex stuff for our draft
- [**Figs**](https://github.com/neurodata-papers/LOL/tree/master/Figs): all figures from the plotting code used in the draft
- [**Data**](https://github.com/neurodata-papers/LOL/tree/master/Data): contains the processed raw data to reproduce all results in the draft, and existing results to readily generate the figures.


## Installation guide:

### Dependencies

- MATLAB (works in R2016B) 
- osx (works in sierra 10.12.5)

### Demo

1. Navigate to folder `XXX`.
1. To load demo data, type `load demo.mat`, which loads X and Y into the workspace. Note that X is a n-by-d matrix and Y is a n-by-q matrix.
2. To run on data, in MATLAB, type `[a,b,c] = MGC(X,Y)`
3. The output will be a set of figures and the p-value, test statistic, optimal scales, XXX.




## Reproduction Instruction

### MATLAB

Add all folders and subfolders of MGC to the path. 
To repeat the simulations and real data experiments, run any of the following:
- `run_1d_sims;`
- `run_hd_sims;`
- `run_realData;` 
- `plot_all;` % to run all the plots

The running time on a standard i7 desktop takes around 1 day for 1D and HD simulations, and around 10 minutes for the real data. 

### R

All codes are in MGC/Code/R, and do `run_realData` to give an example of MGC running on real data.
Typical running time: 1 minute on a standard i7 desktop



