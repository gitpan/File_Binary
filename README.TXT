File::Binary 
by Simon Wistow (simon@twoshortplanks.com)


A very Beta Perl module for Binary manipulation of files. 

perl Makefile.PL
make
make test
make install


19-11-99
Completley rewritten ... it's not as efficent now (it loads the whole file into a list) but at least it doesn't keep falling over.


NAME
       File::Binary - Binary file reading module

SYNOPSIS
           use File::Binary;

           # open an SWF file as a new File::Binary object ...
           $bin = new File::Binary('test.swf') or die "Couldn't open test.swf\n";
           # ... and check tos ee that it's a valid SWF file
           $bin->getBytes(3) eq 'FWS' or die $bin->getFilename()." is not a valid SWF file\n";

           # get bytes and words
           $format = unpack("C",$bin->getBytes(1));
           $width  = $bin->getWord;

           # get bits and signed bits
           $hasloops = $bin->getBits(1);
           $hasend   = $bin->getSBits(2):

           # find out where you are
           print "File Position : " . $bin->where() . "\n";

           # seek to arbitary places in the file
           $bin->seekTo($bin->where + 100) or die "Couldn't seek to that position\n";

           # make sure that all the bit buffers are flushed and reset
           $bin->initBits;





DESCRIPTION
       File::Binary is a Binary file reading module. It is
       currently being used to write a suite of modules for
       manipulating Macromedia SWF files available from the
       section on /www.twoshortplanks.com/simon/flash/ in the
       http: manpage </gratuitous plug>, and as such is heavily
       biased towards this.

       It currently it slurps all of the file into an array which
       makes it unsuitable for anythign but small files. This
       will hopefully be changed in later versions.

BUGS
       getSBits does not handle negative numbers well.

AUTHOR
       Simon Wistow, <simon@twoshortplanks.com>
