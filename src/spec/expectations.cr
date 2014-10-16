module Spec
  class EqualExpectation(T)
    def initialize(@value : T)
    end

    def match(value)
      @target = value
      value == @value
    end

    def failure_message
      "expected: #{@value.inspect}\n     got: #{@target.inspect}"
    end

    def negative_failure_message
      "expected: value != #{@value.inspect}\n     got: #{@target.inspect}"
    end
  end

  class BeExpectation(T)
    def initialize(@value : T)
    end

    def match(value)
      @target = value
      value.same? @value
    end

    def failure_message
      "expected: #{@value.inspect} (object_id: #{@value.object_id})\n     got: #{@target.inspect} (object_id: #{@target.object_id})"
    end

    def negative_failure_message
      "expected: value.same? #{@value.inspect} (object_id: #{@value.object_id})\n     got: #{@target.inspect} (object_id: #{@target.object_id})"
    end
  end

  class BeTruthyExpectation
    def match(@value)
      !!@value
    end

    def failure_message
      "expected: #{@value.inspect} to be truthy"
    end

    def negative_failure_message
      "expected: #{@value.inspect} not to be truthy"
    end
  end

  class BeFalseyExpectation
    def match(@value)
      !@value
    end

    def failure_message
      "expected: #{@value.inspect} to be falsey"
    end

    def negative_failure_message
      "expected: #{@value.inspect} not to be falsey"
    end
  end

  class CloseExpectation
    def initialize(@expected, @delta)
    end

    def match(value)
      @target = value
      (value - @expected).abs <= @delta
    end

    def failure_message
      "expected #{@target} to be within #{@delta} of #{@expected}"
    end

    def negative_failure_message
      "expected #{@target} not to be within #{@delta} of #{@expected}"
    end
  end
end

def eq(value)
  Spec::EqualExpectation.new value
end

def be(value)
  Spec::BeExpectation.new value
end

def be_true
  eq true
end

def be_false
  eq false
end

def be_truthy
  Spec::BeTruthyExpectation.new
end

def be_falsey
  Spec::BeFalseyExpectation.new
end

def be_nil
  eq nil
end

def be_close(expected, delta)
  Spec::CloseExpectation.new(expected, delta)
end

macro expect_raises
  raised = false
  begin
    {{yield}}
  rescue
    raised = true
  end

  fail "expected to raise" unless raised
end

macro expect_raises(klass)
  begin
    {{yield}}
    fail "expected to raise {{klass.id}}"
  rescue {{klass.id}}
  end
end

macro expect_raises(klass, message)
  begin
    {{yield}}
    fail "expected to raise {{klass.id}}"
  rescue _ex_ : {{klass.id}}
    _msg_ = {{message}}
    _ex_to_s_ = _ex_.to_s
    case _msg_
    when Regex
      unless (_ex_to_s_ =~ _msg_)
        fail "expected {{klass.id}}'s message to match #{_msg_}, but was #{_ex_to_s_.inspect}"
      end
    when String
      unless _ex_to_s_.includes?(_msg_)
        fail "expected {{klass.id}}'s message to include #{_msg_.inspect}, but was #{_ex_to_s_.inspect}"
      end
    end
  end
end

class Object
  def should(expectation)
    unless expectation.match self
      fail(expectation.failure_message)
    end
  end

  def should_not(expectation)
    if expectation.match self
      fail(expectation.negative_failure_message)
    end
  end
end