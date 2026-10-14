# The words players see, for use outside views (models, controllers, flash
# messages). Views use the `term` helper instead. See config/locales/en.yml.
module Term
  def self.[](name, count: 1)
    I18n.t("terms.#{name}", count: count)
  end
end
