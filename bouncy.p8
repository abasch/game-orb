pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()

 bc = 0

 balls = {}
 sparks = {}
 
 blts = {}
 bpool = {}
 
 p = p(1,1,2,4)
	cur_ball =	make_ball(rnd(100),rnd(100),8,8)
 
end

function _update()
	
	create_ball()
	
	p.update()
	
	update_balls()
	
	update_bullets()	
	
	update_sparks()
	
end

function _draw()
	cls()
	print("balls: " .. tostr(bc) .. " health: " .. tostr(p.health) .. " ammo: " .. tostr(p.gun.ammo_cnt))
	
	p.draw()
	
	for b in all (balls) do
		b.draw()
	end
	
	for b in all (blts) do
		b.draw()
	end
	
	for s in all (sparks) do
		if s.alive then
			s.draw()
		end
	end
	
end

function create_ball()
	if (btnp(🅾️))then
		cur_ball =	make_ball(rnd(100),rnd(100),8,8)
		if collides(p,cur_ball) then
			cur_ball.x -= p.w*2
			cur_ball.y -= p.h*2
		end
	end
end

function update_balls()
	for b in all (balls) do
		if (not b.alive) then
			make_spark(b.x,b.y)
			del(balls, b)
			bc-=1
		end
end

	for b in all (balls) do
		if collides(p,b) then
			p.take_dmg(b)
		end
		b.update()
	end	
end

function update_bullets()
		for b in all (blts) do
		b.update()
	end	
	
	for b in all (blts) do
		for ball in all (balls) do
			if collides(b,ball) then
				split(ball)
				ball.kill()
				b.kill()
				return
			end
		end
	end
end

function update_sparks()
	for s in all (sparks) do
			s.update()
	end
end
-->8
function make_ball(x,y,w,h)

	local o = {}
	
		o.init = function()
		bc+=1
		o.alive = true
		o.null = false
		o.t = 0
 	o.x = x
 	o.y = y
 	o.w = w
 	o.h = h
		o.dx = flr(rnd(2)) == 1 and 1 or -1
		o.dy = flr(rnd(2)) == 1 and 1 or -1
		o.clr = 7
		o.hb = {}
		o.hb.x = x/2
		o.hb.y = y/2
		o.hb.w = w*2
		o.hb.h = h*2
	end
	
	o.kill = function()
		o.alive = false
	end

	o.update = function()
		o.t += 1
		
		if (o.x > 128 or o.x < 0) then
			o.dx *= -1
		end
		if (o.y > 128 or o.y < 0) then
			o.dy *= -1
		end
		
		-- coords
		o.x += o.dx
		o.y += o.dy

		-- hitbox coords
		o.hb.x = o.x - o.w
		o.hb.y = o.y - o.h
		
	end

	o.draw = function()
		--rect(o.hb.x,o.hb.y,o.hb.w+o.hb.x,o.hb.h+o.hb.y,o.clr)
		circ(o.x,o.y,o.w,o.clr)
	end
	add(balls,o)
	bc+=1
	o.init()
	return o
	
end

function split(b)
	if (b.w <= 4)then return end
	local b1 = make_ball(b.x,b.y,b.w-4,b.h-4)
	local b2 =	make_ball(b.x,b.y,b.w-4,b.h-4)
	b1.dx = -b.dx
	b2.dy = -b.dy
	b1.x += 10
	b2.x -= 10
end

function make_spark(x,y)

	local o = {}
	add(sparks,o)
	
	o.alive=true
	o.col = 10
	o.t = 0
	o.x1 = x
	o.y1 = y
	o.x2 = x
	o.y2 = y
	
	o.update = function()
		if (not o.alive) return
		if (o.t > 15)then
			o.alive = false
		end
		o.t+=1
		local spd = flr(o.t % 2) == 0 and 1.5  or 4
		o.x1 -= spd
		o.x2 += spd
		o.y1 += spd
		o.y2 -= spd
	end
	
	o.draw = function()
		pset(o.x1,o.y1,o.col)
		pset(o.x2,o.y1,o.col)
		pset(o.x1,o.y2,o.col)
		pset(o.x2,o.y2,o.col)
	end
	
	return 0
end
-->8
function collides(a,b)
	local a1 = a.x > b.hb.x + b.hb.w
	local a2 = a.x + a.w < b.hb.x
	local a3 = a.y > b.hb.y + b.hb.h
	local a4 = a.y + a.h < b.hb.y
	return not (a1 or a2 or a3 or a4)
end


function blt(x,y,w,h)
	local o = {}
	o.alive = false
	o.speed = 4
	o.dctx = 1
	o.dcty = 1
	o.x = x
	o.y = y
	o.w = w
	o.h = h
	o.t = 0
	o.clr = 14
	
	o.update = function()
		if not o.alive then
			return
	 end
		o.t += 1
		o.x += (1 * o.dctx) * o.speed
		o.y += (1 * o.dcty) * o.speed
		
		if (o.x > 128 + o.w or o.x < 0 or o.y > 128 or o.y < 0) then
			o.kill()
		end
		
	end
		
	o.kill = function()
			o.alive = false
			o.t = 0
			add(bpool,o)
			del(blts,o)		
	end
	
	
	o.draw = function()
		if not o.alive then
		--	return
	 end
		rectfill(o.x,o.y,o.x + o.w,o.y +o.h)
	end
	
	return o
	
end

function gun()
	local o = {}
	o.ammo_cnt = 30
	b_cpy = 3
	for i = 1,b_cpy do
		add (bpool, blt(0,0,1,1) )
	end
	o.fire = function(x,y,dctx,dcty)
		if o.ammo_cnt <= 0 then return end
		o.ammo_cnt -= 1
		if #bpool == 0 then return end
		local b = bpool[1]
		b.x = x
		b.y = y
		b.dctx = dctx
		b.dcty = dcty
		b.alive = true
		del(bpool,b)
		add(blts,b)
	end
	return o
end

function p(x,y,w,h)
	local o = {}
	o.alive = true
	o.x = x
	o.y = y
	o.w = w
	o.h = h
	o.t = 0
	o.s = 1
	o.inv = {inv=false,dur=30,t=0}
	o.health = 3
	o.dctx = 1
	o.dcty = 1
	o.clr = 14
	o.gun = gun()
	o.update = function()
		
		o.t+=1
		
		if (o.health <= 0) o.kill()

		if o.inv.inv then
			o.inv.t += 1
			o.clr = rnd(13)+1
			if o.inv.t > o.inv.dur then
				o.inv.t = 0
				o.inv.inv = false
			end
		end
		
		if btn(⬅️) then
		 o.x-=1
		 o.dctx = -1
		 o.dcty = 0
		end
		if btn(➡️) then
		 o.x+=1
		 o.dctx = 1
		 o.dcty = 0
		 end
		if btn(⬆️) then
		 o.y-=1
		 o.dcty = -1
		 o.dctx = 0
		 end
		if btn(⬇️) then
		 o.y+=1
		 o.dcty = 1
		 o.dctx = 0
		end
		if btnp(❎) and not o.inv.inv then
			o.gun.fire(o.x,o.y,o.dctx,o.dcty)
		end
	end
	o.draw = function()
		rectfill(o.x,o.y,o.x + o.w,o.y +o.h,o.clr)
		spr(o.s,o.x,o.y,1,1,o.dctx == 1)
	end
	
	o.take_dmg = function(hostile)
		if not o.inv.inv then
				o.health -= 1
				o.inv.inv = true
		end
	end
	
	o.kill = function()
		o.alive = false
		-- todo
	end

	return o
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007000070070000700700007000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070070000700700000700700007007000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007770070077700000777700007777000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077770700777707700077000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777700077777000777700007777000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070070700007070000700700007000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
