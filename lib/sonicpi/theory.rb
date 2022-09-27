module TheoryMethods
  def aganist(a,b)
    res = []
    res = ["-"]*a*b
    ai = range(0,a*b,step: b).to_a
    bi = range(0,a*b,step: a).to_a
    i = ai+bi

    op = res.map.with_index do |x,j|
      if ai.include?(j) && bi.include?(j)
        :c
      elsif ai.include?(j)
        :a
      elsif bi.include?(j)
        :b
      else
        :r
      end
    end
    a = op
    res = a

    res = res.map.with_index{|x,i| [x,(Float i)/res.size]}
    b = Hash.new{|hash, key| []}

    res.each do |c|
      if c[0] != :r
        b[c[0]] = b[c[0]] + [c[1]]
      end
    end
    return b.values.flatten, a.filter{|x| x != :r }
  end
  
  def order(list=[], degrees=[])
    degrees = ((degrees.ring - 1 % list.size).to_a)
    prev = nil
    list = degrees.map {|d|
      if !prev
        prev = list[d]
        list[d]
      elsif list[d] <= prev
        n = list[d]
        while n <= prev
          n = n + 12
        end
        prev = n
        n
      else
        prev = list[d]
        list[d]
      end
    }
  end

  def voice(notes=scale(:c,:major), degrees=[1,5,3],type=3,mode=0)
    notes = notes.to_a
    degrees = ((degrees.ring - 1 + mode % notes.size).to_a)

    notes = notes.select.with_index {|n,i| degrees.include?(i) }

    case type
    when 1
      notes[1] += 12
    when 2
      notes[1] += 12
      notes = notes.push(notes[0] + 12)
    when 3
      notes[1] -= 12
      notes = notes.push(notes[0] + 12)
    end
    notes
  end
end
