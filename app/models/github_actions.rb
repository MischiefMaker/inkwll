# Talks to GitHub for the Founder's Wells page: lists the versions marked
# ready (config/versions.yml on main) and starts the Deploy workflow, which
# does the real work. The game only holds a token that can run workflows and read the
# code; the keys that log in to droplets stay in GitHub. See docs/wells.md.
require "net/http"

class GithubActions
  class Error < StandardError; end

  Release = Data.define(:tag, :name, :notes, :published_at)
  Run = Data.define(:id, :url, :status, :conclusion)

  WORKFLOW = "deploy.yml"
  VERSIONS_FILE = "config/versions.yml"

  # Tests swap in a stand-in so nothing reaches GitHub.
  class << self
    attr_writer :current
    def current = @current || new
  end

  def configured? = token.present?

  # Versions marked ready, newest first, read from main on GitHub so a new
  # version shows up without a deploy.
  def releases
    self.class.parse_versions(get_raw("/contents/#{VERSIONS_FILE}?ref=#{branch}"))
  end

  def self.parse_versions(yaml)
    Array(YAML.safe_load(yaml.to_s, permitted_classes: [ Date ])).filter_map do |entry|
      next unless entry.is_a?(Hash) && entry["version"].present?
      Release.new(tag: entry["version"].to_s, name: entry["version"].to_s, notes: entry["notes"].to_s, published_at: entry["date"]&.to_date)
    end
  rescue Psych::Exception
    raise Error, "#{VERSIONS_FILE} couldn't be read."
  end

  # Asks GitHub to run Deploy with this version. GitHub doesn't say which run
  # it started, so the request id goes into the run's title to find it later.
  # For another Well, well: is its row, and first_time: starts it.
  def start_update(version:, request_id:, well: nil, first_time: false)
    inputs = { version: version, request_id: request_id }
    inputs.merge!(well: well.slug, well_domain: well.domain, well_name: well.name) if well
    inputs.merge!(first_time: "true", setup_code: well.setup_code) if well && first_time
    post("/actions/workflows/#{WORKFLOW}/dispatches", ref: branch, inputs: inputs)
  end

  def find_run(request_id)
    run = get_json("/actions/workflows/#{WORKFLOW}/runs?event=workflow_dispatch&per_page=30")["workflow_runs"].to_a
      .find { |r| r["display_title"].to_s.include?("(#{request_id})") }
    run && to_run(run)
  end

  def run(id)
    to_run(get_json("/actions/runs/#{id.to_i}"))
  end

  private
    def token = ENV["WELLS_GITHUB_TOKEN"]
    def repo = ENV.fetch("WELLS_GITHUB_REPO", "MischiefMaker/inkwll")
    def branch = ENV.fetch("WELLS_GITHUB_BRANCH", "main")

    def to_run(r)
      Run.new(id: r["id"], url: r["html_url"], status: r["status"], conclusion: r["conclusion"])
    end

    def get_json(path)
      body = request(Net::HTTP::Get.new(uri(path)))
      JSON.parse(body)
    rescue JSON::ParserError
      raise Error, "GitHub sent back something unexpected. Try again in a minute."
    end

    # The file's own text rather than GitHub's description of it.
    def get_raw(path)
      request(Net::HTTP::Get.new(uri(path)), accept: "application/vnd.github.raw+json")
    end

    def post(path, body)
      req = Net::HTTP::Post.new(uri(path))
      req.body = body.to_json
      req["Content-Type"] = "application/json"
      request(req)
    end

    def uri(path) = URI("https://api.github.com/repos/#{repo}#{path}")

    def request(req, accept: "application/vnd.github+json")
      raise Error, "The GitHub key isn't set up yet." unless configured?
      req["Accept"] = accept
      req["Authorization"] = "Bearer #{token}"
      req["X-GitHub-Api-Version"] = "2022-11-28"
      response = Net::HTTP.start(req.uri.host, req.uri.port, use_ssl: true, open_timeout: 5, read_timeout: 15) { |http| http.request(req) }
      unless response.is_a?(Net::HTTPSuccess)
        raise Error, "GitHub said no (#{response.code}). The key may have expired or be missing a permission."
      end
      response.body.to_s
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, OpenSSL::SSL::SSLError
      raise Error, "Couldn't reach GitHub. Try again in a minute."
    end
end
