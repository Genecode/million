require 'rails_helper'

RSpec.describe Question, type: :model do
  #subject { Question.new(text: 'some', level: 0, answer1: '1', answer2: '1', answer3: '1', answer4: '1') }

  subject { FactoryBot.create(:question) }
  context 'validation check' do
    it { should validate_presence_of :text }
    it { should validate_presence_of :level }

    it { should validate_inclusion_of(:level).in_range(0..14) }

    it { should validate_uniqueness_of :text }
  end
end
