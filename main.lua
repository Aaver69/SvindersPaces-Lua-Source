-- Variables init --
love.graphics.setDefaultFilter('nearest', 'nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('/sprite/enemy.png')
particle_systems = {}
particle_systems.list = {}
particle_systems.img = love.graphics.newImage('/sprite/particles.png')
score = 0
-- Particle system --
function particle_systems:spawn(x, y)
  local ps = {}
  ps.x = x
  ps.y = y
  ps.ps = love.graphics.newParticleSystem(particle_systems.img, 32)
  ps.ps:setParticleLifetime(2, 4)
  ps.ps:setEmissionRate(5)
  ps.ps:setSizeVariation(1)
  ps.ps:setLinearAcceleration(-20, -20, 20, 20)
  ps.ps:setColors(100, 255, 100, 255, 0, 255, 0, 255)
  table.insert(particle_systems.list, ps)
end

function particle_systems:draw()
  for _, v in pairs(particle_systems.list) do
    love.graphics.draw(v.ps, v.x, v.y)
  end
end

function particle_systems:update(dt)
  for _, v in pairs(particle_systems.list) do
    v.ps:update(dt)
  end
end
-- Basic collisions handler here --
function checkCollisions(enemies, bullets)
  for i, e in ipairs(enemies) do
    for _, b in pairs(bullets) do
      if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
        particle_systems:spawn(e.x, e.y)
        table.remove(enemies, i)
        score = score + 10
      end
    end
  end
end

function love.load()
  -- Will load all the asset you need --
  local music = love.audio.newSource('music/background_music.mp3')
  music:setLooping(true)
  love.audio.play(music)
  game_over = false
  game_win = false
  background_image = love.graphics.newImage('sprite/background.jpg')
  -- Player Object --
  player = {}
  player.x = 0
  player.y = 110
  player.bullets = {}
  player.cooldown = 20
  player.speed = 2
  player.image = love.graphics.newImage('sprite/ship.png')
  player.fire_sound = love.audio.newSource('music/shoot.wav')
  player.fire = function()
    if player.cooldown <= 0 then
      love.audio.play(player.fire_sound)
      player.cooldown = 20
      bullet = {}
      bullet.x = player.x + 4
      bullet.y = player.y + 4
      table.insert(player.bullets, bullet)
    end
  end

  for i=0, 10 do
    enemies_controller:spawnEnemy(i * 15, 0)
  end
end

function enemies_controller:spawnEnemy(x, y)
  -- Enemy Object --
  enemy = {}
  enemy.x = x
  enemy.y = y
  enemy.width = 10
  enemy.height = 10
  enemy.bullets = {}
  enemy.cooldown = 20
  enemy.speed = .1
  table.insert(self.enemies, enemy)
end

function enemy:fire()
  if self.cooldown <= 0 then
    self.cooldown = 20
    bullet = {}
    bullet.x = self.x + 35
    bullet.y = self.y
    table.insert(self.bullets, bullet)
  end
end

function love.update(dt)
  particle_systems:update(dt)
  player.cooldown = player.cooldown - 1
-- Will manage the movement of the ship (left/right)
  if love.keyboard.isDown("right") then
    player.x = player.x + player.speed
  elseif love.keyboard.isDown("left") then
    player.x = player.x - player.speed
  end
-- If space is pressed, will SHOT FIRE --
  if love.keyboard.isDown("space") then
    player.fire()
  end
-- If there is not enmies remaining, you have won --
  if #enemies_controller.enemies == 0 then
    -- we win!! --
    game_win = true
  end
-- Game Over if the aliens reach the bottom --
  for _,e in pairs(enemies_controller.enemies) do
    if e.y >= love.graphics.getHeight()/4 then
      game_over = true
    end
    e.y = e.y + 1 * e.speed
  end
  -- Manage the range of the bullet --
  for i,b in ipairs(player.bullets) do
    if b.y < -10 then
      table.remove(player.bullets, i)
    end
    b.y = b.y - 2
  end
  checkCollisions(enemies_controller.enemies, player.bullets)
end

function love.draw()
  -- Will handle all the graphic part --
  love.graphics.draw(background_image)
  -- Display the score --
  love.graphics.print("SCORE: " .. tostring(score), 715, 580)
  love.graphics.scale(5)
  if game_over then
    love.graphics.print("Game Over!")
    return
  elseif game_win then
    love.graphics.print("You Won!" )
    -- No return here to get 'You Won' into space ! --
  end

  particle_systems:draw()
  -- draw the player --
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(player.image, player.x, player.y)
  for _,e in pairs(enemies_controller.enemies) do
    love.graphics.draw(enemies_controller.image, e.x, e.y, 0)
  end
  -- draw bullets --
  love.graphics.setColor(255, 255, 255)
  for _,b in pairs(player.bullets) do
    love.graphics.rectangle("fill", b.x, b.y, 2, 2)
  end
end
