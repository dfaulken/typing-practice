require 'io/console'

CHARACTER_FILE = 'characters.txt'
PROGRESS_FILE = 'progress.txt'

CHARACTERS = File.read(CHARACTER_FILE).lines.map(&:strip)

# Prefer non-mastered characters 60% of the time.
def character_to_quiz
  mastered_characters = @progress.keys.select do |char|
    @progress[char] == 4
  end
  non_mastered_characters = @progress.keys - mastered_characters
  if rand < 0.6 || mastered_characters.count == 0
    non_mastered_characters.sample
  else mastered_characters.sample
  end
end

def display_count(char)
  count = @progress[char]
  if count == 4 then '*'
  else count
  end
end

def mark_down(char)
  @progress[char] -= 1 unless @progress[char] == 0
  save_progress
end

def mark_up(char)
  @progress[char] += 1 unless @progress[char] == 4
  save_progress
end

def reprompt(char)
  print "\rTry again (#{char}):"
end

def parse_progress(data)
  progress = {}
  data.lines.each do |line|
    char, count = line.split(': ').map(&:strip)
    progress[char] = count.to_i
  end
  progress
end

def prompt(char)
  print "\rType #{char}: (#{display_count(char)})   "
end

def save_progress
  encoded_progress = @progress.each_pair.map do |char, count|
    "#{char}: #{count}"
  end
  File.open PROGRESS_FILE, 'w' do |file|
    file.puts encoded_progress
  end
end

def typed_char
  char = STDIN.getch
  exit unless CHARACTERS.include? char
  char
end

def quiz(char)
  prompt(char)
  while typed_char != char
    mark_down(char)
    reprompt(char)
  end
  mark_up(char)
  # Have to get everything right three times in a row before adding another character.
  if @progress.values.all?{|value| value >= 3 }
    new_char = (CHARACTERS - @progress.keys).sample
    @progress[new_char] = 0
    quiz(new_char)
  else quiz(character_to_quiz)
  end
end

if File.file? PROGRESS_FILE
  progress_data = File.read PROGRESS_FILE
  @progress = parse_progress(progress_data)
  quiz(character_to_quiz)
else
  first_char = CHARACTERS.sample
  @progress = { first_char => 0 }
  quiz(first_char)
end
