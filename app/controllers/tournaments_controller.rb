class TournamentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :update_tournament_brackets]
  before_action :set_tournament, except: [:index, :new, :create]
  before_action :has_team?, only: [:join_tournament]
  before_action :is_tournament_creator?, only: [:join_tournament]
  before_action :is_tournament_creator_from_the_same_team?, only: [:join_tournament]
  before_action :is_tournament_full?, only: [:join_tournament]

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
    @max_participants_options = [16]
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
      participant = Participant.create(tournament_id: @tournament.id,team_id: current_user.team.id)
      respond_to do |format|
        if participant.save
          flash[:success] = "Your team successfully join the tournament."
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
      Participant.where(tournament_id: @tournament.id,team_id: current_user.team.id).first.destroy
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
      Tournament.transaction do
        participants = @tournament.participants
        puts participants.class


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

    @stage = params[:stage]

    match = Match.update(params[:match_id], participant_a_score: @score_a, participant_b_score: @score_b)

    if not match
      @not_saved = true
    end

    respond_to do |format|
      format.js
    end
  end

  def remove_all_matches
    Tournament.transaction do
      @tournament.matches.each do |m|
        m.destroy
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
