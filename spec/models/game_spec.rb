require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) } #, user: user)
  context 'Game Factory' do

    it 'Game.create_game_for_user! new correct game' do
      generate_questions(60)
      game = nil

      # Создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
        # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
        # GameQuestion.count +15
        change(GameQuestion, :count).by(15).and(
          # Game.count не должен измениться
          change(Question, :count).by(0)
        )
      )

      # Проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      # Проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanic' do

    it 'answer correct continues' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.current_game_question).not_to eq q

      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end

  context 'take money' do
    #TODO
  end
#Напишите группу тестов на метод answer_current_question! модели Game.
#Рассмотрите случаи, когда ответ правильный, неправильный, последний (на миллион) и
#Когда ответ дан после истечения времени.
  describe '#answer_current_question!' do

    it 'return true for right answer' do
      #Arrange Act Assert
      #game_w_questions = FactoryBot.create(:game_with_questions)
      #проверку состояния не делаем, т.к. проверили это в механике
      expect(game_w_questions.answer_current_question!('d')).to be_truthy
    end
    it 'return false for all wrong answers' do
      %w[a, b, c].each do |element|
        game = FactoryBot.create(:game_with_questions)
        expect(game.status).to eq(:in_progress)
        expect(game.answer_current_question!(element)).to be_falsey
        expect(game.status).to eq(:fail)
      end
    end

    context 'when last rigth answer' do
      #можно ли вместо 14 указать - Question::QUESTION_LEVELS.max?
      let(:game_w_questions) { FactoryBot.create(:game_with_questions, current_level: 14) }

      it 'won game' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.status).to eq(:won)
      end
      it 'get max prize' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.prize).to eq 1_000_000
      end
    end

    context 'when time left' do
      let(:game_w_questions) { FactoryBot.create(:game_with_questions,
                                                 created_at: Time.now-5.day, current_level: 6) }
      it 'retun status :timeout' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.status).to eq(:timeout)
      end
      it 'failed game' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.is_failed).to be_truthy
      end

      it 'return nearest fireproof prize' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.prize).to eq 1_000
      end
    end

  end


end
