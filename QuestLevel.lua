----------------------------------------------------------------------------
-- "DTweaks" 애드온에서 퀘스트 레벨을 출력하는 부분만 가져옴 2017-11-01 (수)
-- https://wow.curseforge.com/projects/dtweaks
----------------------------------------------------------------------------
--[[
function GossipFrameUpdate_hook()
    local buttonIndex = 1

    -- name, level, isTrivial, isDaily, isRepeatable, isLegendary, isIgnored, ... = GetGossipAvailableQuests()
    local availableQuests = {GetGossipAvailableQuests()}
    local numAvailableQuests = table.getn(availableQuests)

    for i=1, numAvailableQuests, 7 do
        local titleButton = _G["GossipTitleButton" .. buttonIndex]
        local title = "["..availableQuests[i+1].."] "..availableQuests[i]
        local isTrivial = availableQuests[i+2]

        if isTrivial then
            titleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, title)
        else
            titleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, title)
        end

        GossipResize(titleButton)
        buttonIndex = buttonIndex + 1
    end

    if numAvailableQuests > 1 then
        buttonIndex = buttonIndex + 1
    end

    -- name, level, isTrivial, isDaily, isLegendary, isIgnored, ... = GetGossipActiveQuests()
    local activeQuests = {GetGossipActiveQuests()}
    local numActiveQuests = table.getn(activeQuests)

    for i=1, numActiveQuests, 6 do
        local titleButton = _G["GossipTitleButton" .. buttonIndex]
        local title = "["..activeQuests[i+1].."] "..activeQuests[i]
        local isTrivial = activeQuests[i+2]

        if isTrivial then
            titleButton:SetFormattedText(TRIVIAL_QUEST_DISPLAY, title)
        else
            titleButton:SetFormattedText(NORMAL_QUEST_DISPLAY, title)
        end

        GossipResize(titleButton)
        buttonIndex = buttonIndex + 1
    end
end
hooksecurefunc("GossipFrameUpdate", GossipFrameUpdate_hook)
]]


function SetBlockHeader_hook()
    for i = 1, GetNumQuestWatches() do
        local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i)

        if (not questID) then
            break
        end

        local oldBlock = QUEST_TRACKER_MODULE:GetExistingBlock(questID)

        if oldBlock then
            local oldBlockHeight = oldBlock.height
            local oldHeight = QUEST_TRACKER_MODULE:SetStringText(oldBlock.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"])
            local newTitle = "["..select(2, GetQuestLogTitle(questLogIndex)).."] "..title
            local newHeight = QUEST_TRACKER_MODULE:SetStringText(oldBlock.HeaderText, newTitle, nil, OBJECTIVE_TRACKER_COLOR["Header"])
            oldBlock:SetHeight(oldBlockHeight + newHeight - oldHeight);
        end
    end
end

hooksecurefunc(QUEST_TRACKER_MODULE, "Update", SetBlockHeader_hook)


function QuestLogQuests_hook(self, poiTable)
    local numEntries, numQuests = GetNumQuestLogEntries()
    local headerCollapsed = false
    local titleIndex = 0

    for questLogIndex = 1, numEntries do
        local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(questLogIndex)

        if (isHeader) then
            headerCollapsed = isCollapsed
        elseif not isTask and (not isBounty or IsQuestComplete(questID)) and not headerCollapsed then
            titleIndex = titleIndex + 1
            local button = QuestLogQuests_GetTitleButton(titleIndex)
            local buttonText = button.Text:GetText() or ''
            local oldBlockHeight = button:GetHeight()
            local oldHeight = button.Text:GetStringHeight()
            local newTitle = "["..level.."] "..buttonText
            button.Text:SetText(newTitle)
            local newHeight = button.Text:GetStringHeight()
            button:SetHeight(oldBlockHeight + newHeight - oldHeight)
        end
    end
end

hooksecurefunc("QuestLogQuests_Update", QuestLogQuests_hook)
