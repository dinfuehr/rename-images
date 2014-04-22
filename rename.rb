require 'mini_exiftool'

if ARGV.length != 2
  puts "usage: rename.rb <dir> <name>"
  exit 1
end

dir = ARGV[ 0 ]

unless File.directory?( dir )
  puts "#{dir} is not a directory"
  exit 1
end

name = ARGV[ 1 ]

files = []
i = 1

for f in Dir[ "#{dir}/*" ]
  next unless File.file?( f )
  next unless File.extname( f ).downcase == '.jpg'

  exif = MiniExiftool.new( f )

  date = exif.datetimedigitized || exif.datetimeoriginal

  if date.class != Time
    puts "exif data not found for #{f}"
    exit 1
  end

  files.push( {
    :file => f,
    :time => date
  } )

  if i % 10 == 0
    puts "exif read of #{i} files."
  end

  i += 1
end

puts "finished reading exif data of #{files.length} files."
files.sort! { |f1,f2| f1[ :time ] <=> f2[ :time ] }

i = 1
maxlen = files.length.to_s.length

for f in files
  ifmt = "%0#{maxlen}d" % i
  timefmt = f[ :time ].strftime( "%d%m%Y_%H%M" )
  File.rename( f[ :file ], "#{dir}/#{ifmt}_#{name}_#{timefmt}.jpg" )

  i += 1
end

puts "#{files.length} files renamed."
