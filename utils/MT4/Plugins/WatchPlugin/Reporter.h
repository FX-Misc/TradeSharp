#pragma once
#include "UdpSender.h"

class Reporter
{
private:
	// ���� ��������
	int				m_nPort;
	// ����� ��������
	char			m_address[64];
	// �������� ����� ����������, ����������
	int				m_nInterval;
	// ��� (� ���������)
	char			m_Code[64];
	UdpSender		m_sender;
	// ����� ��������
	HANDLE			m_hThread;	
	// ������� �������
	int				m_serviceStopping;

public:
	Reporter();
	~Reporter();
	// ��������� ���������
	void			Initialize();
	// ��������� ����� ��������� � ����������
	static UINT __stdcall ThreadFunction(LPVOID param);
};

extern Reporter *extReporter;