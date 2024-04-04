# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bug, type: :model do
  let(:qa) { build :user, :qa }
  let(:bug) { build :bug, creator: qa }

  context 'with db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:deadline).of_type(:datetime) }
    it { is_expected.to have_db_column(:bug_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:status).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:project_id).of_type(:integer) }
    it { is_expected.to have_db_column(:creator_id).of_type(:integer) }
  end

  context 'with db index' do
    it { is_expected.to have_db_index(:title).unique(true) }
    it { is_expected.to have_db_index(:creator_id) }
    it { is_expected.to have_db_index(:project_id) }
    it { is_expected.to have_db_index(:developer_id) }
  end

  context 'with associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:developer).class_name('User').optional(true) }
  end

  context 'with validations' do
    subject { build :bug }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:bug_type) }
    it { is_expected.to validate_presence_of(:deadline) }
    it { is_expected.to validate_uniqueness_of(:title) }
    it { is_expected.to define_enum_for(:status).with_values(fresh: 0, started: 1, completed: 2, resolved: 3) }
    it { is_expected.to validate_inclusion_of(:bug_type).in_array(%w[feature bug]).with_message(:bug_type_invalid) }

    it 'valid title' do
      bug.title = 'Bug1'
      expect(bug).to be_valid
    end

    it 'invalid title' do
      bug.title = nil
      expect(bug).not_to be_valid
    end

    it 'valid deadline' do
      bug.deadline = Time.now.utc + 20.days
      expect(bug).to be_valid
    end

    it 'invalid deadline' do
      bug.deadline = nil
      expect(bug).not_to be_valid
    end

    it 'with valid bug_type' do
      bug.bug_type = 'feature'
      expect(bug).to be_valid
    end

    it 'invalid bug_type' do
      bug.bug_type = nil
      expect(bug).not_to be_valid
    end

    it 'invalid bug_type value' do
      bug.bug_type = 'dfdgf'
      expect(bug).not_to be_valid
    end

    it 'invalid developer' do
      bug.developer = qa
      expect(bug).not_to be_valid
    end

    it 'valid screenshot' do
      bug.screenshot = fixture_file_upload('/home/dev/Downloads/404.png', 'image/png')
      expect(bug).to be_valid
    end

    it 'invalid screenshot' do
      bug.screenshot = fixture_file_upload('/home/dev/Downloads/my_pic.jpeg', 'image/jpeg')
      expect(bug).not_to be_valid
    end
  end

  context 'when check_status_param' do
    it 'valid status param' do
      expect(described_class.new.check_status_param?('completed')).to be(true)
    end

    it 'invalid status param' do
      expect(described_class.new.check_status_param?('dyfvodfv')).to be(false)
    end
  end
end
