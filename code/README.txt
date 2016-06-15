Reactionet lasso - Structure Learning of Stochastic Reaction Networks with Sparse Regression

Reactionet lasso package documentation:
You can run test examples with: TestReactionetLasso.m

IMPORTANT: to run reactionet lasso you should assemble your data in a specific format, from which procedure will read it. Otherwise, it won't be able to find the data.

Settings and list of parameters:
•	ModelName 
optional:
•	GradientType (splines, FDS; default = splines) = gradients approximation method
•	Nboot ( > 10; default = 100) = number of bootstrap samples for
•	NMom (= 1, 2; default = 2) = order of moments used for gradients
•	p (int, 0 < p <= 1; default = 1) = suggested detection probability
•	PriorGraph (string with filename; default = '') = list of a priori known reactions

DATA: All the initial data (time points, abundances, species names) should be stored in the following format in the following folder: 'data/$ModelName/' in a mat-filed called 'data', (for example 'data/ES100kDT4sp9tp/data.mat'). Inside of the file data should be arranged into following variables: - Information about time points should be stored in variable: Timepoints = (N_Tx1 double), N_T - number of time points - Snapshot data points should be stored in 1xN_T cell array named data - Names of measured species should be stored in a cell array 1xN_species called SpeciesNames

PRIOR KNOWLEDGE: You can predefine which reactions you want to consider by defining stoichiometric matrix in file Topology.mat in your data-folder. Otherwise, it will automatically construct full graph of all possible topologies. Topology.mat should contain following variables: - stoich = (N_species x N_reactions) - stoichiometric matrix
You can also specify a priory known reaction (reactions, which won't be allowed to exclude from learning procedure) in a file: filename.mat and specify its name in running options as for example ReactionetLassoMain( ModelName, p, 'filename'). File with prior knowledge reactions should contain varible: - indx - indexes of priory known reactions in stoichiometric matrix

OUTPUT: Reactionet lasso creates several output folders: - Moments - contains all the estimated moments - LinearSystem - here information about Design matrix and Response vector is stored - resultsCV - intermediate results for each cross-validation fold - results - final results - plots - supporting plots for final results

