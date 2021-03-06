# == Schema Information
#
# Table name: match_results
#
#  id              :integer          not null, primary key
#  match_id        :integer
#  winner_advances :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe MatchResult, type: :model do
  it 'can have advancing losers' do
    match_result = FactoryBot.create :match_result, winner_advances: false
    match = match_result.match
    match.points_home = 1
    match.points_away = 2
    expect(match_result.advancing_participant).to eq(match.loser)
  end
end
