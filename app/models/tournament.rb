# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :text
#  discipline       :string
#  player_type      :integer          not null
#  max_teams        :integer
#  game_mode        :integer          not null
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  startdate        :date
#  enddate          :date
#  deadline         :date
#  gameday_duration :integer
#  owner_id         :integer
#

class Tournament < Event
  enum game_modes: [:ko, :ko_group, :double_elimination]

  def standing_of(team)
    last_match = last_match_of team, finale
    standing_string team, last_match
  end

  def finale
    finale = nil
    matches.each do |match|
      if match.depth == 0
        finale = match
      end
    end
    #TODO: keep care of 3rd place match here
    finale
  end

  def generate_schedule
    create_matches filled_teams, max_match_level, 0
    beautify_match_indices
  end

  def max_match_level
    Math.log(teams.length, 2).ceil - 1
  end

  private

    def last_match_of(team, match)
      if match.is_team_recursive? team
        return match
      end
      standing_recursion_step(team, match.team_home) || standing_recursion_step(team, match.team_away)
    end

    def standing_string(team, match)
      match_name = match.round
      if match.loser == team
        return I18n.t 'events.overview.out', match_name: match_name
      end
      I18n.t 'events.overview.in', match_name: match_name
    end

    def standing_recursion_step(team, child)
      if child.is_a? Match
        last_match_of team, child
      end
    end

    def filled_teams
      filled_teams = shuffled_teams
      insert_index = 0
      until is_power_of_two? filled_teams.length
        filled_teams.insert insert_index, nil
        insert_index += 2
      end
      filled_teams
    end

    def shuffled_teams
      team_copy = []
      teams.each { |team| team_copy << team }
      team_copy.shuffle!
    end

    def create_matches(team_array, depth, index)
      if team_array.length <= 2
        return create_leaf_match *team_array, depth, index
      end

      left_half, right_half = split_teams_array team_array
      child_depth = depth - 1
      match_left = create_matches left_half, child_depth, (2 * index)
      match_right = create_matches right_half, child_depth, (2 * index + 1)

      create_match match_left, match_right, depth, index
    end

    def split_teams_array(team_array)
      half_team_count = team_array.length / 2
      left_half = team_array.first half_team_count
      right_half = team_array.last half_team_count
      return left_half, right_half
    end

    def create_leaf_match(team_home, team_away, depth, index)
      unless team_home.nil? || team_away.nil?
        return create_match team_home, team_away, depth, index
      end
      team_home || team_away
    end

    def create_match(team_home, team_away, depth, index)
      match = Match.new team_home: team_home, team_away: team_away, gameday: depth, index: index + 1, event: self
      match.save!
      match
    end

    def beautify_match_indices
      first_match = matches[0]
      first_gameday_index_offset = first_match.index - 1
      matches.each do |match|
        if match.gameday == first_match.gameday
          match.index -= first_gameday_index_offset
          match.save!
        end
      end
    end

    def is_power_of_two?(number)
      number.to_s(2).count('1') == 1
    end
end
