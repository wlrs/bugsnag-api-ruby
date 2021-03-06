require "spec_helper"

describe Bugsnag::Api::Client::Projects do
  before do
    Bugsnag::Api.reset!
    @client = basic_auth_client
  end

  describe ".account_projects", :vcr do
    context "when using account credentials" do
      it "returns all projects" do
        client = auth_token_client
        projects = client.account_projects
        expect(projects).to be_kind_of(Array)
        expect(projects.first.name).not_to be_nil

        assert_requested :get, bugsnag_url("/account/projects")
      end
    end

    context "when using user credentials" do
      it "raises an error" do
        expect { @client.account_projects }.to raise_error Bugsnag::Api::AccountCredentialsRequired

        assert_not_requested :get, basic_bugsnag_url("/account/projects")
      end
    end

    it "returns all projects on an account" do
      projects = @client.account_projects(test_bugsnag_account)
      expect(projects).to be_kind_of(Array)
      expect(projects.first.name).not_to be_nil

      assert_requested :get, basic_bugsnag_url("/accounts/#{test_bugsnag_account}/projects")
    end
  end

  describe ".user_projects", :vcr do
    it "returns all projects for a user" do
      projects = @client.user_projects(test_bugsnag_user)
      expect(projects).to be_kind_of(Array)
      expect(projects.first.name).not_to be_nil

      assert_requested :get, basic_bugsnag_url("/users/#{test_bugsnag_user}/projects")
    end
  end

  describe ".create_project", :vcr do
    it "creates a project on an account" do
      project = @client.create_project(test_bugsnag_account, :name => "Example")
      expect(project.name).to eq("Example")

      assert_requested :post, basic_bugsnag_url("/accounts/#{test_bugsnag_account}/projects")
    end
  end

  context "with project", :vcr do
    before do
      @project = @client.create_project(test_bugsnag_account, :name => "Example")
    end

    describe ".project" do
      it "returns a project" do
        project = @client.project(@project.id)
        expect(project.id).to eq(@project.id)

        assert_requested :get, basic_bugsnag_url("/projects/#{@project.id}")
      end
    end

    describe ".update_project" do
      it "updates an existing project" do
        updated_project = @client.update_project(@project.id, :name => "New project name")
        expect(updated_project.id).to eq(@project.id)
        assert_requested :patch, basic_bugsnag_url("/projects/#{@project.id}")
      end
    end

    describe ".delete_project" do
      it "deletes an existing project" do
        response = @client.delete_project(@project.id)
        expect(response).to be true
        assert_requested :delete, basic_bugsnag_url("/projects/#{@project.id}")
      end
    end
  end
end
