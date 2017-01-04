class API::V2::GithubStatsResource < JSONAPI::Resource
  attributes :stars,
             :latest_commit_date,
             :first_commit_date,
             :forks,
             :open_issues,
             :committed_to_recently

  has_one :addon

  def committed_to_recently
    @model.addon_recently_committed_to?
  end
end
