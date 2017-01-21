filename = ARGV[0]
basename = File.basename filename

`sox #{filename} -b 16 /tmp/#{basename}.audio.raw`

audio = File.read("/tmp/#{basename}.audio.raw")

height = 257

image = ([[]] * height).map(&:dup)

audio.bytes.each_slice(2) do |pair|
  lo, hi = pair
  val = hi * 0x0100 + lo
  image.length.times do |i|
    n = val / height
    n += 1 if i < val % height
    image[i] << n
  end
end

width = image.first.size
puts "#{width}x#{height}"

File.open("/tmp/#{basename}.image.raw","w"){|f| f.print image.flatten.map(&:chr).join }

`convert -depth 8 -size #{width}x#{height} r:/tmp/#{basename}.image.raw #{basename}.png`
