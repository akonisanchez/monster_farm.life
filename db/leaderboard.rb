# Clear existing test data
if Rails.env.development?
  User.destroy_all
  Monster.destroy_all
end

# Create sample users and monsters
users_monsters = [
  { username: 'PowerPro', monster: { name: 'Chocobat', power: 800, speed: 400 }},
  { username: 'SpeedKing', monster: { name: 'Shinka', power: 300, speed: 850 }},
  { username: 'TankMaster', monster: { name: 'Flopower', defense: 750, health: 500 }},
  { username: 'BalancedOne', monster: { name: 'Galoot', power: 400, speed: 400, defense: 400, health: 400 }},
  { username: 'YogaGuru', monster: { name: 'Enoki', health: 900 }}
]

users_monsters.each do |data|
  user = User.create!(
    username: data[:username],
    password: 'password123',
    password_confirmation: 'password123'
  )
  
  user.create_monster!(
    data[:monster].merge(
      power: data[:monster][:power] || 1,
      speed: data[:monster][:speed] || 1,
      defense: data[:monster][:defense] || 1,
      health: data[:monster][:health] || 1,
      tiredness: 0
    )
  )
end