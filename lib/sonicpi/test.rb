module TestMethods
  def test?
    true
  end
  def at?
    at [0, 0.5, 0.75] do
      sample :bd_haus, amp: 1
    end
  end
  def name?
    print self
  end
  def user?
    puts "Home directory of current user: ",Dir::home();
  end
end

class TestClass
  def test?
    true
  end
  def loop?
    5.times do |i|
      print i
    end
  end

  alias t test?
  alias l loop?
end
