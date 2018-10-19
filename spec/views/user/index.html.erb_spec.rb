require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do
    assign(:users, [
        FactoryBot.build_stubbed(:user, name:'Женя', balance: 5000),
        FactoryBot.build_stubbed(:user, name:'Ваня', balance: 2000),
    ])
    render
  end
  it 'reneders player names' do
    expect(rendered).to match 'Женя'
    expect(rendered).to match 'Ваня'
  end
  it 'reneders player balances' do
    expect(rendered).to match '5 000 ₽'
    expect(rendered).to match '2 000 ₽'
  end
  it 'renders player name in right orders' do
    expect(rendered).to match /Женя.*Ваня/m
  end
end