# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:manager) { build :user, :manager }
  let(:project) { build :project, manager: manager }

  context 'with db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:description).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:manager_id).of_type(:integer) }
  end

  context 'with db index' do
    it { is_expected.to have_db_index(:title).unique(true) }
    it { is_expected.to have_db_index(:manager_id) }
  end

  context 'with associations' do
    it { is_expected.to belong_to(:manager).class_name('User') }
    it { is_expected.to have_many(:assignments).dependent(:delete_all) }
    it { is_expected.to have_many(:assigned_users).through(:assignments).source(:user) }
    it { is_expected.to have_many(:bugs).dependent(:destroy) }
  end

  context 'with validation tests' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }

    it 'with valid title' do
      project.title = 'Project1'
      expect(project).to be_valid
    end

    it 'with invalid title' do
      project.title = nil
      expect(project).not_to be_valid
    end

    it 'with valid description' do
      project.description = 'lorem posem ispum'
      expect(project).to be_valid
    end

    it 'with invalid description' do
      project.description = nil
      expect(project).not_to be_valid
    end

    it 'with valid manager' do
      project.manager = manager
      expect(project).to be_valid
    end

    it 'with invalid manager' do
      manager.user_type = 'developer'
      project.manager = manager
      expect(project).not_to be_valid
    end

    it 'invalid assign user' do
      expect { project.assigned_users << manager }.to raise_exception(ActiveRecord::Rollback)
    end
  end

  context 'with assign_users' do
    it 'assigns users' do
      users = User.developer.ids
      expect(project.assign_user(users)).to eq(project.assigned_users)
    end
  end
end
