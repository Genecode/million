require 'rails_helper'

RSpec.describe GameQuestion, type: :model do

  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }
  context 'game status' do
    it 'correct .variants' do

      expect(game_question.variants).to eq({'a' => game_question.question.answer2,
                                            'b' => game_question.question.answer1,
                                            'c' => game_question.question.answer4,
                                            'd' => game_question.question.answer3
                                           })

    end

    it 'correct .answer_correct?' do
      expect(game_question.answer_correct?('b')).to be_truthy
    end

    # тест на наличие методов делегатов level и text
    it 'correct .level & .text delegates' do
      expect(game_question.text).to eq(game_question.question.text)
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  #Напишите тесты на метод correct_answer_key модели GameQuestion.
  describe '#correct_answer_key' do
    # {a => 'a', b => 'b', c => 'c', d => 'd'}[1]
    # factory a: 2, b: 1, c: 4, d: 3
    it 'return key' do
      expect(game_question.correct_answer_key).to eq('b')
    end
  end

  # Напишите тест на метод help_hash
  describe '.help_hash' do
    it 'correct .help_hash' do
      expect(game_question.help_hash).to eq({})

      # добавляем пару ключей
      game_question.help_hash[:some_key1] = 'blabla1'
      game_question.help_hash['some_key2'] = 'blabla2'

      expect(game_question.save).to be_truthy

      gq = GameQuestion.find(game_question.id)
      expect(gq.help_hash).to eq({some_key1: 'blabla1', 'some_key2' => 'blabla2'})
    end
  end
end
