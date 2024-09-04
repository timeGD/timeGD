getgenv().loadfile = newcclosure(function(filename)
return loadstring(readfile(filename))
end)

getgenv().getscriptclosure = newcclosure(function(scr)
        assert(typeof(scr) == 'Instance' and (scr.ClassName == 'LocalScript' or scr.ClassName == 'ModuleScript'), 'script expected as argument #1')
        for i,v in next, getgc() do
            if type(v) == 'function' then
                local env = getfenv(v)
                if type(env) == 'table' and rawget(env, 'script') == scr then
                    return v
                end
            end
        end
end)

getgenv().getscriptfunction = getscriptclosure
getgenv().http_request = request

getgenv().getcallbackvalue = newcclosure(function(bindable, oninvoke)
        return function(text, ...)
                        return bindable:Invoke(text, ...)
         end
end)

getgenv().hookmetamethod = newcclosure(function(self, method, func)
    local mt = getrawmetatable(self)
    local old = mt[method]
    setreadonly(mt, false)
    mt[method] = func
    setreadonly(mt, true)
    return old
end)

getgenv().IS_LOADED = true
getgenv().IS_REBEL_LOADED = true
getgenv().REBEL_LOADED = true

getgenv().newlclosure = newcclosure(function(closure)
	if (islclosure(closure)) then 
		return closure
	end

	return function(...) 
		return closure(...)
	end
end)


getgenv().getmenv = getsenv
getgenv().getcallingscript = newcclosure(function() return getfenv(0).script end)
getgenv().getcurrentscript = getgenv().getcallingscript

getgenv().getinstances = newcclosure(function()
            local objs = {}
            for i,v in next, getreg() do
               if type(v)=='table' then
                  for o,b in next, v do
                      if typeof(b) == "Instance" then
                           table.insert(objs, b)
                      end
                  end
               end
            end
         return objs
 end)


getgenv().getnilinstances = newcclosure(function()
    local objs = {}
	for i,v in next,getreg() do
		if type(v)=="table" then
			for o,b in next,v do
				if typeof(b) == "Instance" and b.Parent==nil then
					table.insert(objs, b)
				end
			end
		end
	end
	return objs
end)


getgenv().get_nil_instances = getgenv().getnilinstances

getgenv().unlockmodulescript = true


getgenv().getscripts = newcclosure(function()
    local scripts = {}
    for i, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") or v:IsA("ModuleScript") then
            table.insert(scripts, v)
        end
    end
    return scripts
end)


getgenv().getmodules = newcclosure(function()
        local t = {}
		for i,v in pairs(getinstances()) do
			if v:IsA('ModuleScript') then
				table.insert(t, v)
			end
		end
	return t
end)

getgenv().getloadedmodules = newcclosure(function()
        local t = {}
		for i,v in pairs(getinstances()) do
			if v:IsA('ModuleScript') then
				table.insert(t, v)
			end
		end
		return t
end)

getgenv().getrunningscripts = newcclosure(function()
    local scripts = {}
    for _, script in ipairs(game:GetService("Players").LocalPlayer:GetDescendants()) do
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            scripts[#scripts + 1] = script
        end
    end
    return scripts
end)

getgenv().getexecutioncontext = newcclosure(function()
    local runService = game:GetService("RunService")
    
    if runService:IsClient() then
        return "Client"
    elseif runService:IsServer() then
        return "Server"
    else
        return "Studio"
    end
end)

getgenv().getallthreads = newcclosure(function()
    local threads = {}
    local index = 1

    while true do
        local thread = debug.getthread(index)
        if thread then
            threads[index] = thread
            index = index + 1
        else
            break
        end
    end

    return threads
end)

getgenv().getconnections = newcclosure(function(signal)
    local c = signal:Connect(function() return end)
    local result = sleep_with_you(c)
    c:Disconnect()
    return result
end)

getgenv().firesignal = newcclosure(function(signal, ...)
    local connections = getconnections(signal)
    for _, connection in connections do
        connection.Function(...)
    end
end)

getgenv().isnetworkowner = newcclosure(function(p1)
-- "NetworkOwnerV3" can't be accessed in lua due to it being a 'SystemAddress' type property
--assert(typeof(p1) == "Instance", "invalid argument #1 to '?' (Instance expected)", 2)
--assert(IsA(p1, "BasePart"), "invalid argument #1 to '?' (BasePart expected)", 2)
local A = LocalPlayer.SimulationRadius
local B = LocalPlayer.Character or Wait(LocalPlayer.CharacterAdded)
local C = WaitForChild(B, "HumanoidRootPart", 300)
if C then
    if p1.Anchored then
        return false
    end
    if IsDescendantOf(p1, B) or (C.Position - p1.Position).Magnitude <= A then
        return true
    end
end
return p1
end)

getgenv().getrunningscripts = newcclosure(function()
    local scripts = {}
    for _, script in ipairs(game:GetService("Players").LocalPlayer:GetDescendants()) do
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            scripts[#scripts + 1] = script
        end
    end
    return scripts
end)

getgenv().getsenv = newcclosure(function(script_instance)
   for i, v in pairs(getreg()) do
      if type(v) == "function" then
         if getfenv(v).script == script_instance then
             return getfenv(v)
             end
          end
     end
end)


getgenv().dumpstring = newcclosure(function(p1)                                         
return tostring("\\" .. table_concat({string_byte(p1, 1, #p1)}, "\\"))
end)

getgenv().require =  newcclosure(function(module)
if typeof(module) ~= "Instance" or module.ClassName ~= "ModuleScript" then return error'attempt to require a non-ModuleScript' end
if module.Parent == game.CoreGui then return error'attempt to require a core ModuleScript' end
local old_identity = getthreadcontext()
setthreadcontext(2)
local is_run, result = pcall(getrenv().require, module)
setthreadcontext(old_identity)
if is_run then 
return result
else
return error(result)
end
end)

getgenv().getscripthash = newcclosure(function(script)
return script:GetHash()
end)


local lz4 = {}

type Streamer = {
	Offset: number,
	Source: string,
	Length: number,
	IsFinished: boolean,
	LastUnreadBytes: number,

	read: (Streamer, len: number?, shiftOffset: boolean?) -> string,
	seek: (Streamer, len: number) -> (),
	append: (Streamer, newData: string) -> (),
	toEnd: (Streamer) -> ()
}

type BlockData = {
	[number]: {
		Literal: string,
		LiteralLength: number,
		MatchOffset: number?,
		MatchLength: number?
	}
}

local function plainFind(str, pat)
	return string.find(str, pat, 0, true)
end

local function streamer(str): Streamer
	local Stream = {}
	Stream.Offset = 0
	Stream.Source = str
	Stream.Length = string.len(str)
	Stream.IsFinished = false	
	Stream.LastUnreadBytes = 0

	function Stream.read(self: Streamer, len: number?, shift: boolean?): string
		local len = len or 1
		local shift = if shift ~= nil then shift else true
		local dat = string.sub(self.Source, self.Offset + 1, self.Offset + len)

		local dataLength = string.len(dat)
		local unreadBytes = len - dataLength

		if shift then
			self:seek(len)
		end

		self.LastUnreadBytes = unreadBytes
		return dat
	end

	function Stream.seek(self: Streamer, len: number)
		local len = len or 1

		self.Offset = math.clamp(self.Offset + len, 0, self.Length)
		self.IsFinished = self.Offset >= self.Length
	end

	function Stream.append(self: Streamer, newData: string)
		-- adds new data to the end of a stream
		self.Source ..= newData
		self.Length = string.len(self.Source)
		self:seek(0) --hacky but forces a recalculation of the isFinished flag
	end

	function Stream.toEnd(self: Streamer)
		self:seek(self.Length)
	end

	return Stream
end

getgenv().lz4compress = newcclosure(function(str: string): string
	local blocks: BlockData = {}
	local iostream = streamer(str)

	if iostream.Length > 12 then
		local firstFour = iostream:read(4)

		local processed = firstFour
		local lit = firstFour
		local match = ""
		local LiteralPushValue = ""
		local pushToLiteral = true

		repeat
			pushToLiteral = true
			local nextByte = iostream:read()

			if plainFind(processed, nextByte) then
				local next3 = iostream:read(3, false)

				if string.len(next3) < 3 then
					--push bytes to literal block then break
					LiteralPushValue = nextByte .. next3
					iostream:seek(3)
				else
					match = nextByte .. next3

					local matchPos = plainFind(processed, match)
					if matchPos then
						iostream:seek(3)
						repeat
							local nextMatchByte = iostream:read(1, false)
							local newResult = match .. nextMatchByte

							local repos = plainFind(processed, newResult) 
							if repos then
								match = newResult
								matchPos = repos
								iostream:seek(1)
							end
						until not plainFind(processed, newResult) or iostream.IsFinished

						local matchLen = string.len(match)
						local pushMatch = true

						if iostream.Length - iostream.Offset <= 5 then
							LiteralPushValue = match
							pushMatch = false
							--better safe here, dont bother pushing to match ever
						end

						if pushMatch then
							pushToLiteral = false

							-- gets the position from the end of processed, then slaps it onto processed
							local realPosition = string.len(processed) - matchPos
							processed = processed .. match

							table.insert(blocks, {
								Literal = lit,
								LiteralLength = string.len(lit),
								MatchOffset = realPosition + 1,
								MatchLength = matchLen,
							})
							lit = ""
						end
					else
						LiteralPushValue = nextByte
					end
				end
			else
				LiteralPushValue = nextByte
			end

			if pushToLiteral then
				lit = lit .. LiteralPushValue
				processed = processed .. nextByte
			end
		until iostream.IsFinished
		table.insert(blocks, {
			Literal = lit,
			LiteralLength = string.len(lit)
		})
	else
		local str = iostream.Source
		blocks[1] = {
			Literal = str,
			LiteralLength = string.len(str)
		}
	end

	-- generate the output chunk
	-- %s is for adding header
	local output = string.rep("\x00", 4)
	local function write(char)
		output = output .. char
	end
	-- begin working through chunks
	for chunkNum, chunk in blocks do
		local litLen = chunk.LiteralLength
		local matLen = (chunk.MatchLength or 4) - 4

		-- create token
		local tokenLit = math.clamp(litLen, 0, 15)
		local tokenMat = math.clamp(matLen, 0, 15)

		local token = bit32.lshift(tokenLit, 4) + tokenMat
		write(string.pack("<I1", token))

		if litLen >= 15 then
			litLen = litLen - 15
			--begin packing extra bytes
			repeat
				local nextToken = math.clamp(litLen, 0, 0xFF)
				write(string.pack("<I1", nextToken))
				if nextToken == 0xFF then
					litLen = litLen - 255
				end
			until nextToken < 0xFF
		end

		-- push raw lit data
		write(chunk.Literal)

		if chunkNum ~= #blocks then
			-- push offset as u16
			write(string.pack("<I2", chunk.MatchOffset))

			-- pack extra match bytes
			if matLen >= 15 then
				matLen = matLen - 15

				repeat
					local nextToken = math.clamp(matLen, 0, 0xFF)
					write(string.pack("<I1", nextToken))
					if nextToken == 0xFF then
						matLen = matLen - 255
					end
				until nextToken < 0xFF
			end
		end
	end
	--append chunks
	local compLen = string.len(output) - 4
	local decompLen = iostream.Length

	return string.pack("<I4", compLen) .. string.pack("<I4", decompLen) .. output
end)

getgenv().lz4decompress = newcclosure(function(lz4data: string): string
	local inputStream = streamer(lz4data)

	local compressedLen = string.unpack("<I4", inputStream:read(4))
	local decompressedLen = string.unpack("<I4", inputStream:read(4))
	local reserved = string.unpack("<I4", inputStream:read(4))

	if compressedLen == 0 then
		return inputStream:read(decompressedLen)
	end

	local outputStream = streamer("")

	repeat
		local token = string.byte(inputStream:read())
		local litLen = bit32.rshift(token, 4)
		local matLen = bit32.band(token, 15) + 4

		if litLen >= 15 then
			repeat
				local nextByte = string.byte(inputStream:read())
				litLen += nextByte
			until nextByte ~= 0xFF
		end

		local literal = inputStream:read(litLen)
		outputStream:append(literal)
		outputStream:toEnd()
		if outputStream.Length < decompressedLen then
			--match
			local offset = string.unpack("<I2", inputStream:read(2))
			if matLen >= 19 then
				repeat
					local nextByte = string.byte(inputStream:read())
					matLen += nextByte
				until nextByte ~= 0xFF
			end

			outputStream:seek(-offset)
			local pos = outputStream.Offset
			local match = outputStream:read(matLen)
			local unreadBytes = outputStream.LastUnreadBytes
			local extra
			if unreadBytes then
				repeat
					outputStream.Offset = pos
					extra = outputStream:read(unreadBytes)
					unreadBytes = outputStream.LastUnreadBytes
					match ..= extra
				until unreadBytes <= 0
			end

			outputStream:append(match)
			outputStream:toEnd()
		end

	until outputStream.Length >= decompressedLen

	return outputStream.Source
end)

getgenv().lz4 = lz4

               
local DrawingLib = {}

local Camera = game:GetService("Workspace"):FindFirstChild("Camera")
local RunService = game:GetService("RunService")
local CoreGui = (RunService:IsStudio() and game:GetService("Players")["LocalPlayer"]:WaitForChild("PlayerGui") or game:GetService("CoreGui"))

local BaseDrawingProperties = setmetatable({
	Visible = true,
	Color = Color3.new(),
	Transparency = 0,
    Position, Vector2.new(),
	Remove = newcclosure(function()
	end)
}, {
	__add = newcclosure(function(tbl1, tbl2)
		local new = {}
		for i, v in next, tbl1 do
			new[i] = v
		end
		for i, v in next, tbl2 do
			new[i] = v
		end
		return new
	end)
})

local DrawingUI = nil;

DrawingLib.new = newcclosure(function(Type)
	if DrawingUI == nil then
		DrawingUI = Instance.new("ScreenGui");
		DrawingUI.Parent = CoreGui;
		DrawingUI.Name = "DrawingLib"
		DrawingUI.DisplayOrder = 1999999999
		DrawingUI.IgnoreGuiInset = true
	end

	if (Type == "Line") then
		local LineProperties = ({
			To = Vector2.new(),
			From = Vector2.new(),
			Thickness = 1,
		} + BaseDrawingProperties)

		local LineFrame = Instance.new("Frame");
		LineFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		LineFrame.BorderSizePixel = 0

		LineFrame.BackgroundColor3 = LineProperties.Color
		LineFrame.Visible = LineProperties.Visible
		LineFrame.BackgroundTransparency =  LineProperties.Transparency
		LineFrame.ZIndex=3000

		LineFrame.Parent = DrawingUI

		return setmetatable({}, {
					__newindex = newcclosure(function(self, Property, Value)
				if (Property == "To") then
					local To = Value
					local Direction = (To - LineProperties.From);
					local Center = (To + LineProperties.From) / 2
					local Distance = Direction.Magnitude
					local Theta = math.atan2(Direction.Y, Direction.X);

					LineFrame.Position = UDim2.fromOffset(Center.X, Center.Y);
					LineFrame.Rotation = math.deg(Theta);
					LineFrame.Size = UDim2.fromOffset(Distance, LineProperties.Thickness);

					LineProperties.To = To
				end
				if (Property == "From") then
					local From = Value
					local Direction = (LineProperties.To - From);
					local Center = (LineProperties.To + From) / 2
					local Distance = Direction.Magnitude
					local Theta = math.atan2(Direction.Y, Direction.X);

					LineFrame.Position = UDim2.fromOffset(Center.X, Center.Y);
					LineFrame.Rotation = math.deg(Theta);
					LineFrame.Size = UDim2.fromOffset(Distance, LineProperties.Thickness);


					LineProperties.From = From
				end
				if (Property == "Visible") then
					LineFrame.Visible = Value
					LineProperties.Visible = Value
				end
				if (Property == "Thickness") then
					Value = Value < 1 and 1 or Value

					local Direction = (LineProperties.To - LineProperties.From);
					local Distance = Direction.Magnitude

					LineFrame.Size = UDim2.fromOffset(Distance, Value);

					LineProperties.Thickness = Value
				end
				if (Property == "Transparency") then
					LineFrame.BackgroundTransparency = 1 - Value
					LineProperties.Transparency = 1 - Value
				end
				if (Property == "Color") then
					LineFrame.BackgroundColor3 = Value
					LineProperties.Color = Value 
				end
				if (Property == "ZIndex") then
					LineFrame.ZIndex = Value
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						LineFrame:Destroy();
					end)
				end
                if Property == "Destroy" then
                 return (function()
						LineFrame:Destroy();
					end)
                end
				return LineProperties[Property]
			end)
		})
	end

	if (Type == "Circle") then
		local CircleProperties = ({
			Radius = 150,
			Filled = false,
			Thickness = 0,
			Position = Vector2.new()
		} + BaseDrawingProperties)

		local CircleFrame = Instance.new("Frame");

		CircleFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		CircleFrame.BorderSizePixel = 0

		CircleFrame.BackgroundColor3 = CircleProperties.Color
		CircleFrame.Visible = CircleProperties.Visible
		CircleFrame.BackgroundTransparency = CircleProperties.Transparency

		local Corner = Instance.new("UICorner", CircleFrame);
		Corner.CornerRadius = UDim.new(1, 0);
		CircleFrame.Size = UDim2.new(0, CircleProperties.Radius, 0, CircleProperties.Radius);

		CircleFrame.Parent = DrawingUI

		local Stroke = Instance.new("UIStroke", CircleFrame)
		Stroke.Thickness = CircleProperties.Thickness
		Stroke.Enabled = true
        Stroke.Transparency = 0

		return setmetatable({}, {
			__newindex = newcclosure(function(self, Property, Value)
				if (Property == "Radius") then
					CircleFrame.Size = UDim2.new(0,Value*2,0,Value*2)
					CircleProperties.Radius = Value
				end
				if (Property == "Position") then
					CircleFrame.Position = UDim2.new(0, Value.X, 0, Value.Y);
					CircleProperties.Position = Value
				end
				if (Property == "Filled") then
					if Value == true then	
						CircleFrame.BackgroundTransparency = CircleProperties.Transparency
						Stroke.Enabled = not Value
						CircleProperties.Filled = Value
					else
					    CircleFrame.BackgroundTransparency = (Value == true and 0 or 1)
					    Stroke.Enabled = not Value
					    CircleProperties.Filled = Value
					end
				end
				if (Property == "Color") then
					CircleFrame.BackgroundColor3 = Value
					Stroke.Color = Value
					CircleProperties.Color = Value
				end
				if (Property == "Thickness") then
					Stroke.Thickness = Value
					CircleProperties.Thickness = Value
				end
				if (Property == "Transparency") then
					CircleFrame.BackgroundTransparency = Value
					CircleProperties.Transparency = Value
				end
				if (Property == "Visible") then
					CircleFrame.Visible = Value
					CircleProperties.Visible = Value
				end
				if (Property == "ZIndex") then
					CircleFrame.ZIndex = Value
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						CircleFrame:Destroy();
					end)
				end
                if Property ==  "Destroy" then
                return (function()
						CircleFrame:Destroy();
					end)
                end
				return CircleProperties[Property]
			end)
		})
	end

	if (Type == "Text") then
		local TextProperties = ({
			Text = "",
			Center = false,
			Outline = false,
			OutlineColor = Color3.new(),
			Position = Vector2.new(),
            TextBounds = Vector2.new(),
		} + BaseDrawingProperties)

		local TextLabel = Instance.new("TextLabel");
		TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
		TextLabel.BorderSizePixel = 0
		TextLabel.Font = Enum.Font.SourceSans
		TextLabel.TextSize = 14
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
		TextLabel.TextYAlignment = Enum.TextYAlignment.Top

		TextLabel.TextColor3 = TextProperties.Color
		TextLabel.Visible = true
		TextLabel.BackgroundTransparency = 1
		TextLabel.TextTransparency = 1 - TextProperties.Transparency
		
		local Stroke = Instance.new("UIStroke", TextLabel)
		Stroke.Thickness = 0
		Stroke.Enabled = false
		Stroke.Color = TextProperties.OutlineColor
		TextLabel.Parent = DrawingUI

		return setmetatable({}, {
			__newindex = newcclosure(function(self, Property, Value)
				if (Property == "Text") then
					TextLabel.Text = Value
					TextProperties.Text = Value
				end
				if (Property == "Position") then
						TextLabel.Position = UDim2.fromOffset(Value.X, Value.Y);
					    TextProperties.Position = Vector2.new(Value.X, Value.Y);
				end
				if (Property == "Size") then
					TextLabel.TextSize = Value
					TextProperties.TextSize = Value
				end
				if (Property == "Color") then
					TextLabel.TextColor3 = Value
				--	Stroke.Color = Value
					TextProperties.Color = Value
				end
				if (Property == "Transparency") then
					TextLabel.TextTransparency = 1 - Value
                     Stroke.Transparency = 1 - Value
					TextProperties.Transparency = 1 - Value
				end
				if (Property == "OutlineOpacity") then
					TextLabel.TextStrokeTransparency = Value
					--Stroke.Transparency = Value
				end
				if (Property == "OutlineColor") then
					Stroke.Color = Value
					TextProperties.OutlineColor = Value
				end
				if (Property == "Visible") then
					TextLabel.Visible = Value
					TextProperties.Visible = Value
				end
				if (Property == "Outline") then
					if Value == true then
						Stroke.Thickness = 1
						Stroke.Enabled = Value
					else
						Stroke.Thickness = 0
						Stroke.Enabled = Value
					end
				end
				if (Property == "TextBounds") then
					TextLabel.TextBounds = Vector2.new(TextProperties.Position , Value);
				end
				if (Property == "Center") then
					if Value == true then
						TextLabel.TextXAlignment = Enum.TextXAlignment.Center;
						TextLabel.TextYAlignment = Enum.TextYAlignment.Center;
						TextProperties.Center = Enum.TextYAlignment.Center;
					else
						TextProperties.Center = Value
					end
				end
				if (Property == "ZIndex") then
					TextLabel.ZIndex = Value
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						TextLabel:Destroy();
					end)
				end
                 if Property == "Destroy" then
                return (function()
						TextLabel:Destroy();
					end)
                end
				return TextProperties[Property]
			end)
		})
	end

	if (Type == "Square") then
		local SquareProperties = ({
			Thickness = 1,
			Size = Vector2.new(),
			Position = Vector2.new(),
			Filled = false,
		} + BaseDrawingProperties);
		local SquareFrame = Instance.new("Frame");

		--SquareFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		SquareFrame.BorderSizePixel = 0

		SquareFrame.Visible = SquareProperties.Visible
		SquareFrame.Parent = DrawingUI

		local Stroke = Instance.new("UIStroke", SquareFrame)
		Stroke.Thickness = 2
		Stroke.Enabled = true
		SquareFrame.BackgroundTransparency = 0
		Stroke.Transparency = 0

		return setmetatable({}, {
			__newindex = newcclosure(function(self, Property, Value)
				if (Property == "Position") then
					SquareFrame.Position = UDim2.fromOffset(Value.X, Value.Y);
					SquareProperties.Position = Value
				end
				if (Property == "Size") then
					SquareFrame.Size = UDim2.new(0, Value.X, 0, Value.Y);
					SquareProperties.Size = Value
				end
                if (Property == "Thickness") then
                    Stroke.Thickness = Value
                    SquareProperties.Thickness = Value
				end
				if (Property == "Color") then
					SquareFrame.BackgroundColor3 = Value
					Stroke.Color = Value
					SquareProperties.Color = Value
				end
				if (Property == "Transparency") then
					--SquareFrame.BackgroundTransparency = Value
				--	Stroke.Transparency = Value
					SquareProperties.Transparency = Value
				end
				if (Property == "Visible") then
					SquareFrame.Visible = Value
					SquareProperties.Visible = Value
				end
				if (Property == "Filled") then -- requires beta
					if Value == true then	
						SquareFrame.BackgroundTransparency = SquareProperties.Transparency
						Stroke.Transparency = 1
						Stroke.Enabled = not Value
						SquareProperties.Filled = Value
					else
					    SquareFrame.BackgroundTransparency = (Value == true and 0 or 1)
					    Stroke.Enabled = not Value
					    SquareProperties.Filled = Value
					end
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						SquareFrame:Destroy();
					end)
				end
               if Property == "Destroy" then				
				return (function()
						SquareFrame:Destroy();
					end)
				end
				return SquareProperties[Property]
			end)
		})
	end
     
if (Type == "Image") then
		local ImageProperties = ({
			Data = "rbxassetid://848623155", -- roblox assets only rn
			Size = Vector2.new(),
			Position = Vector2.new(),
			Rounding = 0,
			Color = Color3.new(),
		});

		local ImageLabel = Instance.new("ImageLabel");

		ImageLabel.BorderSizePixel = 0
		ImageLabel.ScaleType = Enum.ScaleType.Stretch
		ImageLabel.Transparency = 1

		ImageLabel.ImageColor3 = ImageProperties.Color
		ImageLabel.Visible = false
		ImageLabel.Parent = DrawingUI

		return setmetatable({}, {
			__newindex = newcclosure(function(self, Property, Value)
				if (Property == "Size") then
					ImageLabel.Size = UDim2.new(0, Value.X, 0, Value.Y);
					ImageProperties.Text = Value
				end
				if (Property == "Position") then
					ImageLabel.Position = UDim2.new(0, Value.X, 0, Value.Y);
					ImageProperties.Position = Value
				end
				if (Property == "Size") then
					ImageLabel.Size = UDim2.new(0, Value.X, 0, Value.Y);
					ImageProperties.Size = Value
				end
				if (Property == "Transparency") then
					ImageLabel.ImageTransparency = math.clamp(1-Value,0,1)
					ImageProperties.Transparency = math.clamp(1-Value,0,1)
				end
				if (Property == "Visible") then
					ImageLabel.Visible = Value
					ImageProperties.Visible = Value
				end
				if (Property == "Color") then
					ImageLabel.ImageColor3 = Value
					ImageProperties.Color = Value
				end
				if (Property == "Data") then
					ImageLabel.Image = Value
					ImageProperties.Data = Value
				end
				if (Property == "ZIndex") then
					ImageLabel.ZIndex = Value
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						ImageLabel:Destroy();
					end)
				end
                if Property ==  "Destroy" then
                return (function()
						ImageLabel:Destroy();
					end)
                end
				return ImageProperties[Property]
			end)
		})
	end

	if (Type == "Quad") then -- idk if this will work lmao
		local QuadProperties = ({
			Thickness = 1,
			Transparency = 1,	
			Color = Color3.new(),
			PointA = Vector2.new();
			PointB = Vector2.new();
			PointC = Vector2.new();
			PointD = Vector2.new();
			Filled = false;
		}  + BaseDrawingProperties);

		local PointA = DrawingLib.new("Line")
		local PointB = DrawingLib.new("Line")
		local PointC = DrawingLib.new("Line")
		local PointD = DrawingLib.new("Line")

		return setmetatable({}, {
			__newindex = newcclosure(function(self, Property, Value)
				if Property == "Thickness" then
					PointA.Thickness = Value
					PointB.Thickness = Value
					PointC.Thickness = Value
					PointD.Thickness = Value
					QuadProperties.Thickness = Value
				end
				if Property == "PointA" then
					PointA.From = Value
					PointB.To = Value
				end
				if Property == "PointB" then
					PointB.From = Value
					PointC.To = Value
				end
				if Property == "PointC" then
					PointC.From = Value
					PointD.To = Value
				end
				if Property == "PointD" then
					PointD.From = Value
					PointA.To = Value
				end
				if Property == "Filled" then
					-- i'll do this later
				end
				if Property == "Color" then
					PointA.Color = Value
					PointB.Color = Value
					PointC.Color = Value
					PointD.Color = Value
					QuadProperties.Color = Value
				end
				if Property == "Transparency" then
					PointA.Transparency = Value
					PointB.Transparency = Value
					PointC.Transparency = Value
					PointD.Transparency = Value
					QuadProperties.Transparency = Value
				end
				if Property == "Visible" then
					PointA.Visible = Value
					PointB.Visible = Value
					PointC.Visible = Value
					PointD.Visible = Value
					QuadProperties.Visible = Value
				end
				if (Property == "ZIndex") then
					PointA.ZIndex = Value
					PointB.ZIndex = Value
					PointC.ZIndex = Value
					PointD.ZIndex = Value
					QuadProperties.ZIndex = Value
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						PointA:Remove();
						PointB:Remove();
						PointC:Remove();
						PointD:Remove();
					end)
				end
                if Property ==  "Destroy" then
                       return (function()
						PointA:Remove();
						PointB:Remove();
						PointC:Remove();
						PointD:Remove();
					end)
                end
				return QuadProperties[Property]
			end)
		});
	end

	if (Type == "Triangle") then  -- idk if this will work lmao
		local TriangleProperties = ({
			Thickness = 1,
			Transparency = 1,	
			Color = Color3.new(),
			PointA = Vector2.new();
			PointB = Vector2.new();
			PointC = Vector2.new();
			PointD = Vector2.new();
			Filled = false;
		}  + BaseDrawingProperties);

		local PointA = DrawingLib.new("Line")
		local PointB = DrawingLib.new("Line")
		local PointC = DrawingLib.new("Line")

		return setmetatable({}, {
			__newindex = newcclosure(function(self, Property, Value)
				if Property == "Thickness" then
					PointA.Thickness = Value
					PointB.Thickness = Value
					PointC.Thickness = Value
					PointD.Thickness = Value
					TriangleProperties.Thickness = Value
				end
				if Property == "PointA" then
					PointA.From = Value
					PointB.To = Value
				end
				if Property == "PointB" then
					PointB.From = Value
					PointC.To = Value
				end
				if Property == "PointC" then
					PointC.From = Value
					PointD.To = Value
				end
				if Property == "PointD" then
					PointD.From = Value
					PointA.To = Value
				end
				if Property == "Filled" then
					-- i'll do this later
				end
				if Property == "Color" then
					PointA.Color = Value
					PointB.Color = Value
					PointC.Color = Value
					PointD.Color = Value
					TriangleProperties.Color = Value
				end
				if Property == "Transparency" then
					PointA.Transparency = Value
					PointB.Transparency = Value
					PointC.Transparency = Value
					PointD.Transparency = Value
					TriangleProperties.Transparency = Value
				end
				if Property == "Visible" then
					PointA.Visible = Value
					PointB.Visible = Value
					PointC.Visible = Value
					PointD.Visible = Value
					TriangleProperties.Visible = Value
				end
				if (Property == "ZIndex") then
					PointA.ZIndex = Value
					PointB.ZIndex = Value
					PointC.ZIndex = Value
					PointD.ZIndex = Value
					TriangleProperties.ZIndex = Value
				end
			end),
			__index = newcclosure(function(self, Property)
				if (string.lower(tostring(Property)) == "remove") then
					return (function()
						PointA:Remove();
						PointB:Remove();
						PointC:Remove();
					end)
				end
                if Property ==  "Destroy" then
                return (function()
						PointA:Remove();
						PointB:Remove();
						PointC:Remove();
					end)
                end
				return TriangleProperties[Property]
			end)
		});
	end
end)


DrawingLib.clear = newcclosure(function() 
	DrawingUI:ClearAllChildren();
end)

if RunService:IsStudio() then
	return DrawingLib
else
	if getgenv then
		getgenv()["Drawing"] = DrawingLib
		getgenv()["clear_drawing_lib"] = DrawingLib.clear
		Drawing = drawing
	else
		Drawing = DrawingLib
	end
end
getgenv()["Drawing"] = DrawingLib
getgenv()["clear_drawing_lib"] = DrawingLib.clear
getgenv().Drawing = DrawingLib
getgenv().clear_drawing_lib = DrawingLib.clear

Drawing.Fonts = {}

Drawing.Fonts.UI = 0
Drawing.Fonts.System = 1
Drawing.Fonts.Plex = 2
Drawing.Fonts.Monospace = 3

getgenv().cleardrawcache = DrawingLib.clear
Drawing.cleardrawcache = DrawingLib.clear



local rendered = false
getgenv().isrenderobj = newcclosure(function(a, drawing2)
if rendered == true then
return false
end

rendered = true
return true
end)

getgenv().setrenderproperty = newcclosure(function(drawing, object, value)
drawing[object] = value
return object
end)

getgenv().getrenderproperty = function(drawing, object)
local value = drawing[object]
return value
end

getgenv().fireproximityprompt = newcclosure(function(Obj, Amount, Skip)
	assert(typeof(Obj) == "Instance", "invalid argument #1 to 'fireproximityprompt' (ProximityPrompt expected, got " .. type(Spoof) .. ") ")
	assert(Obj.ClassName == "ProximityPrompt", "invalid argument #1 to 'fireproximityprompt' (ProximityPrompt expected, got " .. type(Spoof) .. ") ")
    assert(type(Amount) == "number", "invalid argument #2 to 'fireproximityprompt' (number expected, got " .. type(Amount) .. ") ", 2)
	Amount = Amount or 1
    local PromptTime = Obj.HoldDuration
    if Skip then
        Obj.HoldDuration = 0
    end
    for i = 1, Amount do
        Obj:InputHoldBegin()
        if not Skip then
            wait(Obj.HoldDuration)
        end
        Obj:InputHoldEnd()
    end
    Obj.HoldDuration = PromptTime
end)

getgenv().rconsoleclear = newcclosure(function(...)
end)
getgenv().consoleclear = newcclosure(function(...)
end)
getgenv().rconsolecreate = newcclosure(function(...)
end)
getgenv().consolecreate = newcclosure(function(...)
end)
getgenv().consoledestroy = newcclosure(function(...)
end)
getgenv().rconsoleinput = newcclosure(function(...)
end)
getgenv().consoleinput = newcclosure(function(...)
end)
getgenv().rconsoleprint = newcclosure(function(...)
end)
getgenv().consoleprint = newcclosure(function(...)
end)
getgenv().rconsolesettitle = newcclosure(function(...)
end)
getgenv().rconsolename = newcclosure(function(...)
end)
getgenv().consolesettitle = newcclosure(function(...)
end)

getgenv().info = newcclosure(function(...)
   game:GetService('TestService'):Message(table.concat({...}, ' '))
end)

getgenv().syn_mouse1press = mouse1press
getgenv().syn_mouse2click = mouse2click
getgenv().syn_mousemoverel = movemouserel
getgenv().syn_mouse2release = mouse2up
getgenv().syn_mouse1release = mouse1up
getgenv().syn_mouse2press = mouse2down
getgenv().syn_mouse1click = mouse1click
getgenv().syn_newcclosure = newcclosure
getgenv().syn_clipboard_set = setclipboard
getgenv().syn_clipboard_get = getclipboard
getgenv().syn_islclosure = islclosure
getgenv().syn_iscclosure = iscclosure
getgenv().syn_getsenv = getsenv
getgenv().syn_getscripts = getscripts
getgenv().syn_getgenv = getgenv
getgenv().syn_getinstances = getinstances
getgenv().syn_getreg = getreg
getgenv().syn_getrenv = getrenv
getgenv().syn_getnilinstances = getnilinstances
getgenv().syn_fireclickdetector = fireclickdetector
getgenv().syn_getgc = getgc
           
getgenv().debug.traceback = getrenv().debug.traceback
getgenv().debug.profilebegin = getrenv().debug.profilebegin
getgenv().debug.profileend = getrenv().debug.profileend
getgenv().debug.getmetatable = getgenv().getrawmetatable
getgenv().debug.setmetatable = getgenv().setrawmetatable
getgenv().debug.info = getrenv().debug.info
