begin
  count = 0
  f = File.open("unique_tracks.txt")
  until f.eof?
    f.each_line do |line|
      count += 1
    end
  end
  f.close

  puts "Read #{count} lines"
rescue
  puts 'could not read file'
end
