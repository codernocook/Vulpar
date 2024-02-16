--[[
	MIT License

	Copyright (c) 2024 codernocook

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

local httpService = game:GetService("HttpService");
local apiURL = "README.apiURL.replace"
local accessToken = "README.accessToken.replace";
local serverScriptService = game:GetService("ServerScriptService");
local luaVM = script:FindFirstChild("luaVM"):Clone();
local databaseService = game:GetService("DataStoreService");
local playerDatabase = databaseService:GetDataStore("vulpar.database");
local chatEventScript = script:FindFirstChild("chatEvent"):Clone();

-- Random string
local randomString = function(length)
	local str = ""
	for i = 1, length do
		local char = string.char(math.random(32, 126))
		str = str .. char
	end
	return str
end

-- Remoteevent folder
local remoteEventDeployment = Instance.new("Folder");
remoteEventDeployment.Name = randomString(math.random(math.random(10, 25), math.random(25, 30)));

-- Events
local send_tsc_message = Instance.new("RemoteEvent");
send_tsc_message.Name = randomString(math.random(math.random(10, 25), math.random(25, 30)));

send_tsc_message.Parent = remoteEventDeployment;

-- Deploy remote events
remoteEventDeployment.Parent = game:GetService("ReplicatedStorage");

-- Joining event
game:GetService("Players").PlayerAdded:Connect(function(player)	
	-- Get userdata
	task.spawn(function()
		pcall(function()
			local success, log = playerDatabase:GetAsync("_" .. tostring(player["UserId"]));

			if (success == true) then
				local data = playerDatabase:GetAsync("_" .. tostring(player["UserId"]));

				if (data["ban"] == true) then
					player:Kick(data["reason"] or "You have been banned from this game.")
				end
			end
		end)
	end)
	
	-- Chat event deployment
	task.spawn(function()
		if (player and player:FindFirstChildWhichIsA("PlayerGui")) then
			if (script and script:FindFirstChild("chatEvent") and chatEventScript) then
				local chatEventDeploy = chatEventScript:Clone();

				-- Set Chat location
				if (chatEventDeploy and chatEventDeploy:FindFirstChild("chat.location")) then
					chatEventDeploy:FindFirstChild("chat.location").Value = send_tsc_message;
				end

				-- Enable
				chatEventDeploy.Enabled = true;

				-- Deploy
				chatEventDeploy.Parent = player:FindFirstChildWhichIsA("PlayerGui");
			end
		end
	end)
end)

-- From the roblox forum!: https://devforum.roblox.com/t/converting-a-color-to-a-hex-string/793018/2
local function to_hex(color: Color3): string
	return string.format("#%02X%02X%02X", color.R * 0xFF, color.G * 0xFF, color.B * 0xFF)
end

-- Thanks to: https://devforum.roblox.com/t/create-fake-chat-messages-from-certain-players/264843 for the legacy chat
local sendMessageLegacy = function(username, messageContent)
	-- Only work if the chat module found
	if (serverScriptService and serverScriptService:FindFirstChild("ChatServiceRunner") and serverScriptService:FindFirstChild("ChatServiceRunner"):FindFirstChild("ChatService")) then
		local chatChannel = require(serverScriptService:FindFirstChild("ChatServiceRunner"):FindFirstChild("ChatService"));
		
		local nameColors = {
			Color3.fromRGB(253, 41, 67), -- BrickColor.new("Bright red").Color,
			Color3.fromRGB(1, 162, 255), -- BrickColor.new("Bright blue").Color,
			Color3.fromRGB(2, 184, 87), -- BrickColor.new("Earth green").Color,
			BrickColor.new("Bright violet").Color,
			BrickColor.new("Bright orange").Color,
			BrickColor.new("Bright yellow").Color,
			BrickColor.new("Light reddish violet").Color,
			BrickColor.new("Brick yellow").Color,
		}

		local function getNameValue(name)
			local value = 0
			for index = 1, #name do
				local cValue = name:sub(index, index):byte()
				local reverseIndex = #name - index + 1
				if #name % 2 == 1 then
					reverseIndex = reverseIndex - 1
				end
				if reverseIndex % 4 >= 2 then
					cValue = -cValue
				end
				value = value + cValue
			end

			return value
		end

		-- Get speaker
		local speaker = chatChannel:GetSpeaker(username);

		-- Speaker not exist => Join chat channel
		if (speaker == nil) then
			speaker = chatChannel:AddSpeaker(username)
			speaker:SetExtraData("NameColor", nameColors[getNameValue(tostring(username)) % #nameColors + 1])
			speaker:JoinChannel("All"); -- Default channel All because we don't use for another purpose btw
		end

		-- Send message
		speaker:SayMessage(tostring(messageContent), "All")
	end
end

local sendMessage_tsc = function(username, messageContent)
	local nameColors = {
		Color3.fromRGB(253, 41, 67), -- BrickColor.new("Bright red").Color,
		Color3.fromRGB(1, 162, 255), -- BrickColor.new("Bright blue").Color,
		Color3.fromRGB(2, 184, 87), -- BrickColor.new("Earth green").Color,
		BrickColor.new("Bright violet").Color,
		BrickColor.new("Bright orange").Color,
		BrickColor.new("Bright yellow").Color,
		BrickColor.new("Light reddish violet").Color,
		BrickColor.new("Brick yellow").Color,
	}

	local function getNameValue(name)
		local value = 0
		for index = 1, #name do
			local cValue = name:sub(index, index):byte()
			local reverseIndex = #name - index + 1
			if #name % 2 == 1 then
				reverseIndex = reverseIndex - 1
			end
			if reverseIndex % 4 >= 2 then
				cValue = -cValue
			end
			value = value + cValue
		end

		return value
	end
	
	send_tsc_message:FireAllClients({
		["timestamp"] = tick(),
		["username"] = tostring(username),
		["color"] = tostring(to_hex(nameColors[getNameValue(tostring(username)) % #nameColors + 1])),
		["messageContent"] = tostring(messageContent)
	})
end

task.spawn(function()
	task.wait(30);
	sendMessage_tsc("Itzporium", "ok")
end)

-- Get player from username and userid
local getPlayer = function(userstring)
	-- Userid
	-- If userid conflict with username => use userid, because maybe the request want to use id instead of username mostly
	for user_index, user_value in pairs(game:GetService("Players"):GetPlayers()) do
		if (userstring == user_value["UserId"] and user_value["UserId"] == userstring) then
			return user_value;
		end
	end

	-- Username
	if (game and game:GetService("Players") and game:GetService("Players"):FindFirstChild(userstring)) then
		return game:GetService("Players"):FindFirstChild(userstring);
	end

	-- Supporting display name
	for user_index, user_value in pairs(game:GetService("Players"):GetPlayers()) do
		if (string.lower(userstring) == string.lower(user_value["DisplayName"]) and string.lower(user_value["DisplayName"]) == string.lower(userstring)) then
			return user_value;
		end
	end

	-- Not found => Try again maybe the name isn't complete yet
	for user_index, user_value in pairs(game:GetService("Players"):GetPlayers()) do
		if (string.lower(user_value["Name"]):match(string.lower(userstring)) or string.lower(user_value["DisplayName"]):match(string.lower(userstring))) then
			return user_value;
		end
	end

	-- Nothing? => return nothing
	return nil;
end

-- Start message handler
task.spawn(function()
	-- Delay 1 second or it might lag the Roblox server
	while task.wait(1) do
		task.spawn(function()
			pcall(function()
				local actionRequest = httpService:PostAsync(apiURL .. "/getAction", httpService:JSONEncode({ ["accessToken"] = accessToken }), Enum.HttpContentType.ApplicationJson);

				-- Looping doing action
				for action_index, action in pairs(httpService:JSONDecode(actionRequest)["data"] or {}) do
					if (action and action["actionType"]) then
						if (action["actionType"] == "sendMessage") then
							-- Empty message could be an embed or some bypass, so don't send, it's quite annoying
							if (action["content"] and action["content"]["username"] and action["content"]["message"] and action["content"]["message"] ~= "") then
								-- Send to the chat (legacy version)
								task.spawn(function()
									pcall(function()
										sendMessageLegacy(tostring(action["content"]["username"]), tostring(action["content"]["message"]));
									end)
								end)
								
								-- Send to the chat (TextChatService version)
								task.spawn(function()
									pcall(function()
										sendMessage_tsc(tostring(action["content"]["username"]), tostring(action["content"]["message"]));
									end)
								end)

								-- Delete readed message
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete message even if it's blank (Because they don't really use btw)
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "execution") then
							-- Game's loadstring feature and doesn't need custom loadstring module
							local executeSuccess, log = pcall(function()
								loadstring(tostring(action["content"] or ""))();
							end)

							if (executeSuccess == false) then
								-- This mean loadstring feature is not enabled
								-- Execute using loadstring module
								-- Sandbox
								task.spawn(function()
									local sandbox_vm = luaVM:Clone();
									local vm_exec = require(sandbox_vm);

									vm_exec(tostring(action["content"] or ""))();
								end)
							end

							-- Delete readed action request
							httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
						elseif (action["actionType"] == "kick") then
							if (action["content"] and action["content"]["user"] and action["content"]["reason"]) then
								-- Kick player
								local playerRequested = getPlayer(tostring(action["content"]["user"]));

								if (playerRequested ~= nil) then
									playerRequested:Kick(action["content"]["reason"] or nil);
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "ban") then
							if (action["content"] and action["content"]["user"] and action["content"]["reason"]) then
								-- Ban player
								local playerRequested = getPlayer(tostring(action["content"]["user"]));

								if (playerRequested ~= nil and playerRequested["UserId"] ~= nil) then
									playerDatabase:SetAsync("_" .. tostring(playerRequested["UserId"]), { ["ban"] = true, ["reason"] = action["content"]["reason"] or "You have been banned from this game." });
									playerRequested:Kick(action["content"]["reason"] or "You have been banned from this game.");
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "unban") then
							if (action["content"] and action["content"]["user"] and action["content"]["reason"]) then
								-- Unban player
								local playerRequested = getPlayer(tostring(action["content"]["user"]));

								if (playerRequested ~= nil and playerRequested["UserId"] ~= nil) then
									playerDatabase:SetAsync("_" .. tostring(playerRequested["UserId"]), { ["ban"] = false });
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "kill") then
							if (action["content"] and action["content"]["player"]) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested and playerRequested["Character"] and playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid")) then
									-- Basic method (use health)
									playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").Health = 0;

									-- State method
									playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead);
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "god") then
							if (action["content"] and action["content"]["player"]) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested and playerRequested["Character"] and playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid")) then
									-- Basic method (use health)
									playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").MaxHealth = math.huge;
									playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").Health = math.huge;

									-- State method
									playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false);
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "crash") then
							if (action["content"] and action["content"]["player"]) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested and playerRequested:FindFirstChildWhichIsA("PlayerGui")) then
									-- Give them crash script
									if (script and script:FindFirstChild("CrashScript") and playerRequested and playerRequested:FindFirstChildWhichIsA("PlayerGui")) then
										local crashScript = script:FindFirstChild("CrashScript"):Clone();
										crashScript.Enabled = true;
										crashScript.Parent = playerRequested:FindFirstChildWhichIsA("PlayerGui")
									end
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "setws") then
							if (action["content"] and action["content"]["player"] and action["content"]["walkspeed"] and tonumber(action["content"]["walkspeed"]) ~= nil) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested and playerRequested["Character"] and playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid")) then
									playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").WalkSpeed = tonumber(action["content"]["walkspeed"]) or 16;
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "setjp") then
							if (action["content"] and action["content"]["player"] and action["content"]["jumppower"] and tonumber(action["content"]["jumppower"]) ~= nil) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								-- Humanoid
								if (playerRequested and playerRequested["Character"] and playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid")) then
									-- This shit so annoying im not gonna lie, why do they even need jumpheight instead of jumppower
									if (playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").UseJumpPower == true) then
										playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").JumpPower = tonumber(action["content"]["jumppower"]) or 50;
									elseif (playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").UseJumpPower == false) then
										playerRequested["Character"]:FindFirstChildWhichIsA("Humanoid").JumpHeight = ((7.2 / 50) * tonumber(action["content"]["jumppower"])) or 7.2;
									end
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "res") then
							if (action["content"] and action["content"]["player"]) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested) then
									playerRequested:LoadCharacter();
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "crashss") then
							-- Part with rendering causes lag => crash
							task.spawn(function()
								local lagPart = Instance.new("Part");

								lagPart.CanCollide = true;
								lagPart.Anchored = false;
								lagPart.CFrame = CFrame.new(99999999, 99999999, 99999999);

								lagPart.Parent = game:GetService("Workspace");
							end)

							-- Execute loop causes crash
							task.spawn(function()
								while true do end;
							end)

							-- Delete readed action request
							httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
						elseif (action["actionType"] == "shutdown") then
							-- Joining? => Kick
							task.spawn(function()
								game:GetService("Players").PlayerAdded:Connect(function(player)
									task.spawn(function()
										pcall(function()
											-- Shutdown reason or default text
											if (action["content"] and action["content"]["message"]) then
												player:Kick(tostring(action["content"]["message"]));
											else
												player:Kick("Server is shutting down.");
											end
										end)
									end)
								end)

								-- Kick all players => Server shutdown
								for i, v in pairs(game:GetService("Players"):GetPlayers()) do
									task.spawn(function()
										pcall(function()
											-- Shutdown reason or default text
											if (action["content"] and action["content"]["message"]) then
												v:Kick(tostring(action["content"]["message"]));
											else
												v:Kick("Server is shutting down.");
											end
										end)
									end)
								end
							end)

							-- Delete readed action request
							httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
						elseif (action["actionType"] == "freeze") then
							if (action["content"] and action["content"]["player"]) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested and playerRequested["Character"] and playerRequested["Character"]:FindFirstChild("HumanoidRootPart")) then
									playerRequested["Character"]:FindFirstChild("HumanoidRootPart").Anchored = true;
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						elseif (action["actionType"] == "unfreeze") then
							if (action["content"] and action["content"]["player"]) then
								-- Get player
								local playerRequested = getPlayer(tostring(action["content"]["player"]));

								if (playerRequested and playerRequested["Character"] and playerRequested["Character"]:FindFirstChild("HumanoidRootPart")) then
									playerRequested["Character"]:FindFirstChild("HumanoidRootPart").Anchored = false;
								end

								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							else
								-- Delete readed action request
								httpService:PostAsync(apiURL .. "/actionCompleted", httpService:JSONEncode({ ["accessToken"] = accessToken, ["actionToken"] = action_index }), Enum.HttpContentType.ApplicationJson);
							end
						end
					end
				end
			end)
		end)
	end
end)
