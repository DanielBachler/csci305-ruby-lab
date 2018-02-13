
#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Dan Bachler
# daniel.bachler@comcast.net
#
###############################################################

$bigrams = Hash.new # The Bigram data structure
$name = "Dan Bachler"

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "
	countSongs = 0
	begin
		linesCleaned = 0
		f = File.open(file_name)
		until f.eof?
			f.each_line do |line|
				# do something for each line
				#Counts number of lines cleaned for debugging
				linesCleaned += 1
				#Cleans the input string to get just the title
				title = cleanup_title (line)
				#Only runs most of the code if nil is not returned
				if title != nil
					#Sets the title to all lowercase and increments the amount of proper songs
					title.downcase!()
					countSongs += 1
					#Splits the string into all possible bigrams and saves to titleBigram, found on stackover flow
					titleBigram = title.split(' ').each_cons(2).to_a

					#Logic for handling each bigram into the master bigram list
					#Loops over each bigram from the titleBigram array
					titleBigram.each do |i|
						#If bigrams has the given key, goes into adding secondary key
						if $bigrams.has_key? i[0]
							#If the secondary key exists already increments by 1
							if $bigrams[i[0]].has_key? i[1]
								$bigrams[i[0]][i[1]] += 1
							#Otherwise creates the secondary key and sets value to 1
							else
								$bigrams[i[0]][i[1]] = 1
							end
						#Otherwise creates a new hash and then creates secondary key with a value of 1
						else
							$bigrams[i[0]] = Hash.new(0)
							$bigrams[i[0]][i[1]] = 1
						end
					end
				end
			end
		end
		f.close
		#Puts the total number of valid songs, and the total number of lines processed
		puts "Total valid songs: #{countSongs}"
		puts "Total songs cleaned #{linesCleaned}"
		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

#Cleans the input strings to return only the title
def cleanup_title (input)
	input.chomp!()
	#Gets title
	find_title = /<SEP>.*<SEP>(.*)\z/
	#Removes Extra text
	extra_text = /([\(\{\[\\\/\_\-\:\"\`\+\=\*]|feat\.).*/
	#Removes punctuation
	remove_punctuation = /[\?\¿\!\¡\.\;\&\@\%\#\|]/
	#Clears strings with non-english characters
	non_english = /\W/
	#Removes common stop words
	stop_words = /\ba\b|\ban\b|\band\b|\bby\b|\bfor\b|\bfrom\b|\bin\b|\bof\b|\bon\b|\bor\b|\bout\b|\bthe\b|\bto\b|\bwith\b/

	#Matches the title
	input =~ find_title
	#Checks to make sure nil is not returned
	if $1 != nil
		#Sets title to match, and sets encoding to UTF-8
		title = $1.force_encoding("UTF-8")
		#Downcases title
		title.downcase!
		#Gets rid of extra text
		title.gsub!(extra_text, "")
		#Removes punctuation
		title.gsub!(remove_punctuation, "")
		#Removes excess words
		title.gsub!(stop_words, " ")
		#Cleans up excess white space from removing excess words
		title.gsub!(/\s+/, " ")
	else
		#returns nil
		return nil
	end

	#Non english character checks
	#Removes spaces and apostrophes to makes sure \W doesn't false flag them
	temp = title.gsub(" ", "")
	temp.gsub!("'", "")
	#Sees if any non english characters are present, if they are returns nil
	#otherwise returns the title
	if temp =~ non_english
		return nil
	else
		return title
	end
end

#Finds the word that most often follows the given word argument
def mcw(word)
	#Checks if the bigram has the primary key, if not returns nil
	if $bigrams.has_key? word
		#Creates a temporary max value that should not exist in data set
		highestCount = 'zzz'
		#Goes through each secondary key and compares count to previous max, default is 0
		$bigrams[word].each do |i|
			#If the secondary key has a higher count than the current highest replaces current highest
			if $bigrams[word][highestCount] < i[1]
				highestCount = i[0]
			#Checks to see if the current value and the current highest have the same count
			elsif $bigrams[word][highestCount] == i[1]
				#Creates a random number either 0 or 1 and then randomly chooses an option
				pick = rand(2)
				if pick == 1
					highestCount = i[0]
				end
			end
		end
		#If the temp max value is the highest value returns nil
		if highestCount == 'zzz'
			return nil
		end
		#If nil is not returned then returns the true highest count word
		return highestCount
	else
		return nil
	end
end

#Creates the most probable song title
def create_title start
	#Creates the title and sets it equal to the start word
	start.downcase!
	title = start
	#Gets the next word from the mcw funtion, if its nil ends here and just returns start word
	newWord = mcw(start)
	if newWord != nil
		#Loops upto 190 times, continues to add most common words until it either reaches max length
		#or hits a nil value, after either condition returns the new title
		1.upto(190) do
			#Adds the new word onto the title
			title += " " + newWord
			#Gets a new newWord using mcw function
			newWord = mcw(newWord)
			#If nil is returned from mcw breaks the loop
			if newWord == nil
				break;
			#If the current word already exists in the title returns the title as is
			elsif title.scan(/\b#{newWord}\b/).length == 1
				return title
			end
		end
	end
	#returns title after loop is done
	return title
end

#Prints the bigram, used for debugging.  Do not call when using full Dataset
def printBigram
	$bigrams.each do |i|
		puts "#{i}"
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	puts "Enter a word [Enter 'q' to quit]:"
	#Gets user input from console
	while user_input = STDIN.gets.chomp
		#checks to see if user wants to quit
		if user_input == 'q'
			break;
		end
		#Prints the users chosen title and reprompts
		puts "Your title: #{create_title(user_input)}"
		puts "Enter a word [Enter 'q' to quit]:"
	end
end

if __FILE__==$0
	main_loop()
end
