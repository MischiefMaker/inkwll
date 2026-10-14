# Banning accounts and IP addresses, and lifting bans. The VPN block is a
# switch on this page too.
class Admin::BansController < Admin::BaseController
  require_job :ban

  def index
    @bans = Ban.includes(:account, :banned_by).order(created_at: :desc)
    @settings = GameSetting.current
  end

  def new
    @ban = Ban.new(account_id: params[:account_id])
  end

  def create
    @ban = Ban.new(banned_by: current_account, **ban_params)
    if params.dig(:ban, :player_name).present? && @ban.account.nil?
      @ban.errors.add(:base, "There's no player called \"#{params.dig(:ban, :player_name)}\"")
      return render :new, status: :unprocessable_entity
    end
    if @ban.account&.staff_rank.to_i >= current_account.staff_rank
      @ban.errors.add(:account, "is staff at your level or above")
      return render :new, status: :unprocessable_entity
    end

    if @ban.save
      @ban.account&.sessions&.destroy_all
      redirect_to admin_bans_path, notice: "Ban saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Lifts a ban, or switches the VPN block.
  def update
    if params[:id] == "vpn"
      GameSetting.current.update!(block_vpns: params[:block_vpns] == "1")
      VpnListJob.perform_later if GameSetting.current.block_vpns?
      redirect_to admin_bans_path, notice: GameSetting.current.block_vpns? ? "VPN block on. The list downloads in the background." : "VPN block off."
    else
      Ban.find(params[:id]).lift!
      redirect_to admin_bans_path, notice: "Ban lifted."
    end
  end

  private
    def ban_params
      permitted = params.expect(ban: [ :player_name, :ip_range, :reason, :expires_on ])
      account = Account.find_by(username: permitted[:player_name].to_s.strip.downcase) if permitted[:player_name].present?
      expires = Date.parse(permitted[:expires_on]).end_of_day if permitted[:expires_on].present?
      { account: account, ip_range: permitted[:ip_range].presence, reason: permitted[:reason], expires_at: expires }
    end
end
