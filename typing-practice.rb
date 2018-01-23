require 'io/console'

CHARACTERS = "йцукенгшщзхъёфывапролджэячсмитьбю".split('')

@working_character_set = [CHARACTERS.sample]
@new_characters = CHARACTERS - @working_character_set

@times_right = Hash.new(0)

# Prefer non-mastered characters 60% of the time.
def character_to_quiz
  mastered_characters = @working_character_set.select do |char|
    @times_right[char] == 4
  end
  non_mastered_characters = @working_character_set - mastered_characters
  if rand < 0.6 || mastered_characters.count == 0
    non_mastered_characters.sample
  else mastered_characters.sample
  end
end

def display_count(char)
  count = @times_right[char]
  if count > 3 then '*'
  else count
  end
end

def mark_down(char)
  @times_right[char] -= 1 unless @times_right[char] == 0
end

def mark_up(char)
  @times_right[char] += 1 unless @times_right[char] == 4
end

def reprompt(char)
  print "\rTry again (#{char}):"
end

def prompt(char)
  print "\rType #{char}: (#{display_count(char)})   "
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
  if @times_right.values.all?{|times_right| times_right >= 3 }
    new_char = @new_characters.sample
    @working_character_set << new_char
    @new_characters.delete new_char
    @times_right[new_char] = 0
    quiz(new_char)
  else quiz(character_to_quiz)
  end
end

quiz(@working_character_set.first)
