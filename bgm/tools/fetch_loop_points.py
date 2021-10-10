import rifflab
import sys
import json

def determine_cues(filename):
	loop_point = None
	end_point = None
	
	with open(filename, 'rb') as wav:
		p = rifflab.object_from_file(wav)
		for i in p:
			if i.name == 'cue ':
				cue_chunk = i
			if i.name == 'smpl':
				smpl_chunk = i
		
		loop_point  = int.from_bytes(cue_chunk.data[-4:], byteorder='little')
		end_point   = int.from_bytes(smpl_chunk.data[-12:-8], byteorder='little')
		
		return (loop_point, end_point)

# Read json file
with open(sys.argv[1], 'r') as msu:
	j = json.load(msu)
	for i in j['tracks']:
		# try adding loop points from the exported wav
		if 'loop' not in i:
			fn = i['file'].replace('\\','/')
			try:
				loop_points = determine_cues(fn)
				i['loop'] = loop_points[0]
				i['trim_end'] = loop_points[1]
			except:
				loop_points = None

# make json file
with open(sys.argv[2], 'w') as msu:
	json.dump(j, msu, indent=4)
