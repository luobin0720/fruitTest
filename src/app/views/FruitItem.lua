local FruitItem = class("FruitItem",
	function ()
		return display.newSprite("#fruit1_1.png");
	end
 )
function  FruitItem:ctor(x,y,fruitIndex)
		self.fruitIndex = fruitIndex or math.round(math.random()*1000) % 8 +1
		--local mySprite = display.newSprite("#fruit"..fruitIndex.."_1.png");
		self:setSpriteFrame(display.newSpriteFrame("fruit"..self.fruitIndex.."_1.png"))
		self.x = x;
		self.y = y;
		self.isActive = false
		self.name="i am fruit"..x..y
		print("构造----",self.isActive)
	-- body
end

function FruitItem:setActived(active)
	
	self.isActive = active
	--print("设置水果是否高亮---->",active)
	local frame
	if active then 
		frame = display.newSpriteFrame("fruit"..self.fruitIndex.."_2.png")
	else 
		frame = display.newSpriteFrame("fruit"..self.fruitIndex.."_1.png")
	end
	self:setSpriteFrame(frame)

	if(active) then
		self:stopAllActions()
		local to1 = cc.ScaleTo:create(0.1,1.1)
		local to2 = cc.ScaleTo:create(0.05,1.0)
		self:runAction(cc.Sequence:create(to1,to2))
		-- body
	end
end

-- 静态方法返回的要是静态变量
function FruitItem.getWidth()
	FruitItem.g_fruitWidth = 0;
	if(0== FruitItem.g_fruitWidth) then 
		local mySprite  = display.newSprite("#fruit1_1.png")
		FruitItem.g_fruitWidth = mySprite:getContentSize().width 
	end 
	return FruitItem.g_fruitWidth
end

return FruitItem