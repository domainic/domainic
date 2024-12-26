# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/datetime/date_time_type'

RSpec.describe Domainic::Type::DateTimeType do
  it_behaves_like 'a datetime type', described_class, DateTime.now, Time.now
end
