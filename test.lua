mem={"123123","12312"}
PerceptionScope=10




for Index, Value in pairs(mem) do
		print(tonumber(string.sub(Value,1,3)))
		print(tonumber(string.sub(Value,4,6)))
end

