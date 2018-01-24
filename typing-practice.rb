require 'io/console'

CHARACTER_FILE = 'characters.txt'
PROGRESS_FILE = 'progress.txt'

TIMES_TO_MASTER = 3

CHARACTERS = File.read(CHARACTER_FILE).lines.map(&:strip)

def character_to_quiz
  # If we're just starting, or we've mastered all the characters, then any character will do.
  if @progress.keys.count == 0 || @progress.keys.sort == CHARACTERS.sort
    return CHARACTERS.sample
  end
  mastered_characters = @progress.keys.select do |char|
    @progress[char] == TIMES_TO_MASTER.succ
  end
  non_mastered_characters = @progress.keys - mastered_characters
  # Prefer non-mastered characters 60% of the time.
  if rand < 0.6
    non_mastered_characters.sample
  else mastered_characters.sample
  end
end

def display_count(char)
  count = @progress[char]
  if count == TIMES_TO_MASTER.succ then '*'
  else count
  end
end

def mark_down(char)
  # If you get a mastered character wrong, start over.
  count = @progress[char]
  @progress[char] = case count
                    when 0, TIMES_TO_MASTER.succ then 0
                    else count - 1
                    end
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
  # Have to get everything right TIMES_TO_MASTER times in a row before adding another character.
  if @progress.values.all?{|value| value >= TIMES_TO_MASTER }
    new_char = (CHARACTERS - @progress.keys).sample
    if new_char.nil?
      quiz(character_to_quiz)
    else
      @progress[new_char] = 0
      quiz(new_char)
    end
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
