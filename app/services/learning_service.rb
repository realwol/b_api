# frozen_string_literal: true

class LearningService
  class << self
    def categories_for(user)
      LearningCategory.order(:sort_order).map do |category|
        skill = user_skill(user, category)
        category_json = category.as_json
        category_json["skill_level"] = skill.level
        category_json["skill_points"] = skill.skill_points
        category_json["exp_to_next_level"] = skill.exp_to_next_level
        category_json["courses"] = category.learning_courses.map do |course|
          course_json = course.as_json
          course_json["progress"] = progress_for(user, course)
          course_json["unlocked"] = course_unlocked?(user, course)
          course_json
        end
        category_json
      end
    end

    def start_course!(user, course)
      raise ApiError, "课程未解锁" unless course_unlocked?(user, course)

      progress = user.user_learning_progresses.find_or_initialize_by(learning_course: course)
      raise ApiError, "课程已完成" if progress.status == "completed"

      progress.status = "in_progress"
      progress.save!
      { course: course.as_json, progress: progress.as_json }
    end

    def complete_course!(user, course)
      progress = user.user_learning_progresses.find_by(learning_course: course)
      raise ApiError, "请先开始学习" unless progress&.status == "in_progress"

      progress.update!(status: "completed", completed_at: Time.current, skill_level: course.skill_points)

      skill = user_skill(user, course.learning_category)
      skill.skill_points += course.skill_points
      while skill.skill_points >= skill.exp_to_next_level
        skill.skill_points -= skill.exp_to_next_level
        skill.level += 1
      end
      skill.save!

      EconomyService.add_exp!(user, course.reward_exp, source: "learning",
                              description: "完成课程：#{course.title}")
      EconomyService.add_coins!(user, course.reward_coins, source: "learning_reward",
                                description: "完成课程：#{course.title}")

      unlock_next_course!(user, course)
      AchievementService.check!(user, :learning)
      AchievementService.check!(user, :user_level)

      {
        progress: progress.as_json,
        skill: skill.as_json,
        rewards: { exp: course.reward_exp, coins: course.reward_coins, skill_points: course.skill_points },
        user: user.reload.as_json
      }
    end

    def initialize_progress!(user)
      LearningCategory.find_each do |category|
        user_skill(user, category)
        first = category.learning_courses.order(:course_order).first
        next unless first

        progress = user.user_learning_progresses.find_or_initialize_by(learning_course: first)
        progress.status = "available" if progress.status == "locked"
        progress.save!
      end
    end

    def skills_summary(user)
      LearningCategory.order(:sort_order).map { |cat| skill_summary(user, cat) }
    end

    def skill_detail(user, category)
      skill = user_skill(user, category)
      courses = category.learning_courses.order(:course_order)
      completed = user.user_learning_progresses.where(learning_course: courses, status: "completed").count
      total = courses.count

      {
        category: category.as_json,
        skill: skill.as_json,
        progress: {
          completed_courses: completed,
          total_courses: total,
          percent: total.zero? ? 0 : (completed * 100 / total),
          next_course: next_course_for(user, courses)
        },
        milestones: build_milestones(category, skill.level),
        courses: courses.map do |course|
          course.as_json.merge(
            "progress" => progress_for(user, course),
            "unlocked" => course_unlocked?(user, course)
          )
        end,
        recent_completions: recent_completions(user, category)
      }
    end

    private

    def skill_summary(user, category)
      skill = user_skill(user, category)
      courses = category.learning_courses
      completed = user.user_learning_progresses.where(learning_course: courses, status: "completed").count
      {
        category: category.as_json,
        skill_level: skill.level,
        skill_points: skill.skill_points,
        exp_to_next_level: skill.exp_to_next_level,
        completed_courses: completed,
        total_courses: courses.count
      }
    end

    def build_milestones(category, current_level)
      milestones = category.milestones.presence || default_milestones
      milestones.map do |m|
        m = m.with_indifferent_access
        {
          level: m[:level],
          title: m[:title],
          description: m[:description],
          reward: m[:reward],
          unlocked: current_level >= m[:level].to_i
        }
      end
    end

    def default_milestones
      [
        { level: 1, title: "初窥门径", description: "技能达到1级" },
        { level: 3, title: "小有所成", description: "技能达到3级" },
        { level: 5, title: "融会贯通", description: "技能达到5级" },
        { level: 10, title: "一代宗师", description: "技能达到10级" }
      ]
    end

    def next_course_for(user, courses)
      courses.find { |c| course_unlocked?(user, c) && progress_for(user, c)["status"] != "completed" }&.as_json
    end

    def recent_completions(user, category)
      user.user_learning_progresses
          .joins(:learning_course)
          .where(learning_courses: { learning_category_id: category.id }, status: "completed")
          .order(completed_at: :desc)
          .limit(5)
          .map { |p| p.as_json.merge("course_title" => p.learning_course.title) }
    end

    def user_skill(user, category)
      user.user_skill_levels.find_or_create_by!(learning_category: category) do |s|
        s.level = 0
        s.skill_points = 0
      end
    end

    def progress_for(user, course)
      user.user_learning_progresses.find_by(learning_course: course)&.as_json || { status: "locked" }
    end

    def course_unlocked?(user, course)
      return false if user.user_level < course.unlock_level

      first = course.learning_category.learning_courses.order(:course_order).first
      return true if course.id == first&.id

      prev = course.learning_category.learning_courses
                   .where("course_order < ?", course.course_order)
                   .order(course_order: :desc).first
      return false unless prev

      user.user_learning_progresses.find_by(learning_course: prev)&.status == "completed"
    end

    def unlock_next_course!(user, course)
      next_course = course.learning_category.learning_courses
                          .where("course_order > ?", course.course_order)
                          .order(:course_order).first
      return unless next_course

      progress = user.user_learning_progresses.find_or_initialize_by(learning_course: next_course)
      progress.status = "available" if progress.status == "locked"
      progress.save!
    end
  end
end
