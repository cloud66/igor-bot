class Models::ApiClient
  def get_stacks_from_api
    return [FIRST_STACK,
            SECOND_STACK,
            LAST_STACK,GOOD_STACK,
            BUSY_STACK,BUSY_TO_GOOD_FOREVER_BUSY_STACK,
            BUSY_TO_GOOD_FOREVER_GOOD_STACK,
            BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_BUSY,
            BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_GOOD]
  end

  def deploy_from_api(id, services)
    return @@stack_started_redeploy_queued_state
  end

  def get_stack_from_api(stack_id)
    case stack_id
      when "good_stack"
        return GOOD_STACK
      when "busy_stack"
        return BUSY_STACK
      when "good_to_good_forever_stack"
        return BUSY_TO_GOOD_FOREVER_STACK.get
      when "busy_to_good_forever_stack_wait_loop"
        return BUSY_TO_GOOD_FOREVER_STACK.get
      when "busy_to_good_forever_stack_set_local_status_to_cancelling_busy"
        stack = Stack.new(BUSY_TO_GOOD_FOREVER_BUSY_STACK_SET_LOCAL_STATUS_TO_CANCELLING_BUSY)
        stack.set_local_status(Lita::Handlers::Deployer::REDIS_PREFIX, Lita::Handlers::Deployer::WAIT_TIMEOUT, :cancelling)
        return BUSY_TO_GOOD_FOREVER_STACK_SET_LOCAL_STATUS.get
    end
  end

  def get_stack_services_from_api(stack_id)
    return SERVICES_FROM_STACK
  end
end