'''
Tools for easily manipulating RIFF chunks used in e.g. WAV, SF2, WEBP.
'''

'''
some terminology:
Serialized = turned into a file format
Deserialized = turned into object representation you can nicely code with
'''

class FileDataPointer(object):
	'''
	Represents a pointer to a block of data within a File object. Necessary
	for large files.
	'''
	def __init__(self, file_, loc, num_bytes):
		'''
		Args:
		    file_ (_io.BufferedReader): a File object to which the data
		        is located.
		    loc (int): the location of the data, in number of bytes.
		    num_bytes (int): length of data.
		
		Returns:
		    A FileDataPointer object.
		'''
		self.file = file_
		self.location = loc
		self.num_bytes = num_bytes
	
	def __repr__(self):
		return '<Pointer for data @{} : {} bytes>'.format(hex(self.location), self.num_bytes)
	
	def get(self):
		'''
		Returns:
		    A bytes object containing the actual data that was pointed
		    to.
		'''
		self.file.seek(self.location)
		return self.file.read(self.num_bytes)


class RiffSubchunk(object):
	'''
	Represents a subchunk in a RIFF file. A subchunk is made up of:
	    1. the identifier (a 4-character code, aka "FourCC"), e.g. "data"
	    2. the length of the data as a 4 byte, little-endian number
	    3. the data itself
	    4. if the amount of bytes that make up this chunk is not even,
	       some zero bytes (b'\\x00') are appended to the end
	'''
	def __init__(self, name, data=b''):
		'''
		Args:
		    name (str): a four character string identifier / FourCC
		    data (bytes, optional): preload this object with some data.
		        Defaults to an empty data set.
		'''
		self.name = name
		self.data = data
	
	def __repr__(self):
		if isinstance(self.data, FileDataPointer):
			return '<RIFF subchunk "{}", {} bytes (@ {})>'.format(self.name, self.data.num_bytes, hex(self.data.location))
		else:
			return '<RIFF subchunk "{}", {} bytes>'.format(self.name, len(self.data))
	
	@property
	def data(self):
		'''
		The data contained in this subchunk. This can either be raw data
		in the form of bytes, or it may be a pointer object to data in
		a file in the form of a FileDataPointer.
		'''
		return self._data
	@property
	def name(self):
		'''
		The FourCC identifier of this subchunk (str).
		'''
		return self._name
	@data.setter
	def data(self, data):
		if isinstance(data, bytes):
			pass
		elif isinstance(data, FileDataPointer):
			pass
		else:
			raise TypeError('data must be in bytes or a FileDataPointer')
		self._data = data
	@name.setter
	def name(self, name):
		if len(name) > 4:
			raise SyntaxError('name must be no more than 4 characters')
		# if less than 4 characters, pad the string with spaces
		self._name = name.ljust(4, ' ')
	
	def from_data(self, data):
		'''
		Generates a RiffSubchunk from raw RIFF chunk data in the form of
		<name><size><bytes>. <bytes> will be read according to <size>.
		
		Args:
		    data (bytes): the raw RIFF chunk data, including its'
		        identifier.
		
		Returns:
		    The data, represented as a RiffSubchunk object.
		'''
		if not isinstance(data, bytes):
			raise TypeError('data must be in bytes')
		
		self.name = bytes[:4].decode('ascii')
		
		# how many bytes to expect
		length = int.from_bytes(bytes[4:8], byteorder='little')
		
		self.data = bytes[8:length-4]
		return self
	
	def serialize(self):
		'''
		Outputs a bytes representation of the RIFF chunk object. Use this
		when saving to a file.
		
		Returns:
		    The binary representation of the RiffSubchunk as bytes.
		'''
		s = bytes(self.name, 'ascii')
		
		if isinstance(self.data, FileDataPointer):
			# extract the data from the pointer 
			# and put it in the output
			data_length = self.data.num_bytes
			
			s += data_length.to_bytes(4, byteorder='little')
			
			s += self.data.get()
			
			if data_length % 2:
				# if number of bytes odd, pad one zero
				s += b'\x00'
		else:
			if len(self.data) % 2:
				# if number of bytes odd, pad one zero
				self.data += b'\x00'
			
			s += len(self.data).to_bytes(4, byteorder='little')
			s += self.data
		return s


class RiffList(list):
	'''
	Represents a RIFF form or list chunk, in the following format:
		1. type of chunk (e.g. "RIFF" or "LIST")
		2. the length of the data as a 4 byte, little-endian number
		   (this includes the following identifier)
		3. the identifier (a 4-character code, aka "FourCC"), e.g. "DATA"
		4. the data itself
	
	This object can be manipulated just as regular Python lists would, and
	can contain RiffSubchunks as well as RiffLists inside itself.
	'''
	def __init__(self, init_list=[], list_type='RIFF', list_name='DATA'):
		'''
		Args:
		    init_list (list or RiffList, optional): generate a RiffList
		        from a specified list. This list must *only* contain
		        RiffSubchunks and/or RiffLists.
		    list_type (str, optional): a 4 character string as the chunk type.
		        Defaults to 'RIFF'.
		    list_name (str, optional): a 4 character string identifying the chunk itself.
		        Defaults to 'DATA'.
		'''
		self.kind = list_type
		self.name = list_name
		for i in init_list:
			if not (isinstance(i, RiffSubchunk) or isinstance(i, RiffList)):
				raise TypeError('Incompatible element: {} (objects must be RiffSubchunk or RiffList)'.format(i))
		super(RiffList, self).__init__(init_list)
	
	def __repr__(self):
		return '<{} chunk "{}", {} subchunks>'.format(self.kind, self.name, len(self))
	
	@property
	def kind(self):
		'''
		The type name of the chunk. (str)
		'''
		return self._kind
	@property
	def name(self):
		'''
		This chunk's identifier. (str)
		'''
		return self._name
	@kind.setter
	def kind(self, list_type):
		if len(list_type) > 4:
			raise SyntaxError('type must be no more than 4 characters')
		# if less than 4 characters, pad the string with spaces
		self._kind = list_type.ljust(4, ' ')
	@name.setter
	def name(self, list_name):
		if len(list_name) > 4:
			raise SyntaxError('name must be no more than 4 characters')
		# if less than 4 characters, pad the string with spaces
		self._name = list_name.ljust(4, ' ')
		
	def __add__(self, other):
		return self.__class__(list.__add__(self, other))
	def __mul__(self, other):
		return self.__class__(list.__mul__(self, other))
	def append(self, other):
		if not (isinstance(other, RiffSubchunk) or isinstance(other, RiffList)):
			raise TypeError('appended object must be RiffSubchunk or RiffList')
		super(RiffList, self).append(other)
	
	def serialize(self):
		'''
		Outputs a bytes representation of the RIFF chunk object. Use this
		when saving to a file.
		
		Returns:
		    The binary representation of the RiffList as bytes.
		'''
		# outputs a binary representation of the RIFF list
		name = bytes(self.kind, 'ascii')
		
		# begin data with the chunk fourcc
		data = bytes(self.name, 'ascii')
		
		# iterate over every element and serialize it into the list
		for i in self:
			data += i.serialize()
		
		s = name
		s += len(data).to_bytes(4, byteorder='little')
		s += data
		return s


def object_from_file(file_, recursion_level=1, as_pointer=False):
	'''
	Creates a RiffList or RiffSubchunk object from a RIFF file.
	
	Args:
	    file_ (_io.BufferedReader): a loaded RIFF file object.
	    recursion_level (int, optional): how many levels (lists -> lists -> ...)
	        to go down. Defaults to 1 (meaning the file is read as a
	        single chunk with subchunks).
	    as_pointer (bool, optional): whether or not to store the data in
	        the Riff* objects as pointers. You may want to set this if the
	        data you're handling is particularly large.
	
	Returns:
	    A RiffList object, or a RiffSubchunk if the recursion level is 0.
	
	Usage:
	    with open("sample.wav", "rb") as wave_file:
	        wave_structure = object_from_file(wave_file, 1, True)
	        
	        # reveal the structure of the file
	        print(wave_structure)
	        for chunk in wave_structure:
	            print('\\t', chunk)
	'''
	assert(recursion_level > -1)
	# assume we are making lists when the recursion_level > 0
	# recursion_level here is how many times to recurse down
	if recursion_level > 0:
		container = RiffList(list_type=file_.read(4).decode('ascii'))
	else:
		# read this as a chunk, not a list
		container = RiffSubchunk(file_.read(4).decode('ascii'))
	
	many_bytes = int.from_bytes(file_.read(4), byteorder='little')
	stop_loc = many_bytes + file_.tell()
	
	if recursion_level > 0:
		container.name = file_.read(4).decode('ascii')
	
	while file_.tell() < stop_loc:
		if recursion_level > 0:
			new_list = object_from_file(file_, recursion_level=recursion_level-1, as_pointer=as_pointer)
			container.append(new_list)
		else:
			if as_pointer:
				# pointer to chunk data
				container.data = FileDataPointer(file_, file_.tell(), many_bytes)
				file_.seek(stop_loc)
			else:
				# read entire chunk
				container.data += file_.read(many_bytes)
	
	if file_.tell() % 2:
		# landing on an odd byte
		file_.read(1)
	
	return container
