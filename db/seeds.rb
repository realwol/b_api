# frozen_string_literal: true

puts "Seeding game data..."

# ========== 商店物品 ==========
items_data = [
  # 食物
  { name: "草莓蛋糕", description: "香甜软糯的草莓蛋糕，心情瞬间变好~", item_type: "food", rarity: "common",
    price_coins: 50, effect_type: "mood", effect_value: 15, icon_url: "/icons/food/cake.png" },
  { name: "马卡龙礼盒", description: "精致法式甜点，提升魅力值", item_type: "food", rarity: "rare",
    price_coins: 120, effect_type: "charm", effect_value: 3, icon_url: "/icons/food/macaron.png" },
  { name: "奶茶", description: "温暖的珍珠奶茶，恢复体力", item_type: "food", rarity: "common",
    price_coins: 30, effect_type: "energy", effect_value: 20, icon_url: "/icons/food/tea.png" },
  { name: "精致便当", description: "营养均衡的爱心便当", item_type: "food", rarity: "common",
    price_coins: 80, effect_type: "hunger", effect_value: -30, icon_url: "/icons/food/bento.png" },

  # 服装
  { name: "樱花和服", description: "春季限定和服，优雅动人", item_type: "outfit", rarity: "epic",
    price_coins: 500, price_gems: 10, effect_type: "charm", effect_value: 8, icon_url: "/icons/outfit/kimono.png" },
  { name: "洛丽塔洋装", description: "梦幻公主风洋装", item_type: "outfit", rarity: "rare",
    price_coins: 350, effect_type: "charm", effect_value: 5, icon_url: "/icons/outfit/lolita.png" },
  { name: "休闲卫衣", description: "舒适日常穿搭", item_type: "outfit", rarity: "common",
    price_coins: 150, effect_type: "mood", effect_value: 8, icon_url: "/icons/outfit/hoodie.png" },

  # 礼物
  { name: "水晶项链", description: "闪耀的心形水晶项链", item_type: "gift", rarity: "epic",
    price_coins: 800, price_gems: 15, effect_type: "affection", effect_value: 15, icon_url: "/icons/gift/necklace.png" },
  { name: "手工贺卡", description: "亲手写下的温暖祝福", item_type: "gift", rarity: "common",
    price_coins: 20, effect_type: "affection", effect_value: 5, icon_url: "/icons/gift/card.png" },
  { name: "花束", description: "新鲜采摘的玫瑰花束", item_type: "gift", rarity: "common",
    price_coins: 100, effect_type: "affection", effect_value: 8, icon_url: "/icons/gift/flowers.png" },

  # 消耗品
  { name: "智慧之书", description: "阅读提升智力", item_type: "consumable", rarity: "rare",
    price_coins: 200, effect_type: "intelligence", effect_value: 5, icon_url: "/icons/consumable/book.png" },
  { name: "能量饮料", description: "快速恢复全部体力", item_type: "consumable", rarity: "common",
    price_coins: 60, effect_type: "energy", effect_value: 50, icon_url: "/icons/consumable/drink.png" }
]

items_data.each do |data|
  Item.find_or_create_by!(name: data[:name]) do |item|
    item.assign_attributes(data)
  end
end

puts "Created #{Item.count} items"

# ========== 主线剧情 ==========
chapter1 = StoryChapter.find_or_create_by!(chapter_order: 1) do |c|
  c.title = "初遇·命运的邂逅"
  c.description = "在一个普通的午后，你遇见了那个改变一切的少女..."
  c.unlock_level = 1
  c.unlock_affection = 0
  c.cover_url = "/story/ch1_cover.png"
end

chapter1_episodes = [
  {
    title: "午后的阳光",
    episode_order: 1,
    content: "春日的午后，阳光透过樱花树的缝隙洒落在小径上。你偶然路过公园，看到一个女孩独自坐在长椅上，似乎在等待着什么...",
    dialogues: [
      { speaker: "narrator", text: "春日的午后，阳光温柔地洒在大地上。" },
      { speaker: "girl", text: "啊...你也好来这里散步吗？" },
      { speaker: "player", text: "嗯，这里的樱花很美呢。" },
      { speaker: "girl", text: "是呀！我叫小雪，很高兴认识你~" }
    ],
    exp_reward: 15, coins_reward: 50, affection_reward: 5
  },
  {
    title: "一起喝奶茶",
    episode_order: 2,
    content: "小雪邀请你一起去附近的奶茶店。你们聊了很多，你发现她是一个温柔又有点害羞的女孩。",
    dialogues: [
      { speaker: "girl", text: "你喜欢什么口味的奶茶呀？" },
      { speaker: "player", text: "珍珠奶茶吧，你呢？" },
      { speaker: "girl", text: "我最喜欢芋泥波波！下次一起来吧~" }
    ],
    choices: [
      { id: "A", text: "好啊，一言为定！", affection_bonus: 3 },
      { id: "B", text: "下次再说吧...", affection_bonus: 0 }
    ],
    exp_reward: 20, coins_reward: 80, affection_reward: 8
  },
  {
    title: "星空下的约定",
    episode_order: 3,
    content: "傍晚时分，你们一起来到了公园的天台。繁星点点，小雪许下了一个小小的愿望...",
    dialogues: [
      { speaker: "narrator", text: "夜空中繁星闪烁，微风轻拂。" },
      { speaker: "girl", text: "我希望...能一直和你在一起。" },
      { speaker: "girl", text: "你会一直陪着我的，对吗？" }
    ],
    exp_reward: 30, coins_reward: 100, affection_reward: 10
  }
]

chapter1_episodes.each do |data|
  StoryEpisode.find_or_create_by!(story_chapter: chapter1, episode_order: data[:episode_order]) do |ep|
    ep.assign_attributes(data.except(:episode_order))
  end
end

chapter2 = StoryChapter.find_or_create_by!(chapter_order: 2) do |c|
  c.title = "成长·绽放的花季"
  c.description = "随着时间推移，小雪逐渐成长，你们的故事也在继续..."
  c.unlock_level = 5
  c.unlock_affection = 20
  c.cover_url = "/story/ch2_cover.png"
end

chapter2_episodes = [
  {
    title: "新的朋友",
    episode_order: 1,
    content: "小雪进入了新的学校，认识了许多新朋友。但她最期待的还是每天和你在一起的时光。",
    dialogues: [
      { speaker: "girl", text: "今天学校里发生了好多有趣的事！" },
      { speaker: "girl", text: "不过...最想分享的人还是你。" }
    ],
    exp_reward: 25, coins_reward: 80, affection_reward: 8
  },
  {
    title: "才艺表演",
    episode_order: 2,
    content: "学校即将举办才艺表演，小雪想要参加，但缺乏信心。你能帮助她鼓起勇气吗？",
    dialogues: [
      { speaker: "girl", text: "我...我可以做到吗？" },
      { speaker: "player", text: "当然可以！你是最棒的！" },
      { speaker: "girl", text: "有你这句话，我就有勇气了！" }
    ],
    choices: [
      { id: "A", text: "我帮你一起练习", affection_bonus: 5 },
      { id: "B", text: "相信你自己", affection_bonus: 3 }
    ],
    exp_reward: 35, coins_reward: 120, affection_reward: 12
  }
]

chapter2_episodes.each do |data|
  StoryEpisode.find_or_create_by!(story_chapter: chapter2, episode_order: data[:episode_order]) do |ep|
    ep.assign_attributes(data.except(:episode_order))
  end
end

chapter3 = StoryChapter.find_or_create_by!(chapter_order: 3) do |c|
  c.title = "梦想·闪耀的舞台"
  c.description = "小雪的梦想逐渐清晰，而你将成为她最坚实的后盾。"
  c.unlock_level = 15
  c.unlock_affection = 50
  c.cover_url = "/story/ch3_cover.png"
end

chapter3_episodes = [
  {
    title: "梦想的起航",
    episode_order: 1,
    content: "小雪告诉了你她的梦想——成为一名出色的偶像。这个梦想需要你们一起努力。",
    dialogues: [
      { speaker: "girl", text: "我想站在最大的舞台上，让所有人都看到我的光芒！" },
      { speaker: "player", text: "我会一直支持你的。" },
      { speaker: "girl", text: "谢谢你...有你在，我什么都不怕。" }
    ],
    exp_reward: 40, coins_reward: 150, affection_reward: 15
  }
]

chapter3_episodes.each do |data|
  StoryEpisode.find_or_create_by!(story_chapter: chapter3, episode_order: data[:episode_order]) do |ep|
    ep.assign_attributes(data.except(:episode_order))
  end
end

puts "Created #{StoryChapter.count} chapters, #{StoryEpisode.count} episodes"

# ========== 成就系统 ==========
achievements_data = [
  { key: "first_care", title: "初次关怀", description: "第一次照顾角色", category: "care",
    condition_type: "care_count", condition_value: 1, reward_coins: 50, reward_exp: 10, icon_url: "🏅" },
  { key: "care_master", title: "养成达人", description: "累计互动50次", category: "care",
    condition_type: "care_count", condition_value: 50, reward_coins: 300, reward_gems: 5, reward_exp: 50, icon_url: "💝" },
  { key: "story_beginner", title: "故事启程", description: "完成第一个剧情", category: "story",
    condition_type: "story_complete", condition_value: 1, reward_coins: 100, reward_exp: 20, icon_url: "📖" },
  { key: "story_lover", title: "剧情爱好者", description: "完成5个剧情", category: "story",
    condition_type: "story_complete", condition_value: 5, reward_coins: 500, reward_gems: 10, reward_exp: 80, icon_url: "📚" },
  { key: "check_in_3", title: "三日之约", description: "连续签到3天", category: "collection",
    condition_type: "check_in_streak", condition_value: 3, reward_coins: 200, reward_exp: 30, icon_url: "📅" },
  { key: "check_in_7", title: "一周坚持", description: "连续签到7天", category: "collection",
    condition_type: "check_in_streak", condition_value: 7, reward_coins: 500, reward_gems: 15, reward_exp: 100, icon_url: "🌟" },
  { key: "level_5", title: "初露锋芒", description: "玩家等级达到5级", category: "economy",
    condition_type: "user_level", condition_value: 5, reward_coins: 300, reward_exp: 0, icon_url: "⭐" },
  { key: "level_10", title: "成长之星", description: "玩家等级达到10级", category: "economy",
    condition_type: "user_level", condition_value: 10, reward_coins: 800, reward_gems: 20, icon_url: "✨" },
  { key: "learning_first", title: "好学少女", description: "完成第一门课程", category: "learning",
    condition_type: "learning_complete", condition_value: 1, reward_coins: 100, reward_exp: 30, icon_url: "🎓" },
  { key: "skill_level_3", title: "才艺达人", description: "任意技能达到3级", category: "learning",
    condition_type: "skill_level", condition_value: 3, reward_coins: 400, reward_gems: 8, reward_exp: 60, icon_url: "🌸" },
  { key: "decorator", title: "装饰新手", description: "拥有5件装饰", category: "decoration",
    condition_type: "decoration_count", condition_value: 5, reward_coins: 200, reward_exp: 25, icon_url: "🏠" },
  { key: "beautiful_room", title: "梦幻小窝", description: "房间美观度达到50", category: "decoration",
    condition_type: "room_beauty", condition_value: 50, reward_coins: 500, reward_gems: 10, icon_url: "💎" },
  { key: "rich_girl", title: "小有积蓄", description: "累计获得5000金币", category: "economy",
    condition_type: "coins_earned", condition_value: 5000, reward_gems: 30, reward_exp: 50, icon_url: "💰" }
]

achievements_data.each do |data|
  Achievement.find_or_create_by!(key: data[:key]) { |a| a.assign_attributes(data) }
end
puts "Created #{Achievement.count} achievements"

# ========== 学习进阶系统 ==========
categories_data = [
  { name: "时尚穿搭", description: "学习潮流搭配，提升审美与魅力", icon_url: "👗", sort_order: 1, theme_color: "#FFB6C1" },
  { name: "烘焙甜点", description: "制作精美甜点，享受甜蜜时光", icon_url: "🧁", sort_order: 2, theme_color: "#FFDAB9" },
  { name: "花艺茶道", description: "品味生活美学，修身养性", icon_url: "🌸", sort_order: 3, theme_color: "#98FB98" },
  { name: "美妆护肤", description: "掌握护肤技巧，绽放自然美", icon_url: "💄", sort_order: 4, theme_color: "#DDA0DD" },
  { name: "音乐舞蹈", description: "培养艺术气质，展现舞台魅力", icon_url: "🎵", sort_order: 5, theme_color: "#87CEEB" }
]

categories_data.each do |data|
  LearningCategory.find_or_create_by!(name: data[:name]) { |c| c.assign_attributes(data) }
end

courses_data = {
  "时尚穿搭" => [
    { title: "色彩搭配入门", course_order: 1, unlock_level: 1, duration_minutes: 5,
      content: "学习基础色彩理论：暖色调给人温暖亲切感，冷色调则显得优雅高级。同色系搭配最安全，对比色搭配最出彩。",
      tips: ["春夏季适合浅色系", "黑白灰是万能百搭色", "配饰颜色不要超过三种"],
      reward_exp: 25, reward_coins: 40, skill_points: 2 },
    { title: "体型修饰技巧", course_order: 2, unlock_level: 2, duration_minutes: 8,
      content: "了解自己的体型特点，学会用穿搭扬长避短。A字裙修饰下半身，V领拉长颈部线条，腰带提高腰线。",
      tips: ["竖条纹显瘦", "深色系更修身", "层次穿搭增加时尚感"],
      reward_exp: 35, reward_coins: 60, skill_points: 3 },
    { title: "场合穿搭指南", course_order: 3, unlock_level: 4, duration_minutes: 10,
      content: "不同场合需要不同风格：日常休闲选舒适简约，约会穿甜美优雅，正式场合则需要得体大方。",
      tips: ["约会可选连衣裙", "上班以简洁为主", "派对可以大胆尝试"],
      reward_exp: 50, reward_coins: 80, skill_points: 4 }
  ],
  "烘焙甜点" => [
    { title: "Cupcake 基础", course_order: 1, unlock_level: 1, duration_minutes: 6,
      content: "Cupcake 是最适合新手的烘焙入门。掌握基本配方：低筋面粉、糖、鸡蛋、黄油的比例是关键。",
      tips: ["黄油需室温软化", "不要过度搅拌面糊", "烤箱需提前预热"],
      reward_exp: 25, reward_coins: 40, skill_points: 2 },
    { title: "马卡龙制作", course_order: 2, unlock_level: 3, duration_minutes: 12,
      content: "马卡龙被誉为烘焙界的'少女之心'。关键在于蛋白霜的打发和晾皮时间。",
      tips: ["杏仁粉需过筛", "晾皮至不粘手", "夹馅可自由创意"],
      reward_exp: 45, reward_coins: 70, skill_points: 4 }
  ],
  "花艺茶道" => [
    { title: "插花基础", course_order: 1, unlock_level: 1, duration_minutes: 5,
      content: "学习日式插花的基本理念：留白、线条、色彩。三支花即可创造 beautiful 的作品。",
      tips: ["选择当季花材", "修剪多余叶片", "注意高低错落"],
      reward_exp: 20, reward_coins: 35, skill_points: 2 },
    { title: "茶道入门", course_order: 2, unlock_level: 2, duration_minutes: 8,
      content: "茶道不仅是品茶，更是一种生活美学。学习基本礼仪和抹茶冲泡方法。",
      tips: ["水温80度最佳", "抹茶需充分搅拌", "静心品味"],
      reward_exp: 30, reward_coins: 50, skill_points: 3 }
  ],
  "美妆护肤" => [
    { title: "护肤四步骤", course_order: 1, unlock_level: 1, duration_minutes: 5,
      content: "清洁-爽肤-精华-保湿，这是基础护肤四步骤。根据自己的肤质选择合适产品。",
      tips: ["早晚都要护肤", "防晒是关键", "充足睡眠养肤"],
      reward_exp: 20, reward_coins: 35, skill_points: 2 },
    { title: "日常淡妆技巧", course_order: 2, unlock_level: 3, duration_minutes: 10,
      content: "自然淡妆的关键：均匀底妆、自然眉形、淡色唇彩。Less is more！",
      tips: ["妆前乳很重要", "少量多次上妆", "卸妆要彻底"],
      reward_exp: 40, reward_coins: 65, skill_points: 3 }
  ],
  "音乐舞蹈" => [
    { title: "声乐基础", course_order: 1, unlock_level: 1, duration_minutes: 6,
      content: "学习正确的呼吸方法和发声技巧。腹式呼吸是歌唱的基础。",
      tips: ["每天练声15分钟", "多喝水保护嗓子", "从低音开始热身"],
      reward_exp: 25, reward_coins: 40, skill_points: 2 },
    { title: "爵士舞入门", course_order: 2, unlock_level: 2, duration_minutes: 10,
      content: "爵士舞强调身体的律动感和表现力。从基本步伐和手臂动作开始练习。",
      tips: ["热身很重要", "跟着节拍练习", "镜子是最好的老师"],
      reward_exp: 35, reward_coins: 55, skill_points: 3 }
  ]
}

courses_data.each do |cat_name, courses|
  category = LearningCategory.find_by!(name: cat_name)
  courses.each do |data|
    LearningCourse.find_or_create_by!(learning_category: category, course_order: data[:course_order]) do |c|
      c.assign_attributes(data.except(:course_order))
    end
  end
end
puts "Created #{LearningCategory.count} categories, #{LearningCourse.count} courses"

# ========== 房间装饰 ==========
decorations_data = [
  { name: "粉色壁纸", slot_type: "wallpaper", rarity: "common", price_coins: 100,
    comfort_bonus: 5, beauty_bonus: 10, icon_url: "🩷" },
  { name: "星空壁纸", slot_type: "wallpaper", rarity: "rare", price_coins: 250, price_gems: 3,
    comfort_bonus: 8, beauty_bonus: 15, icon_url: "🌌" },
  { name: "木质地板", slot_type: "floor", rarity: "common", price_coins: 80,
    comfort_bonus: 5, beauty_bonus: 5, icon_url: "🪵" },
  { name: "大理石地板", slot_type: "floor", rarity: "rare", price_coins: 200,
    comfort_bonus: 3, beauty_bonus: 12, icon_url: "✨" },
  { name: "公主床", slot_type: "furniture", rarity: "epic", price_coins: 800, price_gems: 10,
    comfort_bonus: 20, beauty_bonus: 25, icon_url: "🛏️" },
  { name: "梳妆台", slot_type: "furniture", rarity: "rare", price_coins: 400,
    comfort_bonus: 10, beauty_bonus: 18, icon_url: "💅" },
  { name: "小沙发", slot_type: "furniture", rarity: "common", price_coins: 300,
    comfort_bonus: 15, beauty_bonus: 10, icon_url: "🛋️" },
  { name: "书架", slot_type: "furniture", rarity: "common", price_coins: 250,
    comfort_bonus: 8, beauty_bonus: 8, icon_url: "📚" },
  { name: "水晶吊灯", slot_type: "lighting", rarity: "epic", price_coins: 600, price_gems: 8,
    comfort_bonus: 5, beauty_bonus: 30, icon_url: "💡" },
  { name: "暖色台灯", slot_type: "lighting", rarity: "common", price_coins: 120,
    comfort_bonus: 10, beauty_bonus: 8, icon_url: "🪔" },
  { name: "泰迪熊", slot_type: "ornament", rarity: "common", price_coins: 80,
    comfort_bonus: 12, beauty_bonus: 8, icon_url: "🧸" },
  { name: "兔耳镜子", slot_type: "ornament", rarity: "rare", price_coins: 180,
    comfort_bonus: 5, beauty_bonus: 15, icon_url: "🪞" },
  { name: "盆栽绿植", slot_type: "plant", rarity: "common", price_coins: 60,
    comfort_bonus: 8, beauty_bonus: 10, icon_url: "🪴" },
  { name: "樱花盆栽", slot_type: "plant", rarity: "rare", price_coins: 200, price_gems: 2,
    comfort_bonus: 10, beauty_bonus: 20, icon_url: "🌸" }
]

decorations_data.each do |data|
  Decoration.find_or_create_by!(name: data[:name]) { |d| d.assign_attributes(data) }
end
puts "Created #{Decoration.count} decorations"

# ========== 虚拟地图 ==========
main_map = GameMap.find_or_create_by!(key: "fantasy_realm") do |m|
  m.name = "幻境仙踪"
  m.description = "一片充满奇遇的虚拟世界，随机事件随时可能出现..."
  m.background_url = "/maps/fantasy_realm.png"
  m.width = 1000
  m.height = 1000
  m.unlock_level = 1
  m.spawn_interval_minutes = 1
  m.is_default = true
  m.is_active = true
  m.config = { "theme" => "fantasy", "bgm" => "peaceful" }
end

zones_data = [
  { name: "樱花林", zone_type: "normal", x_min: 0, y_min: 0, x_max: 400, y_max: 500, spawn_weight: 120 },
  { name: "幽暗洞穴", zone_type: "cave", x_min: 400, y_min: 0, x_max: 700, y_max: 400, spawn_weight: 80 },
  { name: "Battle场", zone_type: "battle", x_min: 600, y_min: 400, x_max: 1000, y_max: 700, spawn_weight: 100 },
  { name: "Secret境", zone_type: "secret", x_min: 0, y_min: 500, x_max: 500, y_max: 1000, spawn_weight: 40 },
  { name: "Cloud顶", zone_type: "mountain", x_min: 500, y_min: 600, x_max: 1000, y_max: 1000, spawn_weight: 60 }
]

zones_data.each do |data|
  MapZone.find_or_create_by!(game_map: main_map, name: data[:name]) { |z| z.assign_attributes(data) }
end

secret_zone = MapZone.find_by!(game_map: main_map, name: "Secret境")
battle_zone = MapZone.find_by!(game_map: main_map, name: "Battle场")

MapSpawnPoint.find_or_create_by!(game_map: main_map, name: "入口") do |p|
  p.x = 200; p.y = 250; p.is_random = false; p.is_active = true
end

# ========== 随机事件模板 ==========
events_data = [
  { key: "slime_battle", name: "史莱姆来袭", event_type: "battle", difficulty: 1,
    description: "一只可爱的史莱姆挡住了去路！", map_zone: battle_zone,
    content: { "enemy" => "史莱姆", "hp" => 50, "dialogues" => [{ "speaker" => "narrator", "text" => "史莱姆跳了跳，似乎不太高兴..." }] },
    rewards_config: { "coins_min" => 20, "coins_max" => 80, "exp_min" => 10, "exp_max" => 30 },
    trigger_weight: 150 },
  { key: "shadow_battle", name: "暗影兽伏击", event_type: "battle", difficulty: 3,
    description: "暗影中窜出了一头魔兽！", map_zone: battle_zone,
    content: { "enemy" => "暗影兽", "hp" => 200, "dialogues" => [{ "speaker" => "narrator", "text" => "小心！它冲过来了！" }] },
    rewards_config: { "coins_min" => 80, "coins_max" => 200, "exp_min" => 30, "exp_max" => 80, "gems_chance" => 0.15, "gems_amount" => 3 },
    trigger_weight: 60, min_user_level: 3 },
  { key: "puzzle_game", name: "神秘拼图", event_type: "mini_game", difficulty: 1,
    description: "发现一个古老的拼图机关",
    content: { "game_type" => "puzzle", "time_limit" => 60, "dialogues" => [{ "speaker" => "narrator", "text" => "试试解开这个谜题吧~" }] },
    rewards_config: { "coins_min" => 30, "coins_max" => 100, "exp_min" => 15, "exp_max" => 40 },
    trigger_weight: 100 },
  { key: "rhythm_game", name: "节奏挑战", event_type: "mini_game", difficulty: 2,
    description: "听到远处传来美妙的旋律...",
    content: { "game_type" => "rhythm", "time_limit" => 45 },
    rewards_config: { "coins_min" => 50, "coins_max" => 120, "exp_min" => 20, "exp_max" => 50 },
    trigger_weight: 80 },
  { key: "hermit_encounter", name: "山中隐士", event_type: "hermit", difficulty: 1,
    description: "一位白发隐士出现在你面前",
    content: { "npc" => "云中隐士", "dialogues" => [
      { "speaker" => "hermit", "text" => "年轻人，我看你根骨奇佳..." },
      { "speaker" => "hermit", "text" => "这本心法赠与你，好生修炼。" }
    ] },
    rewards_config: { "coins_min" => 100, "coins_max" => 200, "exp_min" => 50, "exp_max" => 100 },
    trigger_weight: 40, map_zone: secret_zone },
  { key: "master_sword", name: "剑术高手", event_type: "master", difficulty: 3,
    description: "一位剑术大师愿意指点你",
    content: { "npc" => "剑心大师", "dialogues" => [
      { "speaker" => "master", "text" => "剑之道，在于心。" },
      { "speaker" => "master", "text" => "你的剑意已有小成，继续加油。" }
    ] },
    rewards_config: { "coins_min" => 150, "coins_max" => 300, "exp_min" => 80, "exp_max" => 150, "gems_chance" => 0.2, "gems_amount" => 5 },
    trigger_weight: 30, min_user_level: 5 },
  { key: "heavenly_secret", name: "天机显现", event_type: "heavenly_secret", difficulty: 2,
    description: "天际突现异象，似乎有天机降临",
    content: { "dialogues" => [
      { "speaker" => "narrator", "text" => "天空中出现了一道金色光芒..." },
      { "speaker" => "narrator", "text" => "你感悟到了一丝天机，心境豁然开朗。" }
    ] },
    rewards_config: { "coins_min" => 200, "coins_max" => 500, "exp_min" => 100, "exp_max" => 200, "gems_chance" => 0.3, "gems_amount" => 10 },
    trigger_weight: 20, sensor_triggerable: true },
  { key: "serendipity_flower", name: "花仙奇缘", event_type: "serendipity", difficulty: 1,
    description: "一位花仙向你微笑",
    content: { "npc" => "花仙", "dialogues" => [
      { "speaker" => "fairy", "text" => "这朵灵花送给你~" },
      { "speaker" => "fairy", "text" => "愿美丽与你常伴。" }
    ] },
    rewards_config: { "coins_min" => 80, "coins_max" => 180, "exp_min" => 40, "exp_max" => 80,
                      "items" => (flower = Item.find_by(name: "花束")) ? [{ "item_id" => flower.id, "chance" => 0.5, "quantity" => 1 }] : [] },
    trigger_weight: 50 },
  { key: "treasure_chest", name: "神秘宝箱", event_type: "treasure", difficulty: 1,
    description: "发现了一个闪闪发光的宝箱！",
    content: { "dialogues" => [{ "speaker" => "narrator", "text" => "打开宝箱看看有什么惊喜吧~" }] },
    rewards_config: { "coins_min" => 50, "coins_max" => 300, "exp_min" => 20, "exp_max" => 60,
                      "gems_chance" => 0.25, "gems_amount" => 8 },
    trigger_weight: 90 },
  { key: "wandering_merchant", name: "行脚商人", event_type: "story", difficulty: 1,
    description: "遇到一位神秘的行脚商人",
    content: { "npc" => "行脚商人", "dialogues" => [
      { "speaker" => "merchant", "text" => "小姑娘，要不要看看我的宝贝？" }
    ] },
    rewards_config: { "coins_min" => 30, "coins_max" => 100, "exp_min" => 10, "exp_max" => 25 },
    trigger_weight: 70 }
]

events_data.each do |data|
  zone = data.delete(:map_zone)
  EventTemplate.find_or_create_by!(key: data[:key]) do |t|
    t.assign_attributes(data.except(:key))
    t.game_map = main_map
    t.map_zone = zone
    t.is_active = true
  end
end

# ========== 传感器触发配置 ==========
heavenly = EventTemplate.find_by!(key: "heavenly_secret")
SensorTrigger.find_or_create_by!(key: "motion_detect") do |s|
  s.name = "动作感应触发"
  s.description = "检测到玩家移动时触发天机事件"
  s.sensor_type = "motion"
  s.value_range = { "min" => 0.5, "max" => 999 }
  s.event_template = heavenly
  s.game_map = main_map
  s.priority = 10
  s.is_active = true
end

SensorTrigger.find_or_create_by!(key: "proximity_near") do |s|
  s.name = "接近感应"
  s.description = "接近传感器触发"
  s.sensor_type = "proximity"
  s.value_range = { "min" => 0, "max" => 30 }
  s.event_template = EventTemplate.find_by!(key: "treasure_chest")
  s.game_map = main_map
  s.priority = 5
  s.is_active = true
end

# ========== 技能里程碑配置 ==========
LearningCategory.find_each do |cat|
  cat.update!(milestones: [
    { "level" => 1, "title" => "初窥门径", "description" => "#{cat.name}达到1级", "reward" => { "coins" => 50 } },
    { "level" => 3, "title" => "小有所成", "description" => "#{cat.name}达到3级", "reward" => { "coins" => 150, "gems" => 3 } },
    { "level" => 5, "title" => "融会贯通", "description" => "#{cat.name}达到5级", "reward" => { "coins" => 300, "gems" => 5 } },
    { "level" => 10, "title" => "一代宗师", "description" => "#{cat.name}达到10级", "reward" => { "coins" => 800, "gems" => 15 } }
  ], display_config: { "badge_color" => cat.theme_color, "show_rank" => true })
end

puts "Created map: #{main_map.name}, #{MapZone.count} zones, #{EventTemplate.count} events, #{SensorTrigger.count} sensors"
puts "Seed completed!"
