# Banning accounts and IP addresses, and lifting bans. The VPN block is a
# switch on this page too.
class Admin::BansController < Admin::BaseController
  require_job :ban

  def index
    @bans = Ban.includes(:account, :banned_by).order(created_at: :desc)
    @settings = GameSetting.current
    # Guests who chatted in the last week, newest first, one row per address.
    @guests = OocMessage.from_guests.where(created_at: 1.week.ago..).order(created_at: :desc).group_by(&:ip_address)
  end

  def new
    @ban = Ban.new(account_id: params[:account_id], ip_range: params[:ip])
  end

  def create
    @ban = Ban.new(banned_by: current_account, **ban_params)
    if params.dig(:ban, :expires_on).present? && @ban.expires_at.nil?
      @ban.errors.add(:base, "The end date isn't a real date")
      return render :new, status: :unprocessable_entity
    end
    if params.dig(:ban, :player_name).present? && @ban.account.nil?
      @ban.errors.add(:base, "There's no player called \"#{params.dig(:ban, :player_name)}\"")
      return render :new, status: :unprocessable_entity
    end
    if @ban.account && (@ban.account.founder? || @ban.account.staff_rank >= current_account.staff_rank)
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
      ban = Ban.find(params[:id])
      if ban.liftable_by?(current_account)
        ban.lift!
        redirect_to admin_bans_path, notice: "Ban lifted."
      else
        redirect_to admin_bans_path, alert: "Only staff at #{ban.banned_by.display_name}'s level or above can lift that ban."
      end
    end
  end

  private
    def ban_params
      permitted = params.expect(ban: [ :player_name, :ip_range, :reason, :expires_on ])
      account = Account.find_by(username: permitted[:player_name].to_s.strip.downcase) if permitted[:player_name].present?
      expires = (Date.parse(permitted[:expires_on]).end_of_day rescue nil) if permitted[:expires_on].present?
      { account: account, ip_range: permitted[:ip_range].presence, reason: permitted[:reason], expires_at: expires }
    end
end
