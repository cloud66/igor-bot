# For returning stack hashes in the defined order of stack_array to dynamically change its state
class DynamicStack
  def initialize(stack_array, last_stack_forever)
    @index = 0
    @last_stack_forever = last_stack_forever
    @stack_array = stack_array
  end

  def get
    if (@index >= (@stack_array.size - 1)) && @last_stack_forever
      return @stack_array[@stack_array.size - 1]
    end
    stack = @stack_array[@index % @stack_array.size]
    @index += 1
    return stack
  end

  def reset
    @index = 0
  end
end