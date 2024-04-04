# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  context 'with db columns' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:user_type).of_type(:integer).with_options(null: false) }
  end

  context 'with db index' do
    it { is_expected.to have_db_index(:email).unique(true) }
  end

  context 'with associations' do
    it { is_expected.to have_many(:projects).with_foreign_key(:manager_id).dependent(:destroy).inverse_of(:manager) }
    it { is_expected.to have_many(:assignments).dependent(:delete_all) }
    it { is_expected.to have_many(:projects_assigned).through(:assignments).source(:project) }
    it { is_expected.to have_many(:bugs_created).class_name('Bug').with_foreign_key(:creator_id).dependent(:destroy) }
    it { is_expected.to have_many(:bugs_assigned).class_name('Bug').with_foreign_key(:developer_id).dependent(:nullify) }
  end

  context 'with validation tests' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to define_enum_for(:user_type).with_values(manager: 0, developer: 1, qa: 2) }

    it 'with valid name' do
      user.name = 'User1'
      expect(user).to be_valid
    end

    it 'with invalid name' do
      user.name = nil
      expect(user).not_to be_valid
    end

    it 'with valid email' do
      user.email = 'user1@example.com'
      expect(user).to be_valid
    end

    it 'with invalid email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'with valid passwrod' do
      user.password = 'mohsin'
      expect(user).to be_valid
    end

    it 'with invalid password' do
      user.password = nil
      expect(user).not_to be_valid
    end
  end

  context 'when calling name_with_email' do
    it 'returns email with user_type' do
      user.email = Faker::Internet.email
      user.user_type = 'qa'
      name_with_email = "#{user.email} (#{user.user_type})"
      expect(user.name_with_email).to eq(name_with_email)
    end
  end
end
