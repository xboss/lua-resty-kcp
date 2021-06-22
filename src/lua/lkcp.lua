
local ffi = require("ffi")

ffi.cdef[[
typedef uint32_t ISTDUINT32;
typedef int32_t ISTDINT32;
typedef ISTDINT32 IINT32;
typedef ISTDUINT32 IUINT32;
struct IQUEUEHEAD {
	struct IQUEUEHEAD *next, *prev;
};
struct IKCPCB
{
	IUINT32 conv, mtu, mss, state;
	IUINT32 snd_una, snd_nxt, rcv_nxt;
	IUINT32 ts_recent, ts_lastack, ssthresh;
	IINT32 rx_rttval, rx_srtt, rx_rto, rx_minrto;
	IUINT32 snd_wnd, rcv_wnd, rmt_wnd, cwnd, probe;
	IUINT32 current, interval, ts_flush, xmit;
	IUINT32 nrcv_buf, nsnd_buf;
	IUINT32 nrcv_que, nsnd_que;
	IUINT32 nodelay, updated;
	IUINT32 ts_probe, probe_wait;
	IUINT32 dead_link, incr;
	struct IQUEUEHEAD snd_queue;
	struct IQUEUEHEAD rcv_queue;
	struct IQUEUEHEAD snd_buf;
	struct IQUEUEHEAD rcv_buf;
	IUINT32 *acklist;
	IUINT32 ackcount;
	IUINT32 ackblock;
	void *user;
	char *buffer;
	int fastresend;
	int fastlimit;
	int nocwnd, stream;
	int logmask;
	int (*output)(const char *buf, int len, struct IKCPCB *kcp, void *user);
	void (*writelog)(const char *log, struct IKCPCB *kcp, void *user);
};
typedef struct IKCPCB ikcpcb;
// typedef int (*output_cb)(const char *buf, int len, struct IKCPCB *kcp, void *user);

ikcpcb* ikcp_create(IUINT32 conv, void *user);
void ikcp_release(ikcpcb *kcp);
void ikcp_setoutput(ikcpcb *kcp, int (*output)(const char *buf, int len, 
	ikcpcb *kcp, void *user));
int ikcp_recv(ikcpcb *kcp, char *buffer, int len);
int ikcp_send(ikcpcb *kcp, const char *buffer, int len);
void ikcp_update(ikcpcb *kcp, IUINT32 current);
IUINT32 ikcp_check(const ikcpcb *kcp, IUINT32 current);
int ikcp_input(ikcpcb *kcp, const char *data, long size);
void ikcp_flush(ikcpcb *kcp);
int ikcp_peeksize(const ikcpcb *kcp);
int ikcp_setmtu(ikcpcb *kcp, int mtu);
int ikcp_wndsize(ikcpcb *kcp, int sndwnd, int rcvwnd);
int ikcp_waitsnd(const ikcpcb *kcp);
int ikcp_nodelay(ikcpcb *kcp, int nodelay, int interval, int resend, int nc);
void ikcp_log(ikcpcb *kcp, int mask, const char *fmt, ...);
void ikcp_allocator(void* (*new_malloc)(size_t), void (*new_free)(void*));
IUINT32 ikcp_getconv(const void *ptr);
]]


local ikcplib = nil

local _M = {}

function _M.loadlib(ikcplib_path)
	ikcplib = ffi.load(ikcplib_path)
end


function _M.create(conv, user)
	user = ffi.cast("void*", user)
	return ikcplib.ikcp_create(conv, user)
end

function _M.set_output(kcp, output_func)
	return ikcplib.ikcp_setoutput(kcp, function (buf, len, kcp, user)
        return output_func(ffi.string(buf, len), user)
    end)
end

function _M.send(kcp, buf, len)
	return ikcplib.ikcp_send(kcp, buf, len)
end

function _M.recv(kcp, buf, len)
	return ikcplib.ikcp_recv(kcp, buf, len)
end

function _M.update(kcp, ms)
	return ikcplib.ikcp_update(kcp, ms)
end

function _M.nodelay(kcp, nodelay, interval, resend, nc)
	return ikcplib.ikcp_nodelay(kcp, nodelay, interval, resend, nc)
end

function _M.setmtu(kcp, mtu)
	return ikcplib.ikcp_setmtu(kcp, mtu)
end

function _M.wndsize(kcp, sndwnd, rcvwnd)
	return ikcplib.ikcp_wndsize(kcp, sndwnd, rcvwnd)
end

function _M.input(kcp, data, size)
	return ikcplib.ikcp_input(kcp, data, size)
end

function _M.flush(kcp)
	return ikcplib.ikcp_flush(kcp)
end

function _M.check(kcp, ms)
	return ikcplib.ikcp_check(kcp, ms)
end

function _M.release(kcp)
	return ikcplib.ikcp_release(kcp)
end

return _M




