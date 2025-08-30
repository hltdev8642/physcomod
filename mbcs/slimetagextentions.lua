-- version 1.0
-- please do not rename slimetagextentions.lua, thanks.

function TakeTag(handle, tag) return GetTagValue(handle, tag), RemoveTag(handle, Tag) end

function ReplaceTagValue(handle, tag, value) return GetTagValue(handle, tag), SetTag(handle, tag, value) end
