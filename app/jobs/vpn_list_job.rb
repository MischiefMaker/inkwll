require "net/http"

# Downloads the free list of known VPN addresses, once a day. Does nothing
# while the game's VPN block is switched off.
class VpnListJob < ApplicationJob
  queue_as :default

  def perform
    return unless GameSetting.current.block_vpns?

    response = Net::HTTP.get_response(URI(VpnRange::LIST_URL))
    if response.is_a?(Net::HTTPSuccess)
      count = VpnRange.replace_with!(response.body)
      Rails.logger.info "VPN list updated: #{count} ranges"
    else
      Rails.logger.warn "VPN list download failed: #{response.code}"
    end
  end
end
