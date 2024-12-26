# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/datetime/date_type'

RSpec.describe Domainic::Type::DateType do
  it_behaves_like 'a datetime type', described_class, Date.today, Time.now
end
