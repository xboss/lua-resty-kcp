local lkcp = require "lkcp"

local str_sub = string.sub

lkcp.loadlib("/root/jim/lua-resty-kcp/ikcp.so")


local sock = ngx.socket.udp()
local ok, err = sock:setpeername("127.0.0.1", 12345)
if not ok then
    print("failed to connect: ", err)
    return
end
print("successfully connected!")


local function getms()
    return ngx.now() * 1000
end

local function udp_output(buf, user)
    -- print("udp_output: ", buf, " ", tonumber(user))
    local ok, err = sock:send(buf)
    if not ok then
        print("sock send error : ", err)
        return 0
    end
    return 0
end

local function recv()
    local data, err
    sock:settimeout(1000)  -- one second timeout
    data, err = sock:receive()
    if not data then
        print("failed to read a packet: ", err)
        return 0, nil
    end
    return #data, data
end

local function test(mode)
    local session = 111
    local kcp = lkcp.create(session, session)

    lkcp.set_output(kcp, udp_output)

	--配置窗口大小：平均延迟200ms，每20ms发送一个包，
	--而考虑到丢包重发，设置最大收发窗口为128
	lkcp.wndsize(kcp, 128, 128)

	--判断测试用例的模式
    if mode == 0 then
		--默认模式
        lkcp.nodelay(kcp, 0, 10, 0, 0)
    elseif mode == 1 then
		--普通模式，关闭流控等
        lkcp.nodelay(kcp, 0, 10, 0, 1)
    else
		--启动快速模式
		--第二个参数 nodelay-启用以后若干常规加速将启动
		--第三个参数 interval为内部处理时钟，默认设置为 10ms
		--第四个参数 resend为快速重传指标，设置为2
		--第五个参数 为是否禁用常规流控，这里禁止
        lkcp.nodelay(kcp, 1, 10, 2, 1)
    end

    local hrlen = 0
    local hr = ""

    while 1 do
        local current = getms()
        -- lkcp.check(kcp, current)
        lkcp.update(kcp, current)
        local msg = "test msg"
        lkcp.send(kcp, msg)

		hrlen, hr = recv()
        if hrlen > 0 then
            -- print("recv:", hr)
            lkcp.input(kcp, hr, hrlen)
        end
        local buf = lkcp.recv(kcp, 100)
        print("recv:", buf)
    end

    lkcp.release(kcp)
end

--测试
test(0) --默认模式，类似 TCP：正常模式，无快速重传，常规流控
-- test(1) --普通模式，关闭流控等
-- test(2) --快速模式，所有开关都打开，且关闭流控

sock:close()



