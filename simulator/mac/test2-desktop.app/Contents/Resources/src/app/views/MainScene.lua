
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "MainScene.csb"


-- 函数定义要在调用之前，否则报错 NND!!!
local function onChangScenes(sender)
print("游戏开始咯！~~~");
local scene = cc.Scene:create();
scene:addChild(require("app.views.PlayScene"):new());
display.runScene(scene)
print(type(scene));
end


function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
display.loadSpriteFrames("fruit.plist","fruit.png");
local bg =display.newSprite("mainBG.png");
bg:move(display.cx,display.cy);
bg:addTo(self);

local btn = ccui.Button:create();
btn:loadTextures("startBtn_N.png","startBtn_S.png","",ccui.TextureResType.plistType);
--print("----麻蛋的坐标---------->");
btn:setPosition(display.cx,display.cy-80);
btn:addTo(self);
btn:addClickEventListener(onChangScenes);

--print("6666666666666666666666666");
--[[ you can create scene with following comment code instead of using csb file.
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    ]]
end



return MainScene
