local fruit = require("app.views.FruitItem")
local PlayScene = class("PlayScene",cc.load("mvc").ViewBase)

local size = cc.Director:getInstance():getWinSize();



-- math.newrandomseed();
function PlayScene:ctor()
	self.highScore=0;
	self.stage=1;
	self.target=123;
	self.curScore=0;

	self.xCount =8;
	self.yCount =8;
	self.fruitGap =0;

	self.scoreStart =5 -- 水果基分
	self.scoreStep =10 -- 加成分数
	self.activeScore=0 -- 当前高亮水果得分

	self:initUI();

	--c初始化 糖果落下 左下角坐标
	self.matrixLBX =(size.width - fruit.getWidth()*self.xCount - (self.xCount -1)*self.fruitGap )/2;
	self.matrixLBY =(size.height - fruit.getWidth()*self.yCount - (self.yCount -1)*self.fruitGap )/2 -80;


    --cocos果然很坑爹 要这样才能监听转场事件 日了狗了 = =!!
	self:registerScriptHandler(function (eventType)
		--print("当前事件类型----->"..eventType)
		if(eventType == "enterTransitionFinish") then
			print("转场完毕")
			self:initMatrix()
		end
		end)

	-- 处理触屏事件函数

	local function onToucheBegan(touch,event)
		print("触发了touchBegin事件")
		return true
	end
	-- 函数命名不能为onTouchEnded 可能与其内部回调函数重名 注意！！！
	local function onTouchEnd(touch,event)
		local target = event:getCurrentTarget()
		print("触发了touchEnd事件")
		local  pos = touch:getLocation()
		local px = math.floor((pos.x - self.matrixLBX)/(fruit.getWidth()+self.fruitGap))+1
		local py = math.floor((pos.y - self.matrixLBY)/(fruit.getWidth()+self.fruitGap))+1
		--print("点击的位置----->",px.."------"..py)
		target = self.matrix[(py - 1)*self.xCount + px]
		--print("点击对象为",target.name)
		if target.isActive then
			--清除高亮 并落下水果
			print("清除")
			self:removeActivedFruit()
			self:dropFruits()
		else
			print("点击水果------->",target.name)
			self:inactive() --清除高亮水果
			self:activeNeighbor(target) --以水果为中心，高亮周围水果
			self:showActivesScore() --计算高亮区域水果
		end
	end
	local function onTouchMoved(touch,event)
		print("触发了touchMove事件")
			--print(event.getCurrentTarget())
	end
	--注册事件
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	--print("事件-----》"..cc.Handler.EVENT_TOUCH_BEGAN..cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(onToucheBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
	--handler(self,self.onTouchEnd)
	listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	--print("监听对象------>",newFruit.name)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
	--handler(self,self.onTouchEnd)
end


-- 创建水果 并赋予坐标 这个函数名取的真low
function PlayScene:initMatrix()
	-- body
	self.matrix = { }
	--高亮的水果
	self.actives={ }
	for y=1,self.yCount do
		for x=1,self.xCount do
			if 1== y and 2==x then
				self:createAndDropFruit(x,y,self.matrix[1].fruitIndex)
			else
				self:createAndDropFruit(x,y)
			end
		end
	end
end

-- 分数特效
function PlayScene:scorePopEffect(score,px,py)
	-- body
	print("分数特效")
	local labelScore = cc.Label:createWithBMFont("font/earth32.fnt",tostring(score))
	local  move = cc.MoveBy:create(0.8,cc.p(0,80))
	local fadeOut = cc.FadeOut:create(0.8)
	local action = cc.Spawn:create(move,fadeOut)
	action = cc.Sequence:create(action,cc.CallFunc:create(function()
		labelScore:removeFromParent()
		end))
	labelScore:setPosition(px,py)
	:addTo(self)
	:runAction(action)
end

function PlayScene:removeActivedFruit()
	-- body
  local fruitScore = self.scoreStart 
  for _,fruit in pairs(self.actives) do
  	print("取消-----",fruit.name)
  	if(fruit)then
  		self.matrix[(fruit.y -1)*self.xCount + fruit.x]= nil
  		self:scorePopEffect(fruitScore,fruit:getPosition())
  		fruitScore = fruitScore + self.scoreStep
  		fruit:removeFromParent()
  		fruit= nil
  	end
  end
  self.actives={ }
  self.curScore = self.curScore+self.activeScore
  self.curScoreLabel:setString(tostring(self.curScore))
  self.activeScoreLabel:setString("")
  self.activeScore=0
end

--掉落水果
function PlayScene:dropFruits()
	-- body
	local emptyInfo={ }
	for x = 1,self.xCount do
		local removeCounts = 0
		local newY = 0
		for y =1,self.yCount do
			local tmpFruit = self.matrix[(y - 1)*self.xCount+x]
			if(nil == tmpFruit) then 
				removeCounts = removeCounts+1
			else
				if(removeCounts>0)then 
					newY = y - removeCounts
					self.matrix[(newY - 1) * self.xCount+x] = tmpFruit
					tmpFruit.y = newY
					self.matrix[(y - 1)  *   self.xCount+x] = nil 
					--添加落下动画
					local endPos = self:positionOfFruit(x,newY)
					local speed = (tmpFruit:getPositionY() - endPos.y)/size.height 
					tmpFruit:runAction(cc.MoveTo:create(speed,endPos))
				end
			end 
		end
		emptyInfo[x] = removeCounts
		--print("落下水果后0-------->",#self.matrix)

	end
	for i=1,self.xCount do
		for j = self.yCount - emptyInfo[i] + 1,self.yCount do 
			self:createAndDropFruit(i,j)
		end 
	end 
	--print("落下水果后1-------->",#self.matrix)
end
-- 清除高亮水果
function PlayScene:inactive()
	--print("清除高亮水果")
	for _,fruit in pairs(self.actives) do
		--print("水果---",fruit.name,(fruit~=nil))
		if(fruit ~= nil)then
			fruit:setActived (false)
		end
	end
	self.actives={ }
end
--递归高亮周围 水果
function PlayScene:activeNeighbor(fruit)
	print("查找相同水果并高亮",fruit.x,fruit.y,table.getn(self.matrix))
	-- body
	if false == fruit.isActive or nil == fruit.isActive then
		fruit:setActived (true)
		table.insert(self.actives,fruit)
	end
	if(fruit.x - 1 >=1) then
		local leftNeighbor = self.matrix[(fruit.y -1)*self.xCount + fruit.x - 1 ]
		-- print("******",fruit.x.."   "..fruit.y.."    "..fruit.name)
		-- print("左边",(fruit.y -1)*self.xCount , fruit.x - 1,leftNeighbor.isActive,leftNeighbor.fruitIndex,fruit.fruitIndex)
		if(false == leftNeighbor.isActive) and(leftNeighbor.fruitIndex == fruit.fruitIndex) then
                print("左边一样")
			 leftNeighbor:setActived (true)
			 table.insert(self.actives,leftNeighbor)
		 	self:activeNeighbor(leftNeighbor)
		end
	end

	if(fruit.x + 1 <= self.xCount) then
		local rightNeighbor = self.matrix[(fruit.y -1)*self.xCount + fruit.x + 1 ]
		if(false == rightNeighbor.isActive) and(rightNeighbor.fruitIndex == fruit.fruitIndex) then
			  print("右边一样")
			 rightNeighbor:setActived (true)
			 table.insert(self.actives,rightNeighbor)
		 	self:activeNeighbor(rightNeighbor)
		end
	end

	if(fruit.y+ 1 <= self.yCount) then
		local upNeighbor = self.matrix[(fruit.y)*self.xCount + fruit.x]
		if(false == upNeighbor.isActive) and(upNeighbor.fruitIndex == fruit.fruitIndex) then
			  print("上面一样")
			 upNeighbor:setActived (true)
			 table.insert(self.actives,upNeighbor)
		 	self:activeNeighbor(upNeighbor)
		end
	end 

	if(fruit.y - 1 >=1) then
		local downNeighbor = self.matrix[(fruit.y -2)*self.xCount + fruit.x]
		if(false == downNeighbor.isActive) and(downNeighbor.fruitIndex == fruit.fruitIndex) then
			   print("下面一样")
			 downNeighbor:setActived (true)
			 table.insert(self.actives,downNeighbor)
		 	self:activeNeighbor(downNeighbor)
		end
	end 
end

--显示得分
function PlayScene:showActivesScore()
	print("选中"..#self.actives.."个水果")
	if 1 == # self.actives then
		self:inactive()
		self.activeScoreLabel:setString("")
		self.activeScore=0
		return
	end 
	--print((self.scoreStart *2).."-----"..self.scoreStep*(#self.actives-1))
	self.activeScore = (self.scoreStart *2 + self.scoreStep * (#self.actives -1))* #self.actives/2
	self.activeScoreLabel:setString(string.format("%d 连消，得分 %d",#self.actives,self.activeScore))
end

function PlayScene:createAndDropFruit(x,y,index)

	-- body
	local newFruit = fruit.new(x,y,index)
	--print("产生水果----------->",newFruit.x,newFruit.y,newFruit.name)
	local endPos = self:positionOfFruit(x,y)
	local startPos =cc.p(endPos.x,endPos.y + display.height/2)
	newFruit:setPosition(startPos)
	local speed = startPos.y/(2*display.height)
	newFruit:runAction(cc.MoveTo:create(speed,endPos))
	self.matrix[(y-1)*self.xCount +x]=newFruit
	self:addChild(newFruit)
	--newFruit:addTouchEventListener(callBack)
	---print("创建水果-------",self.witdth,self.height)
	--print("添加的水果---",newFruit.name.."  "..newFruit.x.."  "..newFruit.y)
	-- touch事件需要注册	
end

function PlayScene:positionOfFruit(x,y)
local px = self.matrixLBX + (fruit.getWidth() + self.fruitGap) * (x-1)+fruit.getWidth()/2
local py = self.matrixLBY + (fruit.getWidth() + self.fruitGap) * (y-1)+fruit.getWidth()/2
--print("计算出坐标---->"..px.."--------"..py)
return cc.p(px,py)
end

function PlayScene:initUI()
display.newSprite("playBG.png")
:move(display.cx,display.cy)
:addTo(self);

--display.newSprite(cc.SpriteFrameCache.getSpriteFrame())
display.newSprite("#high_score.png")
:align(display.LEFT_CENTER,display.left+15,display.top-30)
:addTo(self);

display.newSprite("#highscore_part.png")
:align(display.LEFT_CENTER,display.cx+10,display.top-26)
:addTo(self);

self.highScoreLabel = cc.Label:createWithBMFont("font/earth38.fnt",tostring(self.highScore))
:align(display.CENTER,display.cx+105,display.top-24)
:addTo(self);

display.newSprite("#sound.png")
:align(display.center,display.right - 60,display.top-30)
:addTo(self);

display.newSprite("#stage.png")
:align(display.LEFT_CENTER,display.left+15,display.top-80)
:addTo(self);
display.newSprite("#stage_part.png")
:align(display.LEFT_CENTER,display.left+170,display.top-80)
:addTo(self);

self.highStageLabel = cc.Label:createWithBMFont("font/earth32.fnt",tostring(self.stage))
:align(display.CENTER,display.left+214,display.top-78)
:addTo(self);

display.newSprite("#tarcet.png")
:align(display.LEFT_CENTER,display.cx-50,display.top-80)
:addTo(self);

display.newSprite("#tarcet_part.png")
:align(display.LEFT_CENTER,display.cx+130,display.top-78)
:addTo(self);

self.highTargetLabel = cc.Label:createWithBMFont("font/earth32.fnt",tostring(self.target))
:align(display.CENTER,display.cx+195,display.top-76)
:addTo(self)

display.newSprite("#score_now.png")
:align(display.CENTER,display.cx,display.top-150)
:addTo(self);

self.curScoreLabel = cc.Label:createWithBMFont("font/earth48.fnt",tostring(self.curScore))
:align(display.CENTER,display.cx,display.top-150)
:addTo(self)

self.activeScoreLabel = cc.Label:createWithSystemFont("123",display.DEFAULT_TTF_FONT,30)
self.activeScoreLabel:setPosition(size.width/2,40)
self.activeScoreLabel:addTo(self)
end

function PlayScene:onCreate()

end


return PlayScene