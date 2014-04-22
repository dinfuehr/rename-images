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
end

files.sort! { |f1,f2| f1[ :time ] <=> f2[ :time ] }

# puts "files = #{files.inspect}"

i = 1

for f in files
  File.rename( f[ :file ], "#{dir}/#{name}_#{i}.jpg" )

  i += 1
end

puts "#{files.length} files renamed."
