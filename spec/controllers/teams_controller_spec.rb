require 'rails_helper'

# There are no expectations of assigns and templates rendered in this spec.
# These features have been removed from Rails core in Rails 5, but can be
# added back in via the `rails-controller-testing` gem.

RSpec.describe TeamsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Team. As you add validations to Team, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    FactoryBot.build(:team).attributes
  }

  let(:invalid_attributes) {
    FactoryBot.build(:team, name: '').attributes
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TeamsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      team = Team.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      team = Team.create! valid_attributes
      get :show, params: {id: team.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      team = Team.create! valid_attributes
      get :edit, params: {id: team.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Team" do
        expect {
          post :create, params: {team: valid_attributes}, session: valid_session
        }.to change(Team, :count).by(1)
      end

      it "redirects to the created team" do
        post :create, params: {team: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Team.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: {team: invalid_attributes}, session: valid_session
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {"name" => valid_attributes["name"] + "_new"}
      }

      it "updates the requested team" do
        team = Team.create! valid_attributes
        put :update, params: {id: team.to_param, team: new_attributes}, session: valid_session
        team.reload
        expect(team.name).to eq(new_attributes["name"])
      end

      it "redirects to the team" do
        team = Team.create! valid_attributes
        put :update, params: {id: team.to_param, team: valid_attributes}, session: valid_session
        expect(response).to redirect_to(team)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        team = Team.create! valid_attributes
        put :update, params: {id: team.to_param, team: invalid_attributes}, session: valid_session
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested team" do
      team = Team.create! valid_attributes
      expect {
        delete :destroy, params: {id: team.to_param}, session: valid_session
      }.to change(Team, :count).by(-1)
    end

    it "redirects to the teams list" do
      team = Team.create! valid_attributes
      delete :destroy, params: {id: team.to_param}, session: valid_session
      expect(response).to redirect_to(teams_url)
    end
  end

end
