# == Schema Information
#
# Table name: matches
#
#  id             :integer          not null, primary key
#  place          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  team_home_id   :integer
#  team_away_id   :integer
#  event_id       :integer
#  points_home    :integer
#  points_away    :integer
#  gameday        :integer
#  team_home_type :string           default("Team")
#  team_away_type :string           default("Team")
#  index          :integer
#

class Match < ApplicationRecord
  belongs_to :team_home, polymorphic: true
  belongs_to :team_away, polymorphic: true
  belongs_to :event, dependent: :delete
  has_many :game_results, dependent: :delete_all

  accepts_nested_attributes_for :game_results, allow_destroy: true
  has_many :match_results, dependent: :destroy

  after_validation :calculate_points

  validates :points_home, :points_away, numericality: { allow_nil: true }

  def depth
    event.finale_gameday - gameday
  end

  def round
    key = { 0 => 'zero', 1 => 'one', 2 => 'two', 3 => 'three' }[depth]
    key ||= 'other'
    I18n.t('matches.round_name.' + key, round: (gameday + 1).to_s, gameid: index.to_s)
  end

  def score_home_total
    game_results.inject(0) { |sum, result| sum + result.score_home }
  end

  def score_away_total
    game_results.inject(0) { |sum, result| sum + result.score_away }
  end

  def select_results_by_score(score_comparison)
    game_results.select { |current_result| (current_result.score_home.nil? || current_result.score_away.nil?) ? false : current_result.score_home.send(score_comparison, current_result.score_away) }
  end

  def wins_home
    select_results_by_score(:>).length
  end

  def wins_away
    select_results_by_score(:<).length
  end

  def has_points?
    points_home.present? && points_away.present?
  end

  def has_scores?
    game_results.each do |result|
      if result.score_home.present? && result.score_away.present?
        return true
      end
    end
    return false
  end

  def has_winner?
    wins_home != wins_away
  end

  def winner
    if has_winner?
      wins_home > wins_away ? team_home_recursive : team_away_recursive
    end
  end

  def loser
    if has_winner?
      wins_home < wins_away ? team_home_recursive : team_away_recursive
    end
  end

  def team_home_recursive
    team_home.advancing_participant
  end

  def team_away_recursive
    team_away.advancing_participant
  end

  def is_team_recursive?(team)
    team_home_recursive == team || team_away_recursive == team
  end

  def standing_string_of(team)
    match_name = round
    if loser == team
      return I18n.t 'events.overview.out', match_name: match_name
    end
    I18n.t 'events.overview.in', match_name: match_name
  end

  def last_match_of(team)
    if is_team_recursive? team
      return self
    end
    team_home.last_match_of(team) || team_away.last_match_of(team)
  end

  def adjust_index_by(offset)
    self.index -= offset
    save!
  end

  def set_points(home, away)
    self.points_home = home
    self.points_away = away
  end

  def calculate_points
    return if !has_scores? || has_points?

    if wins_home > wins_away
      set_points(3, 0)
    elsif wins_home < wins_away
      set_points(0, 3)
    else
      set_points(1, 1)
    end
  end
end
