"""
Eventually create hierarchy of pattern methods
with PatternMethods staying on top
and alternative systems occupying down the chain
"""

module HexadecimalPatternMethods
  # packs times into normalized units
# for traversal within refresh rate
# formatted for asychronous time function
# at times (list), params (list)
# takes in list of numbers representing times
# returns containers of normalized times
def pack_pattern(times,length=nil,offset=0,unit=1)
  if times.empty?
    return [[]]
  end
  if !length
    ##| length = times.last # non-quantized?
    length = times.last.floor+1 # quantize to time grid
  end
  start, finish = offset, offset+length
  result = Hash[ (start...finish).collect{|x| [x.to_i, []] } ]
  times.each do |time|
    key = time.floor
    if key >= finish
      break
    elsif key < start
      next
    else
      result[key].push(time % unit)
    end
  end

  result.map {|k,v| v }
end

# takes in string of x's and -'s starting with ints
# converts into list of numbers representing times
# string can contain digits 1-9 to change scalar
def parse_pattern(pattern,length=nil)
  scalar = 4 # by default, used most in practice
  times = []
  duration = 0
  pattern.split(//).each do |character|
    if character.to_i != 0 # check if valid integer
      # right now, limited to 1-9
      scalar = character.to_i
    elsif character == " "
      next
    end

    if character == "x"
      times.push(duration)
    end

    duration += 1.0/scalar
  end

  if length
    duration = length
  end

  return times, duration
end

# format hexadecimal pattern
# convert .4/4 8888 to 4x---x---x---x--- using decode
def format_pattern(pattern)
  result = ""
  length = 4 # by default, padding size 4
  i = 0
  while i < pattern.length do
    character = pattern[i]
    case character
    when '.'
      i+=1
      result += pattern[i] # get duration integer, divider
      # makes this kind of situation: 4xxxx1xxxx from .4F.1F"
    when '/'
      i+=1
      length = pattern[i].to_i
    when ' '
      # nothing, skip
    else
      result += decode_pattern(character, length)
    end
    i+=1
  end
  result
end

# decode hexadecimal pattern into x's and -'s
def decode_pattern(pattern, length)
  pattern.split(//).map{ |character|
    bits = character.to_i(16).to_s(2)
    bits = bits.rjust(length,'0') # padding, leading zeros or truncating
    bits = bits[bits.size-length..bits.size-1]
    bits.split(//).map {|bit| bit == '1' ? 'x' : '-' }
  }.join("")
end

def run_pattern(pattern, length=nil, offset=0, &block)
  def run_pattern(pattern, length=nil, offset=0, &block)
      if pattern.is_a?(Array)
        patterns = pattern.to_h
      elsif !pattern.is_a?(Hash)
        patterns = [pattern].to_h
      else
        patterns = pattern
      end

      patterns.each do |level, pattern|
        pattern = format_pattern(pattern)
        times, length = parse_pattern(pattern, length)
        units = pack_pattern(times, length, offset)
        index = truthy?(length) ? look % length : 0
        at units.look, units.look do |onset|
          time = onset+index # denormalized time
          position = times.find_index(time) # nth onset
          block.(level, onset, time, position) if block
        end
      end
    end
end

alias h run_pattern
end
