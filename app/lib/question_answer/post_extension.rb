# frozen_string_literal: true

module QuestionAnswer
  module PostExtension
    after_create :qa_update_vote_order, if: :qa_enabled

    def qa_vote_count
      if custom_fields['vote_count'].present?
        custom_fields['vote_count'].to_i
      else
        0
      end
    end

    def qa_voted
      if custom_fields['voted'].present?
        [*custom_fields['voted']].map(&:to_i)
      else
        []
      end
    end

    def qa_vote_history
      if custom_fields['vote_history'].present?
        [*custom_fields['vote_history']]
      else
        []
      end
    end

    def qa_enabled
      ::Topic.qa_enabled(topic)
    end

    def qa_update_vote_order
      ::Topic.qa_update_vote_order(topic_id)
    end

    def qa_last_voted(user_id)
      user_votes = qa_vote_history.select do |v|
        v['user_id'].to_i == user_id && v['action'] == 'create'
      end

      return unless user_votes.any?

      user_votes
        .min_by { |v| v['created_at'].to_i }
        .first['created_at']
        .to_datetime
    end

    def qa_can_vote(user_id)
      SiteSetting.qa_tl_allow_multiple_votes_per_post ||
        !qa_voted.include?(user_id)
    end
  end
end
