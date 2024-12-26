# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/datetime/time_type'

RSpec.describe Domainic::Type::TimeType do
  it_behaves_like 'a datetime type', described_class, Time.now, Date.today
end
