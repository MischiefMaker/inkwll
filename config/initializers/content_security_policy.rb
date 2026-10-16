# The Content Security Policy tells browsers which scripts, styles, pictures
# and connections a page may use. If a player ever managed to sneak a script
# into a post, the browser would refuse to run it. See the Securing Rails
# Applications Guide:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    # Scripts only from this site, plus the import map Rails writes into each
    # page, which carries the nonce below.
    policy.script_src  :self
    # Styles allow inline style="" attributes: pages use them for colours and
    # sizes, and they can't run code.
    policy.style_src   :self, :unsafe_inline
    # Pictures in forum posts and wiki pages can come from other websites.
    policy.img_src     :self, :https, :data, :blob
    policy.font_src    :self, :data
    # Live updates (chat, Chapters) use a WebSocket back to this same site,
    # which "self" covers in current browsers.
    policy.connect_src :self
    policy.object_src  :none
    policy.base_uri    :self
    # Nobody else's site may show the game inside a frame.
    policy.frame_ancestors :none
  end

  # A nonce lets the import map's inline script run. It stays the same for a
  # visitor's whole session, so Turbo page changes keep working.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s.presence || SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[ script-src ]
end
