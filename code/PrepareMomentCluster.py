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
	StatusFile = '{0}_Moments_log.txt'.format(Names.JobsOutput)
	StatFile = '{0}_Moments'.format(Names.JobsOutput)

	if os.path.isfile(StatusFile):
		subprocess.call("rm " + StatusFile , shell=True)
	if os.path.isfile(Names.JobsOutput + "_ERR.txt"):
		subprocess.call("rm " + StatFile + "_ERR.txt", shell=True)
	if os.path.isfile(Names.JobsOutput + "_OUT.txt"):		
		subprocess.call("rm " + StatFile + "_OUT.txt", shell=True)

	# submit CV-jobs
	WriteMessageToFile(StatusFile, '\nsubmit CV-jobs\n')
	l = 0
	WaitTime = 60*10
	maxProcess = 100
	for cv in range(1, Ncv+1):
		for boot in range(1, options.Nboot+1):
			Param = '"({7}, \'{0}\', {1:d}, \'{2}\', {3:d}, {4:d}, {5:f}, \'{6}\')"'.format(options.ModelName, cv,
				options.GradientType, options.NMom, options.Nboot, options.p, options.PriorGraph, boot)
			
			CallSeqLine = 'bsub -n 1 -e {0}_ERR.txt -o {0}_OUT.txt -W "{1:d}:00" -R "rusage[mem={2:d}]" matlab -singleCompThread -nodisplay -r PrepareMomentsBoot{3}'.format(StatFile, 
				1, Names.Mem, Param)
			# print CallSeqLine
			os.system(CallSeqLine)
			l = l+1
			if l > maxProcess:
				time.sleep(WaitTime)
				l = 0
			

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

