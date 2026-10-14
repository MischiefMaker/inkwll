# Building tools: make several rooms (Settings) and the exits (Paths)
# between them on one screen, for laying out a big area at once.
class Admin::BulkBuildsController < Admin::BaseController
  require_job :build
  limit_posting to: 10, within: 10.minutes, only: :create

  def new
    @bulk_build = BulkBuild.blank(area_id: params[:area_id])
  end

  def create
    @bulk_build = BulkBuild.new(bulk_build_params)
    if @bulk_build.save
      redirect_to admin_areas_path, notice: "Added #{count_of(:room, @bulk_build.rooms)} and #{count_of(:exit, @bulk_build.exits)}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def count_of(term, records)
      "#{records.size} #{Term[term, count: records.size].downcase}"
    end

    def bulk_build_params
      params.fetch(:bulk_build, {}).permit(:area_id, rooms: {}, paths: {})
    end
end
