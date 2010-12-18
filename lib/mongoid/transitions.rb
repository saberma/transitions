# Copyright (c) 2010 Krzysiek Herod

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Mongoid
  module Transitions
    extend ActiveSupport::Concern

    included do
      include ::Transitions
      before_validation :set_initial_state
      validates_presence_of :state
      validate :state_inclusion
    end

    protected

    def write_state(state_machine, state)
      self.send("#{state_machine.name}=", state.to_s)
      save!
    end

    def read_state(state_machine)
      self.send(state_machine.name).to_sym
    end

    def set_initial_state
      self.class.state_machines.each_pair do |name, machine|
        self.send("#{name}=", machine.initial_state.to_s) unless self.send(name)
      end
    end

    def state_inclusion
      self.class.state_machines.each_pair do |name, machine|
        unless machine.states.map{|s| s.name.to_s }.include?(self.send(name).to_s)
          self.errors.add(name, :inclusion, :value => self.send(name))
        end
      end
    end
  end
end

