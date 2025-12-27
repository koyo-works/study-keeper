activities = [
  { name: "勉強する", icon: "📚" },
  { name: "SNSを見る", icon: "📱" },
  { name: "動画を見る", icon: "🎥" },
  { name: "ゲームをする", icon: "🎮" },
  { name: "休憩する", icon: "☕" }
]

activities.each do |activity|
  Activity.find_or_create_by!(name: activity[:name]) do |a|
    a.icon = activity[:icon]
  end
end

puts "Activities seeded!"
