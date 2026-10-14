# One saved version of a wiki page.
class WikiRevision < ApplicationRecord
  belongs_to :page, class_name: "WikiPage"
  belongs_to :account, optional: true
end
