#pragma once
typedef void (*ON_RECV)(const TCHAR *buf, int len);

class UdpListener
{
private:
	char m_ip[128];
	int  m_port;
	ON_RECV m_onRecv;

	// ���������� ���������� �������
	void* m_hThread;	
	void* m_hShutdownCompletedEvent;
	UINT_PTR m_hSocket;
	// ��������� �������
	static DWORD __stdcall ThreadProc(LPVOID lpParameter);
	
	// ���������
public:
	int GetPort() { return m_port; }
	const char* GetIp() { return m_ip; }

	// ������
public:
	UdpListener(const char *ip, int port, ON_RECV onRecv);
	~UdpListener();
	void Listen();
	void Stop();	
	static void SetupWSA();
	static void TeardownWSA();
public:
	static int lastErrorCode;
};
