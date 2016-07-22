#!/usr/bin/env python


import optparse
import sys
import os
import datetime
import time
import subprocess
import re
import math


import ReadInputParameters
from ReadInputParameters import ReadInputParameters
from ReadInputParameters import WriteMessageToFile
from ReadInputParameters import OptionsList
from ReadInputParameters import CheckFileExist
from ReadInputParameters import NamesClass


def ReactionetLasso(options):
	Ncv = 5

	# write log-file
	Names = NamesClass()
	Names.GetNames(options, 0)
	StatusFile = '{0}_log.txt'.format(Names.JobsOutput)

	if os.path.isfile(StatusFile):
		subprocess.call("rm " + StatusFile , shell=True)
	if os.path.isfile(Names.JobsOutput + "_ERR.txt"):
		subprocess.call("rm " + Names.JobsOutput + "_ERR.txt", shell=True)
	if os.path.isfile(Names.JobsOutput + "_OUT.txt"):		
		subprocess.call("rm " + Names.JobsOutput + "_OUT.txt", shell=True)

	# submit CV-jobs
	WriteMessageToFile(StatusFile, '\nsubmit CV-jobs\n')
	for cv in range(1, Ncv+1):
		Names.GetNames(options, cv)
		FileName = '{0}/{1}'.format(options.DefaultPath, Names.ResultsCV)
		if  not CheckFileExist(FileName, StatusFile):
			Param = '"(\'{0}\', {1:d}, \'{2}\', {3:d}, {4:d}, {5:f}, \'{6}\', \'{7}\', \'{8}\')"'.format(options.ModelName, cv,
				options.GradientType, options.NMom, options.Nboot, options.p, options.PriorGraph, options.PriorTopology, options.connect)
			
			CallSeqLine = 'bsub -n 1 -e {0}_ERR.txt -o {0}_OUT.txt -W "{1:d}:00" -R "rusage[mem={2:d}]" matlab -singleCompThread -nodisplay -r ReactionetLasso{3}'.format(Names.JobsOutput, 
				Names.Time, Names.Mem, Param)
			print CallSeqLine
			os.system(CallSeqLine)

	# wait for CV-jobs to finish
	WriteMessageToFile(StatusFile, '\nwait for CV-jobs to finish\n')
	for cv in range(1, Ncv+1):
		Names.GetNames(options, cv)
		FileName = '{0}/{1}'.format(options.DefaultPath, Names.ResultsCV)
		while  not CheckFileExist(FileName, StatusFile):
			time.sleep(30)
			if os.path.isfile(Names.JobsOutput + "_ERR.txt") and (os.path.getsize(Names.JobsOutput + "_ERR.txt") > 0):
				WriteMessageToFile(StatusFile, '\nERROR')
				return False

	# submit stability selection
	WriteMessageToFile(StatusFile, '\nsubmit stability selection\n')
	FileName = '{0}/{1}'.format(options.DefaultPath, Names.Results)
	# if  not CheckFileExist(FileName, StatusFile):
	Param = '"(\'{0}\', \'{1}\', {2:d}, {3:d}, {4:f}, \'{5}\', \'{6}\', \'{7}\')"'.format(options.ModelName,
			options.GradientType, options.NMom, options.Nboot, options.p, options.PriorGraph, options.PriorTopology, options.connect)
	CallSeqLine = 'bsub -n 1 -e {0}_ERR.txt -o {0}_OUT.txt -W "{1:d}:00" -R "rusage[mem={2:d}]" matlab -singleCompThread -nodisplay -r ReactionetLassoSS{3}'.format(Names.JobsOutput, 
			Names.Time, Names.Mem, Param)
	os.system(CallSeqLine)
		# CallSeqLine = 'bsub -n 1 -e {0}_ERR.txt -o {0}_OUT.txt -W "{1:d}:00" -R "rusage[mem={2:d}]" matlab -singleCompThread -nodisplay -r TopologicalFiltering{3}'.format(Names.JobsOutput, 
		# 		Names.Time, Names.Mem, Param)
		# os.system(CallSeqLine)
	
	WriteMessageToFile(StatusFile, '\nFINISHED!!!')
	return True

options = ReadInputParameters()
optionsIter = ReadInputParameters()

OptList = OptionsList()
OptList.AssignOptionsLists(options)

l = 0
maxProcess = 10
WaitTime = 10*60


for iGT in range(len(OptList.GradientTypeList)):
	optionsIter.GradientType = OptList.GradientTypeList[iGT]
	for iB in range(len(OptList.NbootList)):
		optionsIter.Nboot = OptList.NbootList[iB]	
		for iNM in range(len(OptList.NMomList)):
			optionsIter.NMom = OptList.NMomList[iNM]
			for ip in range(len(OptList.pList)):
				optionsIter.p = OptList.pList[ip]
				ReactionetLasso(optionsIter)
				l = l+1
				if l > maxProcess:
					time.sleep(WaitTime)
					l = 0
