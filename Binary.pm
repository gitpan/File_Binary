## File::Binary ##

package   File::Binary;
use strict;
use Exporter;
use IO::File;
use vars qw(@ISA @EXPORT_OK $DEBUG $VERSION);

@ISA       = qw(Exporter);
@EXPORT_OK = qw(new getBytes getBits getSBits seekTo  getFilename getWord initBits);

$DEBUG     = 1;
$VERSION   = '0.2';

########################################################################


=head1 NAME

File::Binary - Binary file reading module

=head1 SYNOPSIS

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
    
    
    


=head1 DESCRIPTION

I<File::Binary> is a Binary file reading module. It is currently being used to 
write a suite of modules for manipulating Macromedia SWF files available from 
L<http://www.twoshortplanks.com/simon/flash/> </gratuitous plug>, and as such is
heavily biased towards this.

It currently it slurps B<all> of the file into an array which makes it unsuitable
for anythign but small files. This will hopefully be changed in later versions.

=head1 BUGS

getSBits does not handle negative numbers well.

=head1 AUTHOR

Simon Wistow, <simon@twoshortplanks.com>


=cut


sub new {
  my ($class, $filename) = @_;
  my $self = {};

  my $fh = new IO::File($filename) || return; # returns undef on error
  
  $self->{filename} = $filename;
  $self->{_bitPos}  = 0;
  $self->{_bitBuf}  = 0;
  $self->{_filepos} = 0;
  $self->{debug}    = $DEBUG;
  $self->{buf}      = [];
    
  my $data;
  while (read ($fh, $data, 1)) {
        push (@{$self->{buf}}, $data);
  }

  bless $self, $class;            
  return $self;

}


sub InitBits() {
  my $self = shift;  
  
  $self->{_bitPos} = 0;
  $self->{_bitBuf} = 0;

}



sub getBytes {
  my ($self, $bytes) = @_;
  my $data;
  $self->{_bitPos} = 0;
  $self->{_bitBuf} = 0;

  my $fp = $self->{_filepos};
  $self->{_filepos} += $bytes;
  
  for ($a=0; $a<$bytes ; $a++)
  {
    $data .= ($self->{buf}[$a+$fp] || '');
  }  
  
  return  $data;
}
  
sub where
{
    my $self = shift;

    return $self->{_filepos};

}    


sub getFilename
{
    my $self = shift;

    return $self->{filename};
 
}

sub getBits {
  my ($self, $bits) = @_;
  my $data = 0; # the return value
  
  for (;;) {
      
      # we want to know if we should use the whole byte.
      my $s =  $bits - $self->{_bitPos};
      
      if ( $s > 0 ) {
	
	      # all these bits are ours
	      $data |= $self->{_bitBuf} << $s;
	      $bits -= $self->{_bitPos};
	
	      # get the next buffer
	      $self->{_bitBuf} = unpack("C",$self->getBytes(1));
	      $self->{_bitPos} = 8;
	
      } else {
	
	      # this is our last byte, take only the bits we need
	      $data |= $self->{_bitBuf} >> ( -$s );
	      $self->{_bitPos} -=     $bits;
	
	      # mask off the consumed bits
	      $self->{_bitBuf} &= 0xff >> (8 - $self->{_bitPos});
	      return $data;
      }
  }
}

# same as _GetBits, but signed
# there are problems with this returning negative numbers
# my hack at extending the sign didn't work because Perl
# does that all internally.
sub getSBits { 
  my ($self, $bits) = @_;
  
  return $self->getBits($bits);
  
  # Is the number negative?
  #if ($data & (1 << ($bits - 1))) {
  #  # Yes. Extend the sign.
  #  $data |= -1 << $bits;
  #}
  #return $data;
}




sub seekTo {
  my ($self,$position) = @_;
  
  return 0 unless ($position>=0);
  
  return 0 unless ($position<$#{$self->{buf}});
  $self->{_bitPos} = 0;
  $self->{_bitBuf} = 0;
  $self->{_filepos} = $position;
  return 1;
}


sub getWord {
  my $self = shift;
  
  return unpack("C",$self->getBytes(1)) | unpack("C",$self->getBytes(1)) << 8;  
  
  
}


1;
