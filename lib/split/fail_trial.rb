# frozen_string_literal: true
module Split
  class FailTrial < Split::Trial

    # Choose an alternative, add a participant, and save the alternative choice on the user. This
    # method is guaranteed to only run once, and will skip the alternative choosing process if run
    # a second time.
    def choose!(context = nil)
      @user.cleanup_old_experiments!
      # Only run the process once
      return alternative if @alternative_choosen

      if override_is_alternative?
        self.alternative = @options[:override]
        if should_store_alternative? && !@user[@experiment.key]
          self.alternative.increment_participation
        end
      elsif @options[:disabled] || Split.configuration.disabled?
        self.alternative = @experiment.control
      elsif @experiment.has_winner?
        self.alternative = @experiment.winner
      else
        cleanup_old_versions

        if exclude_user?
          self.alternative = @experiment.control
        else
          self.alternative = @user[@experiment.key]
          if alternative.nil?
            self.alternative = @experiment.next_alternative

            # Increment the number of participants since we are actually choosing a new alternative
            self.alternative.increment_participation

            run_callback context, Split.configuration.on_trial_choose
          else
            # this difference between the parent class and this one is here
            self.alternative.fail_and_increment
          end
        end
      end

      @user[@experiment.key] = alternative.name if !@experiment.has_winner? && should_store_alternative?
      @alternative_choosen = true
      run_callback context, Split.configuration.on_trial unless @options[:disabled] || Split.configuration.disabled?
      alternative
    end
  end
end
