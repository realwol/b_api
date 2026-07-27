# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_07_24_000003) do
  create_table "achievements", force: :cascade do |t|
    t.string "key", null: false
    t.string "title", null: false
    t.text "description"
    t.string "category", null: false
    t.string "condition_type", null: false
    t.integer "condition_value", default: 1, null: false
    t.integer "reward_coins", default: 0, null: false
    t.integer "reward_gems", default: 0, null: false
    t.integer "reward_exp", default: 0, null: false
    t.string "icon_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_achievements_on_category"
    t.index ["key"], name: "index_achievements_on_key", unique: true
  end

  create_table "care_logs", force: :cascade do |t|
    t.integer "character_id", null: false
    t.string "action_type", null: false
    t.integer "item_id"
    t.json "result", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "created_at"], name: "index_care_logs_on_character_id_and_created_at"
    t.index ["character_id"], name: "index_care_logs_on_character_id"
    t.index ["item_id"], name: "index_care_logs_on_item_id"
  end

  create_table "characters", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.json "appearance", default: {}, null: false
    t.integer "level", default: 1, null: false
    t.integer "exp", default: 0, null: false
    t.string "stage", default: "baby", null: false
    t.integer "charm", default: 10, null: false
    t.integer "intelligence", default: 10, null: false
    t.integer "mood", default: 80, null: false
    t.integer "energy", default: 100, null: false
    t.integer "hunger", default: 50, null: false
    t.integer "affection", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "last_cared_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "coin_transactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "amount", null: false
    t.integer "balance_after", null: false
    t.string "source", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "created_at"], name: "index_coin_transactions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_coin_transactions_on_user_id"
  end

  create_table "daily_check_ins", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "check_in_date", null: false
    t.integer "reward_coins", default: 0, null: false
    t.integer "reward_gems", default: 0, null: false
    t.integer "streak_day", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "check_in_date"], name: "index_daily_check_ins_on_user_id_and_check_in_date", unique: true
    t.index ["user_id"], name: "index_daily_check_ins_on_user_id"
  end

  create_table "decorations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "slot_type", null: false
    t.string "rarity", default: "common", null: false
    t.integer "price_coins", default: 0, null: false
    t.integer "price_gems", default: 0, null: false
    t.integer "comfort_bonus", default: 0, null: false
    t.integer "beauty_bonus", default: 0, null: false
    t.string "icon_url"
    t.string "sprite_url"
    t.boolean "is_shop_item", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slot_type"], name: "index_decorations_on_slot_type"
  end

  create_table "event_templates", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.string "event_type", null: false
    t.integer "difficulty", default: 1, null: false
    t.integer "game_map_id"
    t.integer "map_zone_id"
    t.integer "learning_category_id"
    t.integer "min_user_level", default: 1, null: false
    t.integer "max_user_level", default: 999, null: false
    t.integer "trigger_weight", default: 100, null: false
    t.integer "cooldown_minutes", default: 0, null: false
    t.json "content", default: {}, null: false
    t.json "rewards_config", default: {}, null: false
    t.json "trigger_conditions", default: {}, null: false
    t.boolean "sensor_triggerable", default: false, null: false
    t.boolean "is_active", default: true, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_event_templates_on_event_type"
    t.index ["game_map_id"], name: "index_event_templates_on_game_map_id"
    t.index ["is_active"], name: "index_event_templates_on_is_active"
    t.index ["key"], name: "index_event_templates_on_key", unique: true
    t.index ["learning_category_id"], name: "index_event_templates_on_learning_category_id"
    t.index ["map_zone_id"], name: "index_event_templates_on_map_zone_id"
  end

  create_table "exp_records", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "character_id"
    t.integer "amount", null: false
    t.integer "total_after", null: false
    t.string "source", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_exp_records_on_character_id"
    t.index ["user_id", "created_at"], name: "index_exp_records_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_exp_records_on_user_id"
  end

  create_table "game_maps", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.string "background_url"
    t.integer "width", default: 1000, null: false
    t.integer "height", default: 1000, null: false
    t.integer "unlock_level", default: 1, null: false
    t.integer "spawn_interval_minutes", default: 5, null: false
    t.json "config", default: {}, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_game_maps_on_is_active"
    t.index ["key"], name: "index_game_maps_on_key", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "item_type", null: false
    t.string "rarity", default: "common", null: false
    t.integer "price_coins", default: 0, null: false
    t.integer "price_gems", default: 0, null: false
    t.string "effect_type"
    t.integer "effect_value", default: 0, null: false
    t.string "icon_url"
    t.boolean "is_shop_item", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_shop_item"], name: "index_items_on_is_shop_item"
    t.index ["item_type"], name: "index_items_on_item_type"
  end

  create_table "learning_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "icon_url"
    t.integer "sort_order", default: 0, null: false
    t.string "theme_color", default: "#FFB6C1"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "milestones", default: [], null: false
    t.json "display_config", default: {}, null: false
    t.index ["sort_order"], name: "index_learning_categories_on_sort_order"
  end

  create_table "learning_courses", force: :cascade do |t|
    t.integer "learning_category_id", null: false
    t.string "title", null: false
    t.text "description"
    t.text "content", null: false
    t.integer "course_order", null: false
    t.integer "unlock_level", default: 1, null: false
    t.integer "duration_minutes", default: 5, null: false
    t.integer "reward_exp", default: 20, null: false
    t.integer "reward_coins", default: 30, null: false
    t.integer "skill_points", default: 1, null: false
    t.json "tips", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_category_id", "course_order"], name: "index_courses_on_category_and_order", unique: true
    t.index ["learning_category_id"], name: "index_learning_courses_on_learning_category_id"
  end

  create_table "map_spawn_points", force: :cascade do |t|
    t.integer "game_map_id", null: false
    t.integer "map_zone_id"
    t.string "name"
    t.integer "x", null: false
    t.integer "y", null: false
    t.integer "spawn_weight", default: 100, null: false
    t.boolean "is_random", default: true, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_map_id"], name: "index_map_spawn_points_on_game_map_id"
    t.index ["map_zone_id"], name: "index_map_spawn_points_on_map_zone_id"
  end

  create_table "map_zones", force: :cascade do |t|
    t.integer "game_map_id", null: false
    t.string "name", null: false
    t.string "zone_type", default: "normal", null: false
    t.integer "x_min", default: 0, null: false
    t.integer "y_min", default: 0, null: false
    t.integer "x_max", default: 1000, null: false
    t.integer "y_max", default: 1000, null: false
    t.integer "spawn_weight", default: 100, null: false
    t.json "config", default: {}, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_map_id"], name: "index_map_zones_on_game_map_id"
  end

  create_table "sensor_triggers", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.string "sensor_type", null: false
    t.json "value_range", default: {}, null: false
    t.integer "event_template_id", null: false
    t.integer "game_map_id"
    t.integer "priority", default: 0, null: false
    t.json "config", default: {}, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_template_id"], name: "index_sensor_triggers_on_event_template_id"
    t.index ["game_map_id"], name: "index_sensor_triggers_on_game_map_id"
    t.index ["key"], name: "index_sensor_triggers_on_key", unique: true
    t.index ["sensor_type"], name: "index_sensor_triggers_on_sensor_type"
  end

  create_table "sms_codes", force: :cascade do |t|
    t.string "phone", null: false
    t.string "code", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone", "code"], name: "index_sms_codes_on_phone_and_code"
    t.index ["phone"], name: "index_sms_codes_on_phone"
  end

  create_table "story_chapters", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "chapter_order", null: false
    t.integer "unlock_level", default: 1, null: false
    t.integer "unlock_affection", default: 0, null: false
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_order"], name: "index_story_chapters_on_chapter_order", unique: true
  end

  create_table "story_episodes", force: :cascade do |t|
    t.integer "story_chapter_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.integer "episode_order", null: false
    t.json "dialogues", default: [], null: false
    t.json "choices", default: [], null: false
    t.integer "exp_reward", default: 10, null: false
    t.integer "coins_reward", default: 50, null: false
    t.integer "affection_reward", default: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_chapter_id", "episode_order"], name: "index_episodes_on_chapter_and_order", unique: true
    t.index ["story_chapter_id"], name: "index_story_episodes_on_story_chapter_id"
  end

  create_table "user_achievements", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "achievement_id", null: false
    t.integer "progress", default: 0, null: false
    t.datetime "unlocked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "user_decorations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "decoration_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decoration_id"], name: "index_user_decorations_on_decoration_id"
    t.index ["user_id", "decoration_id"], name: "index_user_decorations_on_user_id_and_decoration_id", unique: true
    t.index ["user_id"], name: "index_user_decorations_on_user_id"
  end

  create_table "user_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_user_items_on_item_id"
    t.index ["user_id", "item_id"], name: "index_user_items_on_user_id_and_item_id", unique: true
    t.index ["user_id"], name: "index_user_items_on_user_id"
  end

  create_table "user_learning_progresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "learning_course_id", null: false
    t.string "status", default: "locked", null: false
    t.integer "skill_level", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_course_id"], name: "index_user_learning_progresses_on_learning_course_id"
    t.index ["user_id", "learning_course_id"], name: "index_learning_progress_on_user_and_course", unique: true
    t.index ["user_id"], name: "index_user_learning_progresses_on_user_id"
  end

  create_table "user_map_events", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "event_template_id", null: false
    t.integer "game_map_id", null: false
    t.integer "map_zone_id"
    t.string "status", default: "pending", null: false
    t.string "trigger_source", default: "explore", null: false
    t.integer "pos_x", null: false
    t.integer "pos_y", null: false
    t.json "event_snapshot", default: {}, null: false
    t.json "rewards_granted", default: {}, null: false
    t.json "result_data", default: {}, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "sensor_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_template_id"], name: "index_user_map_events_on_event_template_id"
    t.index ["game_map_id"], name: "index_user_map_events_on_game_map_id"
    t.index ["map_zone_id"], name: "index_user_map_events_on_map_zone_id"
    t.index ["user_id", "created_at"], name: "index_user_map_events_on_user_id_and_created_at"
    t.index ["user_id", "status"], name: "index_user_map_events_on_user_id_and_status"
    t.index ["user_id"], name: "index_user_map_events_on_user_id"
  end

  create_table "user_map_states", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_map_id", null: false
    t.integer "pos_x", default: 500, null: false
    t.integer "pos_y", default: 500, null: false
    t.datetime "entered_at"
    t.datetime "last_explored_at"
    t.integer "explore_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_map_id"], name: "index_user_map_states_on_game_map_id"
    t.index ["user_id", "game_map_id"], name: "index_user_map_states_on_user_id_and_game_map_id", unique: true
    t.index ["user_id"], name: "index_user_map_states_on_user_id"
  end

  create_table "user_rooms", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "room_name", default: "我的小窝", null: false
    t.string "wallpaper", default: "pink_wall", null: false
    t.string "floor_style", default: "wood_light", null: false
    t.json "layout", default: {}, null: false
    t.integer "comfort", default: 10, null: false
    t.integer "beauty", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_rooms_on_user_id", unique: true
  end

  create_table "user_skill_levels", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "learning_category_id", null: false
    t.integer "level", default: 0, null: false
    t.integer "skill_points", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_category_id"], name: "index_user_skill_levels_on_learning_category_id"
    t.index ["user_id", "learning_category_id"], name: "index_skill_levels_on_user_and_category", unique: true
    t.index ["user_id"], name: "index_user_skill_levels_on_user_id"
  end

  create_table "user_story_progresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "story_episode_id", null: false
    t.string "status", default: "locked", null: false
    t.datetime "completed_at"
    t.string "choice_made"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_episode_id"], name: "index_user_story_progresses_on_story_episode_id"
    t.index ["user_id", "story_episode_id"], name: "index_story_progress_on_user_and_episode", unique: true
    t.index ["user_id"], name: "index_user_story_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "openid", null: false
    t.string "nickname", default: "小仙女"
    t.string "avatar_url"
    t.integer "coins", default: 1000, null: false
    t.integer "gems", default: 50, null: false
    t.integer "login_streak", default: 0, null: false
    t.datetime "last_check_in_at"
    t.boolean "tutorial_completed", default: false, null: false
    t.string "auth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_level", default: 1, null: false
    t.integer "total_exp", default: 0, null: false
    t.string "account"
    t.string "password_digest"
    t.string "phone"
    t.index ["account"], name: "index_users_on_account", unique: true
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["openid"], name: "index_users_on_openid", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  add_foreign_key "care_logs", "characters"
  add_foreign_key "care_logs", "items"
  add_foreign_key "characters", "users"
  add_foreign_key "coin_transactions", "users"
  add_foreign_key "daily_check_ins", "users"
  add_foreign_key "event_templates", "game_maps"
  add_foreign_key "event_templates", "learning_categories"
  add_foreign_key "event_templates", "map_zones"
  add_foreign_key "exp_records", "characters"
  add_foreign_key "exp_records", "users"
  add_foreign_key "learning_courses", "learning_categories"
  add_foreign_key "map_spawn_points", "game_maps"
  add_foreign_key "map_spawn_points", "map_zones"
  add_foreign_key "map_zones", "game_maps"
  add_foreign_key "sensor_triggers", "event_templates"
  add_foreign_key "sensor_triggers", "game_maps"
  add_foreign_key "story_episodes", "story_chapters"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
  add_foreign_key "user_decorations", "decorations"
  add_foreign_key "user_decorations", "users"
  add_foreign_key "user_items", "items"
  add_foreign_key "user_items", "users"
  add_foreign_key "user_learning_progresses", "learning_courses"
  add_foreign_key "user_learning_progresses", "users"
  add_foreign_key "user_map_events", "event_templates"
  add_foreign_key "user_map_events", "game_maps"
  add_foreign_key "user_map_events", "map_zones"
  add_foreign_key "user_map_events", "users"
  add_foreign_key "user_map_states", "game_maps"
  add_foreign_key "user_map_states", "users"
  add_foreign_key "user_rooms", "users"
  add_foreign_key "user_skill_levels", "learning_categories"
  add_foreign_key "user_skill_levels", "users"
  add_foreign_key "user_story_progresses", "story_episodes"
  add_foreign_key "user_story_progresses", "users"
end
