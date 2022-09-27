
module Utils

  class Once
    def initialize(&block)
      @foo = false
      @block = block
    end
    def foo
      if !@foo
        @foo = true
        @block.() if @block
      else
        # nothing
      end
    end

    # o = Once.new { sample :bd_haus }
    # o.foo
  end

  def calculate_sample_bpm(*args)
    sample_name, args_h = split_params_and_merge_opts_array(args)
    num_beats = args_h[:num_beats] || 1
    min = args_h[:min] || 0
    max = args_h[:max] || 300

    raise ArgumentError, "#{__method__} num_beats should be a number. Got #{num_beats.inspect}" unless num_beats.is_a?(Numeric)
    raise ArgumentError, "#{__method__} min should be a number. Got #{min.inspect}" unless min.is_a?(Numeric)
    raise ArgumentError, "#{__method__} max should be a number. Got #{max.inspect}" unless max.is_a?(Numeric)

    scaling = __thread_locals.get(:sonic_pi_spider_arg_bpm_scaling)
    __thread_locals.set(:sonic_pi_spider_arg_bpm_scaling, false)
    sd = sample_duration(sample_name, args_h)
    __thread_locals.set(:sonic_pi_spider_arg_bpm_scaling, scaling)

    res = num_beats * (60.0 / sd)
    while res < min
      num_beats *= 2
      res = num_beats * (60.0 / sd)
    end
    while res > max && res > 0
      num_beats /= 2
      res = num_beats * (60.0 / sd)
    end

    [res, num_beats]
  end

  def get_onsets (*args)
    params, opts = split_params_and_merge_opts_array(args)
    res = []
    l = lambda {|c| res = c ; c[0]}
    s = params
    sample s, opts, onset: l, amp: 0

    times = []
    time = 0
    res.each do |n|
      n = n[:index]
      dur = sample_duration s, onset: n
      times.push(time)
      time += dur
    end

    return res, times
  end

  def generate_lsystem(*args)
    params, opts = split_params_and_merge_opts_array(args)
    variables = params[0] || opts.fetch(:variables, [])
    constants = params[1] || opts.fetch(:constants, [])
    axiom = params[2] || opts.fetch(:axiom, "")
    rules = params[3] || opts.fetch(:rules, [])
    rules = rules.each_slice(2).map do |k, v|
      {k.to_s => v}
    end
    keys = rules.map{ |x| x.keys }.flatten
    lambda do |num_its|
      variables = variables
      constants = constants
      axiom = axiom.to_s
      rules = rules
      keys = keys
      current = axiom
      res = current

      num_its.times do
        res = ""
        current.split(//) do |c|
          if constants.include? c
            res = res + c
          elsif keys.include? c
            rule = rules.select { |x| x.has_key?(c) }[0]
            str = ""
            case rule[c]
            when Integer
              str = rule[c].to_s
            when Proc
              str = rule[c].()
            else
              str = rule[c].to_s
            end
            res = res + str
          end
        end
        current = res
      end
      res
    end
  end

  def choose_with_weights(list, weights)

    raise ArgumentError, "#{__method__} weights should be non-empty. Got: #{weights.inspect}" unless weights.size > 0

    invalid_args = weights.filter {|x| !x.is_a?(Numeric) }
    raise ArgumentError, "#{__method__} weights should be numbers. Got: #{invalid_args.inspect}" unless invalid_args.size == 0

    n = weights.size
    avg = weights.sum/n.to_f
    aliases = [[1,nil]]*n
    smalls = []
    bigs = []
    weights.each.with_index do |w,i|
      if w < avg
        smalls.append([i,w/avg])
      end
    end
    weights.each.with_index do |w,i|
      if w >= avg
        bigs.append([i,w/avg])
      end
    end

    big = bigs
    small = smalls
    while big != [] and small != []

      s = small[0]
      b = big[0]
      aliases[s[0]] = [s[1], b[0]]
      b = [b[0], b[1] - (1-s[1])]
      if b[1] < 1
        s = b
        big = big.drop(1)

      else
        small = small.drop(1)
      end

    end

    r = rand*n
    i = r.to_i
    odds, a = aliases[i]
    idx = ((r-i) > odds) ? a : i
    return list[i]

  end



end
