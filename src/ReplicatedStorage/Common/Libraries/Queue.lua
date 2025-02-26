local Queue = {}
Queue.__index = Queue

function Queue.new()
	local self = setmetatable({}, Queue)
	self._queue = {}
	self._size = 0
	self._processing = false
	return self
end

function Queue:Enqueue(taskFunction, ...)
	local args = { ... }
	table.insert(self._queue, function()
		taskFunction(unpack(args))
	end)
	self._size = self._size + 1
	self:ProcessQueue()
end

function Queue:Dequeue()
	if self._size == 0 then
		error("Queue is empty")
	end
	local task = table.remove(self._queue, 1)
	self._size = self._size - 1
	return task
end

function Queue:ProcessQueue()
	if not self._processing and self._size > 0 then
		self._processing = true
		coroutine.wrap(function()
			while self._size > 0 do
				local task = self:Dequeue()
				task()
			end
			self._processing = false
		end)()
	end
end

function Queue:Size()
	return self._size
end

function Queue:IsEmpty()
	return self._size == 0
end

function Queue:Clear()
	self._queue = {}
	self._size = 0
end

return Queue
