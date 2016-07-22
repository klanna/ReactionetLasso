#!/usr/bin/env python

import optparse
import sys
import os
import datetime
import time
import subprocess
import re
from datetime import datetime


def ReadInputParameters():		
	parser = optparse.OptionParser()
	parser.add_option('-m', '--ModelName', dest='ModelName', help='Name of the folder with data')
	parser.add_option('-g', '--GradientType', dest='GradientType', help='splines | FDS')
	parser.add_option('-b', '--Nboot', dest='Nboot', help='20 | 100', type=int, default=100)
	parser.add_option('-o', '--NMom', dest='NMom', help='1 | 2', type=int)
	parser.add_option('-p', '--p', dest='p', help='0.05', type=float)
	parser.add_option('-d', '--DefaultPath', dest='DefaultPath', default = '../../../../scratch/klanna/ReactionetLasso/')
	parser.add_option('-a', '--PriorGraph', dest='PriorGraph', default = '')
	parser.add_option('-t', '--PriorTopology', dest='PriorTopology', default = 'Topology')
	parser.add_option('-c', '--connect', dest='connect', default = '')

	(options, args) = parser.parse_args()
	return options

def CheckFileExist(FileName, StatusFile):
	if os.path.isfile(FileName):
		WriteMessageToFile(StatusFile, 'EXIST: {0}'.format(FileName) )
		return True
	else:
		return False
		
def WriteMessageToFile(Fname, Mes):
	f = open(Fname, 'a+')
	f.write(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '\n')
	f.write(Mes + '\n')
	f.close()


class OptionsList(object):
	GradientTypeList = ['splines', 'FDS']
	NbootList = [100]
	NMomList = [2, 1]
	pList = [0.01, 0.05, 0.1, 0]
	
	def AssignOptionsLists(self, options):
		if not (options.GradientType is None):
			self.GradientTypeList = [options.GradientType]

		if not (options.Nboot is None):
			self.NbootList = [options.Nboot]

		if not (options.NMom is None):
			self.NMomList = [options.NMom]

		if not (options.p is None):
			self.pList = [options.p]

class NamesClass(object):
	def GetNames(self, options, cv):
		if options.p == 0:
			self.SysName = '{0}_{1}{2:d}_Boot{3:d}_p{4:d}'.format(options.ModelName, options.GradientType, options.NMom, options.Nboot, 100)
		else:
			self.SysName = '{0}_{1}{2:d}_Boot{3:d}_p{4:d}'.format(options.ModelName, options.GradientType, options.NMom, options.Nboot, int(options.p*100))

		self.JobsOutput = '../JOBS/{0}{3}{1}_{2}'.format(self.SysName, options.PriorTopology, options.PriorGraph, options.connect)	    
		self.Moments = 'Moments/{0}/CV_{1:d}/'.format(options.ModelName, cv)
		self.ResultsCV = 'resultsCV/{0}/CV_{1:d}/{4}{2}_{3}/StepLASSO.mat'.format(self.SysName, cv, options.PriorTopology, options.PriorGraph, options.connect)
		# self.ResultsCV = 'resultsCV/{0}/CV_{1:d}/{4}{2}_{3}/StepStabilitySelection.mat'.format(self.SysName, cv, options.PriorTopology, options.PriorGraph, options.connect)
		
		self.Results = 'results/{0}/{3}{1}_{2}/StabilitySelection.mat'.format(self.SysName, options.PriorTopology, options.PriorGraph, options.connect)
		self.Mem = 6*1028
		self.Time = 4
		