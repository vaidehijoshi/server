# frozen_string_literal: true

class AddonSizeCalculator

  def self.calculate_addon_sizes(addons)
    ember_new_output = EmberNewOutput.install
    addons.each do |addon|
      addon_version = addon.newest_version
      next if addon_version.has_size_data

      begin
        diff = ember_new_output.install_addon_and_measure(addon_version)
      rescue => e
        Rails.logger.error("Failed to measure addon #{addon_version.addon_name}: #{e}")
      end
      AddonSizeUpdater.perform_later(addon_version.id, diff.to_h)
    end
    ember_new_output.cleanup
  end

end