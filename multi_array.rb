class MultiArray
  def initialize *mag
    raise "Multi Arrays need a > 0 degree!" if mag.size == 0
    @arity = mag.size
    if mag.length == 1
      @backing = Array.new mag[0] { 7 }
    else
      arg = mag.dup
      arg.delete_at(0)
      @backing = Array.new mag[0] { MultiArray.new mag }
    end
  end
  def [] *args
    args = args.flatten
    if @arity == 1
      @backing[args[0]] if args.size == 1
    else
      @backing[args[0]].[](args.last(args.size-1))
    end
  end
end


m = MultiArray.new 3,3,3
puts m[0,0,0]
