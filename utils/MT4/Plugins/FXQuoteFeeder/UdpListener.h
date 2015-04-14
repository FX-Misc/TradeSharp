#pragma once
typedef void (*ON_RECV)(char *buf, int len);

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

public:
	UdpListener(char *ip, int port, ON_RECV onRecv);
	~UdpListener();
	void Listen();
	void Stop();	
	static void SetupWSA();
	static void TeardownWSA();
};
