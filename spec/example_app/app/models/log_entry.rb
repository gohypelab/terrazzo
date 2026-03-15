class LogEntry < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  validate do |log_entry|
    if log_entry.action == "cancel" && log_entry.loggable.is_a?(Customer)
      log_entry.errors.add(:loggable, "A customer cannot be cancelled")
    end
  end
end
