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

  describe '#take money!' do
    it 'finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)
      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0

      # проверяем что закончилась игра и пришли деньги игроку
      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end

  describe '#answer_current_question!' do
    it 'return true for right answer' do
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.answer_current_question!(q.correct_answer_key)).to be_truthy

      expect(game_w_questions.status).to eq(:in_progress)
      expect { game_w_questions.answer_current_question!(q.correct_answer_key) }.to change { game_w_questions.current_level }.by(1)
      expect(game_w_questions.current_game_question).not_to eq q
      expect(game_w_questions.finished?).to be_falsey
    end
    it 'return false if  wrong answer' do
        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.answer_current_question!('a')).to be_falsey
        expect(game_w_questions.finished?).to be_truthy
        expect(game_w_questions.status).to eq(:fail)
    end

    context 'when last rigth answer' do
      #можно ли вместо 14 указать - Question::QUESTION_LEVELS.max?
      let(:game_w_questions) do  FactoryBot.create(:game_with_questions, current_level: 14,
                                                   user: user)
      end

      it 'won game' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.status).to eq(:won)
      end
      it 'get max prize' do
        game_w_questions.answer_current_question!('d')
        expect(game_w_questions.prize).to eq 1_000_000
        expect(game_w_questions.finished?).to be_truthy
      end
      it 'append prize to user balance' do
        expect { game_w_questions.answer_current_question!('d') }.to change { user.balance }.by(1_000_000)
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

  context '.status' do
    # перед каждым тестом "завершаем игру"
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  #Напишите тесты на методы current_game_question и previous_level модели Game.

  describe '#current_game_question' do
    it 'return game question corresponding game current level' do
      game = FactoryBot.create(:game_with_questions, current_level: 8)
      result = game.current_game_question
      expect(result).to eq(game.game_questions[8])
    end
  end

  describe '#previous_level' do
    it "return current level-1" do
      game = FactoryBot.create(:game_with_questions, current_level: 8)
      result = game.previous_level
      expect(result).to eq 7
    end
  end
end
