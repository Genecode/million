require 'rails_helper'

RSpec.feature 'USER creates game', type: :feature do
  let(:user) { FactoryBot.create :user }
  let!(:questions) do
    (0..14).to_a.map do |i|
      FactoryBot.create(
        :question, level: i,
        text: "Тестовый вопрос #{i}?",
        answer1: '1000', answer2: '1001', answer3: '1002', answer4: '1003'
      )
    end
  end

  before(:each) do
    login_as user
  end

  scenario 'success' do
    visit '/'
    click_link 'Новая игра'

    expect(page).to have_content('Тестовый вопрос 0')
    expect(page).to have_content('1000')
    expect(page).to have_content('1001')
    expect(page).to have_content('1002')
    expect(page).to have_content('1003')

    save_and_open_page
  end
end