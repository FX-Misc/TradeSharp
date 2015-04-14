#pragma once
#include "UDP\UdpListener.h"

#define QUOTES_MAXLEN 256

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Response
{
	int			requestId;			// id �������
	int			status;				// ��. ����
	double		price;				// ���� ����������
	double		sl;
	double		tp;
	char		comment[32];		// id �������, ����������� � ����������
	char		isPendingActivate;	// ����� �� ������ ��������� ����������� ������
	int			pendingOrderId;		// id ������������� ����������� ������
	char		isStopoutReply;		// ������� ��������

	void		Copy(Response *resp)
	{
		requestId = resp->requestId; 
		status = resp->status; 
		price = resp->price;
		sl = resp->sl; 
		tp = resp->tp;
		isPendingActivate = resp->isPendingActivate;
		pendingOrderId = resp->pendingOrderId;
		strcpy(comment, resp->comment);
		isStopoutReply = resp->isStopoutReply;
	}
};
// ��������� ���������� �������
enum 
{ 
	RequestCompleted = 10, 
	RequestFailed = 20, 
	RequestWrongParams = 30, 
	RequestWrongPrice = 40,
	RequestToClose = 50,
	OrderSLExecuted = 60,
	OrderTPExecuted = 70
};

// resp - ��������� �� ����������� response
// TRUE - response ���������, � ������� �� �����������
typedef int (*ON_RESPONSE)(Response *resp);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ResponseQueue
{
private:	
	UdpListener			*listener;
	CRITICAL_SECTION	locker;
	Response			buffer[QUOTES_MAXLEN];
	volatile int		length;
	static ON_RESPONSE	OnResponse;
private:
	void				Free(int count);
	void				Enqueue(Response *resp);	
	static void			OnReceive(char *buf, int len);
public:
	ResponseQueue(ON_RESPONSE _onResp);
	~ResponseQueue();

	void				Init(char *host, int port);	
	int					FindAndDequeue(int requestId, Response* resp);
};

extern ResponseQueue	*extQueue;