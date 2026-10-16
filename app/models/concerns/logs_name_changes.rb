# Keeps a log of renames. Include it and say which column holds the name:
#   logs_name_changes :name
module LogsNameChanges
  extend ActiveSupport::Concern

  class_methods do
    def logs_name_changes(column)
      has_many :name_changes, as: :subject, dependent: :delete_all
      after_update do
        if saved_change_to_attribute?(column)
          old_name, new_name = saved_change_to_attribute(column)
          name_changes.create!(old_name: old_name, new_name: new_name, changed_by: Current.account)
        end
      end
    end
  end
end
