module RandomMethods
  def wchoose(*weights)
    ps = weights.map {|w| (Float w) / weights.reduce(:+) }
    items = (Array self)
    items = items[0..ps.size-1].zip(ps).to_h
    items.max_by {|_, weight| rand ** (1.0 / weight) }.first
  end
end
