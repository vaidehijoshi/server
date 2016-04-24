require 'test_helper'

class BuildQueueControllerTest < ControllerTest
  test "responds with HTTP unauthorized when request doesn't include a token" do
    post :get_build

    assert_response :unauthorized
  end

  test "responds with HTTP 204 (no content) when no builds are in the queue" do
    authed_post :get_build

    assert_response :no_content
  end

  test "responds with HTTP 204 (no content) when the queue is not empty but all builds are assigned" do
    addon_version = create(:addon_version)
    other_build_server = create(:build_server)
    x = create(:pending_build, addon_version: addon_version, build_server: other_build_server, build_assigned_at: 1.hour.ago)

    authed_post :get_build

    assert_response :no_content
  end

  test "responds with build info for the oldest non-assigned build when queue is not empty" do
    addon = create(:addon, repository_url: 'file:///')
    oldest_addon_version, middle_addon_version, newest_addon_version = create_list(:addon_version, 3, addon: addon)

    create :pending_build, addon_version: oldest_addon_version, created_at: 2.months.ago, build_server: create(:build_server), build_assigned_at: 2.months.ago
    create :pending_build, addon_version: middle_addon_version, created_at: 1.month.ago
    create :pending_build, addon_version: newest_addon_version, created_at: 1.hour.ago

    authed_post :get_build

    assert_response :success
    assert_equal addon.name, json_response['pending_build']['addon_name']
    assert_equal 'file:///', json_response['pending_build']['repository_url']
    assert_equal middle_addon_version.version, json_response['pending_build']['version']
  end

  test "sets the build server and assigned date when a build is requested" do
    addon_version = create(:addon_version)
    pending_build = create(:pending_build, addon_version: addon_version)

    authed_post :get_build

    pending_build.reload

    assert_equal build_server.id, pending_build.build_server_id
    assert_not_nil pending_build.build_assigned_at
  end

  test "returns HTTP 423 (locked) when a request is made using a token that already has a build assigned" do
    addon_version = create(:addon_version)
    create(:pending_build, addon_version: addon_version, build_server: build_server, build_assigned_at: 1.day.ago)

    authed_post :get_build

    assert_response :locked
  end

  private

  def build_server
    @build_server ||= create(:build_server)
  end

  def authed_post(action, data=nil)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(build_server.token)
    post action, data
  end
end