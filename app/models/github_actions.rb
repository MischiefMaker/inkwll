# Talks to GitHub for the Founder's Wells page: lists the versions marked
# ready (GitHub Releases) and starts the Deploy workflow, which does the real
# work. The game only holds a token that can run workflows and read the
# code; the keys that log in to droplets stay in GitHub. See docs/wells.md.
require "net/http"

class GithubActions
  class Error < StandardError; end

  Release = Data.define(:tag, :name, :notes, :published_at)
  Run = Data.define(:id, :url, :status, :conclusion)

  WORKFLOW = "deploy.yml"

  # Tests swap in a stand-in so nothing reaches GitHub.
  class << self
    attr_writer :current
    def current = @current || new
  end

  def configured? = token.present?

  # Versions marked ready, newest first. Drafts and test builds are left out.
  def releases
    get("/releases?per_page=20").reject { |r| r["draft"] || r["prerelease"] }.map do |r|
      Release.new(tag: r["tag_name"], name: r["name"].presence || r["tag_name"], notes: r["body"].to_s, published_at: Time.zone.parse(r["published_at"].to_s))
    end
  end

  # Asks GitHub to run Deploy with this version. GitHub doesn't say which run
  # it started, so the request id goes into the run's title to find it later.
  def start_update(version:, request_id:)
    post("/actions/workflows/#{WORKFLOW}/dispatches", ref: branch, inputs: { version: version, request_id: request_id })
  end

  def find_run(request_id)
    run = get("/actions/workflows/#{WORKFLOW}/runs?event=workflow_dispatch&per_page=30")["workflow_runs"].to_a
      .find { |r| r["display_title"].to_s.include?("(#{request_id})") }
    run && to_run(run)
  end

  def run(id)
    to_run(get("/actions/runs/#{id.to_i}"))
  end

  private
    def token = ENV["WELLS_GITHUB_TOKEN"]
    def repo = ENV.fetch("WELLS_GITHUB_REPO", "MischiefMaker/inkwll")
    def branch = ENV.fetch("WELLS_GITHUB_BRANCH", "main")

    def to_run(r)
      Run.new(id: r["id"], url: r["html_url"], status: r["status"], conclusion: r["conclusion"])
    end

    def get(path) = request(Net::HTTP::Get.new(uri(path)))

    def post(path, body)
      req = Net::HTTP::Post.new(uri(path))
      req.body = body.to_json
      req["Content-Type"] = "application/json"
      request(req)
    end

    def uri(path) = URI("https://api.github.com/repos/#{repo}#{path}")

    def request(req)
      raise Error, "The GitHub key isn't set up yet." unless configured?
      req["Accept"] = "application/vnd.github+json"
      req["Authorization"] = "Bearer #{token}"
      req["X-GitHub-Api-Version"] = "2022-11-28"
      response = Net::HTTP.start(req.uri.host, req.uri.port, use_ssl: true, open_timeout: 5, read_timeout: 15) { |http| http.request(req) }
      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "GitHub said no (#{response.code}). The key may have expired or be missing a permission."
      end
      response.body.present? ? JSON.parse(response.body) : {}
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, OpenSSL::SSL::SSLError, JSON::ParserError
      raise Error, "Couldn't reach GitHub. Try again in a minute."
    end
end
