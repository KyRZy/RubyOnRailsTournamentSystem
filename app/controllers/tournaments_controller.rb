require 'json'

class TournamentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :update_tournament_brackets]
  before_action :set_tournament, except: [:index, :new, :create]
  before_action :has_team?, only: [:join_tournament]
  before_action :is_tournament_creator?, only: [:join_tournament]
  before_action :is_tournament_creator_from_the_same_team?, only: [:join_tournament]
  before_action :is_tournament_full?, only: [:join_tournament]
  before_action :max_participants_options, only: [:new, :edit]

  def has_team?
    if current_user.team.nil?
      flash[:error] = "You need to create/join team to join tournaments."
      redirect_to tournaments_url
    end
  end

  def is_tournament_creator?
    if @tournament.user == current_user
      flash[:error] = 'You cannot join your own tournaments.'
      redirect_to tournaments_url
    end
  end

  def is_tournament_creator_from_the_same_team?
    if @tournament.user.team == current_user.team
      flash[:error] = "You cannot join tournament created by your teammate."
      redirect_to tournaments_url
    end 
  end

  def is_tournament_full?
    if @tournament.participants.count == @tournament.max_participants
      flash[:error] = "You cannot join. Tournament is full."
      redirect_to @tournament
    end
  end

  def max_participants_options
    @max_participants_options = [16]
  end

  # GET /tournaments
  # GET /tournaments.json
  def index
    @tournaments = Tournament.all
  end

  # GET /tournaments/1
  # GET /tournaments/1.json
  def show
    if current_user.present? && current_user.team.present? && @tournament.participants.exists?(team_id: current_user.team.id)
      @current_user_in_tournament = true
    else
      @current_user_in_tournament = false
    end
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
  end

  # GET /tournaments/1/edit
  def edit
  end

  # POST /tournaments
  # POST /tournaments.json
  def create
    @tournament = Tournament.new(tournament_params)
    @tournament.user_id = current_user.id
    respond_to do |format|
      if @tournament.save
        flash[:success] = 'Tournament was successfully created.'
        format.html { redirect_to @tournament}
        format.json { render :show, status: :created, location: @tournament }
      else
        format.html { render :new }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tournaments/1
  # PATCH/PUT /tournaments/1.json
  def update
    respond_to do |format|
      if @tournament.update(tournament_params)
        flash[:success] = 'Tournament was successfully updated.'
        format.html { redirect_to @tournament}
        format.json { render :show, status: :ok, location: @tournament }
      else
        format.html { render :edit }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tournaments/1
  # DELETE /tournaments/1.json
  def destroy
    @tournament.destroy
    respond_to do |format|
      flash[:success] = 'Tournament was successfully destroyed.'
      format.html { redirect_to tournaments_url}
      format.json { head :no_content }
    end
  end

  def join_tournament
    if current_user.team.leader == current_user
      participant = Participant.create(tournament_id: @tournament.id, team_id: current_user.team.id)
      respond_to do |format|
        if participant.save
          flash[:success] = "Your team successfully joined the tournament."
          format.html { redirect_to @tournament}
          format.json { render :show, status: :created, location: @tournament }
        else
          format.html { render :new }
          format.json { render json: @tournament.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:error] = "Only leader of a team can join tournaments."
      redirect_to tournaments_url
    end 
  end

  def leave_tournament
    if current_user.team.leader == current_user
      Participant.where(tournament_id: @tournament.id, team_id: current_user.team.id).first.destroy
      respond_to do |format|
        flash[:success] = 'You successully left the tournament.'
        format.html { redirect_to tournaments_url}
        format.json { head :no_content }
      end
    else
      flash[:error] = "Only leader of a team can leave tournaments."
      redirect_to tournaments_url
    end 
  end

  def update_tournament_brackets  
    respond_to do |format|
      format.js
    end
  end

  def start_tournament
    if @tournament.matches.count == 0
      Match.transaction do
        participants = @tournament.participants

        for i in 0..(@tournament.max_participants/2 - 1)
          participant_a = participants.sample
          participants -= [participant_a]
          participant_b = participants.sample
          participants -= [participant_b]

          Match.create(participant_a: participant_a, participant_b: participant_b, stage: i)
        end
      end
    else
      @already_started = true
    end
    respond_to do |format|
      format.js
    end
  end

  def insert_match_score
    @score_a = params[:score_a]
    @score_b = params[:score_b]
    stage = params[:stage]

    Match.transaction do
      match = Match.update(params[:match_id], participant_a_score: @score_a, participant_b_score: @score_b)

      if @tournament.tournament_type.name == "Swiss system"
        
        if(@score_a > @score_b)
          match.participant_a.increment!(:wins)
          match.participant_b.increment!(:losses)
        else
          match.participant_b.increment!(:wins)
          match.participant_a.increment!(:losses)
        end

        # count amount of wins to estimate if any of the rounds ended
        wins = @tournament.participants.map(&:wins).sum

        # if end of round 1
        if wins == 8
          best = @tournament.participants.where("wins = 1")
          worst = @tournament.participants.where("losses = 1")

          # round 2 contains stages from 8 to 15 
          # to make 4 iterations instead of 8, winners and losers matches are created at the same time
          # losers matches are on stages 12-15 so offset from value of 1 equast 4
          for i in 8..11
            w_participant_a = best.sample
            best -= [w_participant_a]
            w_participant_b = best.sample
            best -= [w_participant_b]
  
            Match.create(participant_a: w_participant_a, participant_b: w_participant_b, stage: i)

            l_participant_a = worst.sample
            worst -= [l_participant_a]
            l_participant_b = worst.sample
            worst -= [l_participant_b]
  
            Match.create(participant_a: l_participant_a, participant_b: l_participant_b, stage: i+4)
          end
        
        # if end of round 2
        elsif wins == 16
          best = @tournament.participants.where("wins = 2")
          average = @tournament.participants.where("wins = 1")
          worst = @tournament.participants.where("losses = 2")

          for i in 16..17
            w_participant_a = best.sample
            best -= [w_participant_a]
            w_participant_b = best.sample
            best -= [w_participant_b]
  
            Match.create(participant_a: w_participant_a, participant_b: w_participant_b, stage: i)

            l_participant_a = worst.sample
            worst -= [l_participant_a]
            l_participant_b = worst.sample
            worst -= [l_participant_b]
  
            Match.create(participant_a: l_participant_a, participant_b: l_participant_b, stage: i+6)
          end

          for i in 18..21
            w_participant_a = average.sample
            average -= [w_participant_a]
            w_participant_b = average.sample
            average -= [w_participant_b]
  
            Match.create(participant_a: w_participant_a, participant_b: w_participant_b, stage: i)
          end

        # if end of round 3
        elsif wins == 24
          best = @tournament.participants.where("wins = 2 AND losses = 1")
          worst = @tournament.participants.where("wins = 1 AND losses = 2")

          for i in 24..26
            w_participant_a = best.sample
            best -= [w_participant_a]
            w_participant_b = best.sample
            best -= [w_participant_b]
  
            Match.create(participant_a: w_participant_a, participant_b: w_participant_b, stage: i)

            l_participant_a = worst.sample
            worst -= [l_participant_a]
            l_participant_b = worst.sample
            worst -= [l_participant_b]
  
            Match.create(participant_a: l_participant_a, participant_b: l_participant_b, stage: i+3)
          end

        # if end of round 4
        elsif wins == 30
          remaining = @tournament.participants.where("wins = 2 AND losses = 2")

          for i in 30..32
            w_participant_a = remaining.sample
            remaining -= [w_participant_a]
            w_participant_b = remaining.sample
            remaining -= [w_participant_b]
  
            Match.create(participant_a: w_participant_a, participant_b: w_participant_b, stage: i)
          end
        end

      else
        # Single and Double elimination
        winner = nil
        loser = nil
        if(@score_a > @score_b)
          winner = match.participant_a
          loser = match.participant_b
        else
          winner = match.participant_b
          loser = match.participant_a
        end
  
        path = Rails.public_path.join('matches.json')
        file = File.read(path)
        data_hash = JSON.parse(file)
  
        next_matches = data_hash[@tournament.tournament_type.name][stage]
        if next_matches.key?("winner")
          next_stage_match = @tournament.matches.find {|match| match.stage == next_matches["winner"]["next_stage"]}
          if next_stage_match.present?
            if next_matches["winner"]["side"] == "a"
              Match.update(next_stage_match ,participant_a: winner)
            else
              Match.update(next_stage_match, participant_b: winner)
            end
          else
            if next_matches["winner"]["side"] == "a"
              Match.create(participant_a: winner, stage: next_matches["winner"]["next_stage"])
            else
              Match.create(participant_b: winner, stage: next_matches["winner"]["next_stage"])
            end
          end
        end
  
        if next_matches.key?("loser")
          next_stage_match = @tournament.matches.find {|match| match.stage == next_matches["loser"]["next_stage"]}
          if next_stage_match.present?
            if next_matches["loser"]["side"] == "a"
              Match.update(next_stage_match ,participant_a: loser)
            else
              Match.update(next_stage_match, participant_b: loser)
            end
          else
            if next_matches["loser"]["side"] == "a"
              Match.create(participant_a: loser, stage: next_matches["loser"]["next_stage"])
            else
              Match.create(participant_b: loser, stage: next_matches["loser"]["next_stage"])
            end
          end
        end
      end

    end

    #if not match
    #  @not_saved = true
    #end

    respond_to do |format|
      format.js
    end
  end

  def remove_all_matches
    Participant.transaction do
      @tournament.matches.each do |m|
        m.destroy
      end
      @tournament.participants.each do |p|
        Participant.update(p.id, wins: 0, losses: 0)
      end
    end
    redirect_to @tournament
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tournament_params
      params.require(:tournament).permit(:user_id, :name, :tournament_type_id, :max_participants, :start_date, :finished)
    end
end
