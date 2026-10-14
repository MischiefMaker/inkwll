# Known VPN and data-centre address ranges, from a free public list that
# VpnListJob downloads once a day. Only used when the game's VPN block is on.
class VpnRange < ApplicationRecord
  # The list is maintained by X4BNet on GitHub (github.com/X4BNet/lists_vpn).
  LIST_URL = "https://raw.githubusercontent.com/X4BNet/lists_vpn/main/output/vpn/ipv4.txt"

  def self.covers?(ip)
    ip.present? && where("range >>= ?::inet", ip.to_s).exists?
  rescue ActiveRecord::StatementInvalid
    false
  end

  # Replaces the stored list with these ranges (one CIDR per line).
  def self.replace_with!(text)
    ranges = text.lines.map(&:strip).grep(%r{\A[0-9a-f:.]+(/\d+)?\z}i)
    return 0 if ranges.empty?

    transaction do
      delete_all
      ranges.each_slice(5_000) { |slice| insert_all(slice.map { |range| { range: range } }) }
    end
    ranges.size
  end
end
