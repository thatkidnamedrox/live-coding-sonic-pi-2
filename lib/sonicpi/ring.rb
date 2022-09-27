module RingMethods
  def % (m)
    a = self.to_a
    a.map.with_index {|x,i| x % m }.ring
  end

  def normalize(max=1.0)
    a = self.to_a
    max = max
    min = 0.0
    old_min = (Float a.min())
    old_max = (Float a.max())
    a.map{|x| (x-old_min)/(old_max-old_min)*(max-min)+min}.ring
  end
  alias n normalize

  def normalize_sum(max=1.0)
    a = self.to_a
    a.map{|x| x/a.sum.to_f }
  end
  alias ns normalize_sum
end
