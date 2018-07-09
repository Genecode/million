require 'rails_helper'

RSpec.describe Question, type: :model do

  context 'validation check' do
    it { should validate_presence_of :text }
    it { should validate_presence_of :level }

    it { should validate_inclusion_of(:level).in_range(0..14) }
  end
end
