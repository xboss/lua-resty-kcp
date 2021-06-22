# lua-resty-kcp

lua-resty-kcp - KCP support for the OpenResty.

基于C实现的[KCP](https://github.com/skywind3000/kcp),通过Luajit的ffi再次封装，使OpenResty具备KCP协议的解析和转发等功能。

KCP是一个快速可靠协议，能以比 TCP 浪费 10%-20% 的带宽的代价，换取平均延迟降低 30%-40%，且最大延迟降低三倍的传输效果。

关于ffi，[官网的callback](http://luajit.org/ext_ffi_semantics.html#callback)这一节说明“Callbacks are slow!”，实际情况有待测试，回头出一个测试报告。

## 状态

目前已经封装的API：
* recv
* send
* update
* check
* input
* flush
* wndsize
* nodelay
* setmtu
* waitsnd
* create


## 使用说明
#### 编译
```
cd lua-resty-kcp/
make
```
如果编译时报“'lua.h' file not found”，请修改“Makefile”文件中的“INCLUDE_DIR”值为你所使用的Luajit头文件的目录。

#### 测试
先启动OpenResty监听“12345”端口。修改“nginx.conf”如下：
```
server {
    listen 11111 udp;
    content_by_lua_block {
        local sock, err = ngx.req.socket()
        if not sock then
            ngx.log(ngx.ERR, "failed to get req.socket ", err)
            ngx.exit(500)
        end
        sock:settimeout(1000)
        local data, err = sock:receive()
        if not data then
            ngx.log(ngx.ERR, "failed to receive data ", err)
            return ngx.exit(200)
        end
        ngx.log(ngx.DEBUG, "data:", data)
    }
}
```
然后
```
cd lua-resty-kcp/src/lua/
resty test.lua
```
OpenResty能够收到消息表示可以正常使用了。
