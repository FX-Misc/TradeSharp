USE MTS_LIVE
GO

/*
DROP TABLE CHANNEL_GROUP
DROP TABLE CHANNEL
DROP TABLE POSITION
DROP TABLE PENDING_ORDER
DROP TABLE BALANCE_CHANGE
DROP TABLE ACCOUNT
DROP TABLE ACCOUNT_GROUP

DROP TABLE CURRENCY_PAIR_INFO
DROP TABLE CURRENCY_INFO
*/


CREATE TABLE COMMODITY
(
	/* �������� � ���� ���� */
    Title VARCHAR(6) PRIMARY KEY NOT NULL,
    /* �������������� �������� */
	Description VARCHAR(25) NULL,
    /* ��� � ������ ������� */
	CodeFXI INT NULL,
	/* ���������� ������ */
	InterestRatePercent DECIMAL(6,2) NULL,
	/* ��� (0 - ������, 1 - �����, 2 - ������� ������, 3 - ����������) */
	ComType INT NOT NULL
)
GO

CREATE TABLE SPOT
(
	/* ������ ��4: EURUSD, CADNZD... */
    Title VARCHAR(12) NOT NULL PRIMARY KEY,
	/* ������ �� ��������� ������ */
	ComBase VARCHAR(6) NOT NULL,
    /* ��� ����������� */
    ComCounter VARCHAR(6) NOT NULL,	
	/* ������������ ��������? */
    Description VARCHAR(25) NULL,
    /* ��� ������� ������ */
    ComBase VARCHAR(6) NOT NULL REFERENCES COMMODITY(Title),
    /* ��� ����������� */
    ComCounter VARCHAR(6) NOT NULL REFERENCES COMMODITY(Title),
    /* ������. �������� ������ */
    Precise INT NOT NULL,
    /* ��� � ������ ������� */
	CodeFXI INT NULL,
	/* ���� ������� */
    SwapBuy DECIMAL(8,5),
    /* ���� ������� */
    SwapSell DECIMAL(8,5),
	/* ���� �� ����� � LOT_BY_GROUP... (10 000 - ��-���������) */
	MinVolume INT NULL,
	/* ���� �� ����� � LOT_BY_GROUP... (10 000 - ��-���������) */
	MinStepVolume DECIMAL(16,2) NULL,	
)

CREATE TABLE ACCOUNT_GROUP
(
	/* ���������� ��� */
    Code VARCHAR(10) PRIMARY KEY NOT NULL,
	/* �������� */
	Name VARCHAR(60) NOT NULL,
    /* ���� ��������? */
	IsReal BIT NOT NULL,
    /* ��� ���� ������ - ������� ��-��������� */
	DefaultVirtualDepo INT NULL,
    /* ����� ������� */
	BrokerLeverage DECIMAL(8,2) NOT NULL,
    /* ������� �� */
	MarginCallPercentLevel DECIMAL(8,2) NOT NULL,
    /* ������� �������� */
	StopoutPercentLevel DECIMAL(8, 2) NOT NULL,
    /* ��� ������� (0 - ���, 1 - ������� � ���������, 2 - �����������) */
	MarkupType int NOT NULL,
    /* ������ ��-��������� (���� �� ��������� ��������� ��� ����������� ������) */
	DefaultMarkupPoints FLOAT NOT NULL,
	/* ����������� ����? */
	SwapFree BIT NOT NULL
)
GO

CREATE TABLE LOT_BY_GROUP
(
	[Group] VARCHAR(10) NOT NULL REFERENCES ACCOUNT_GROUP(Code),
	Spot VARCHAR(12) NOT NULL REFERENCES SPOT(Title),
	MinVolume INT NOT NULL,
	MinStepVolume INT NOT NULL
	CONSTRAINT PK_LOT_SPOT_GROUP PRIMARY KEY CLUSTERED
	(
	  [Group], [Spot]
    )
)
GO

CREATE TABLE ACCOUNT
(
    ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),

    Currency VARCHAR(6) NOT NULL REFERENCES COMMODITY(Title),
    /* ��������� ��� ����� �������� ������� */
	Balance DECIMAL(16,2) NOT NULL,
    UsedMargin DECIMAL(16,2) NOT NULL,
    AccountGroup VARCHAR(10) NOT NULL REFERENCES ACCOUNT_GROUP(Code),
    Description NVARCHAR(80) NULL,
	/* ����. �����, ��� ������� �������� ������� ����� ������
	  (����� ������� ��������, � ��������� � ��������� �����) */
	MaxLeverage DECIMAL(8, 2) NOT NULL,
	/* 0 - ������, 1 - ������������ */
	[Status] INT NOT NULL,
	TimeCreated DATETIME NOT NULL,
	TimeBlocked DATETIME NULL
)
GO

CREATE TABLE PLATFORM_USER
(
	ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Title VARCHAR(50) NOT NULL,
	Name VARCHAR(50) NULL,
	Surname VARCHAR(50) NULL,
	Patronym VARCHAR(50) NULL,
	Description VARCHAR(50) NULL,
	Email VARCHAR(50) NULL,
	Phone1 VARCHAR(25) NULL,
	Phone2 VARCHAR(25) NULL,
	Login VARCHAR(25) NOT NULL,
	Password VARCHAR(25) NOT NULL,
	RoleMask INT NOT NULL,
	RegistrationDate DATETIME NOT NULL
)
GO

CREATE TABLE PLATFORM_USER_ACCOUNT
(
	PlatformUser INT NOT NULL REFERENCES PLATFORM_USER(ID),
	Account INT NOT NULL REFERENCES ACCOUNT(ID),
	RightsMask INT NOT NULL,
	CONSTRAINT PK_PLATFORM_USER_ACCOUNT PRIMARY KEY CLUSTERED
	(
	  [PlatformUser], [Account]
    )
)
GO

CREATE TABLE PENDING_ORDER
(
    ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    /* 1 - ����, 2 - ����� */
	PriceSide INT NOT NULL,
	AccountID INT NOT NULL REFERENCES ACCOUNT(ID),
    Symbol VARCHAR(12) NOT NULL REFERENCES SPOT(Title),
    Volume INT NOT NULL,
    PriceFrom DECIMAL(8,5) NOT NULL,
    PriceTo DECIMAL(8,5),
    TimeFrom DATETIME NULL,
    TimeTo DATETIME NULL,
    Side INT NOT NULL,
    Comment VARCHAR(64) NULL,
	ExpertComment VARCHAR(64) NULL,
    Magic INT NULL,
    Stoploss DECIMAL(8,5),
    Takeprofit DECIMAL(8,5),
	PairOCO INT NULL REFERENCES PENDING_ORDER(ID) ON DELETE SET NULL,
	/* �������� 1 */
    TrailLevel1 DECIMAL(8,5) NULL,
    TrailTarget1 DECIMAL(8,5) NULL,
    /* �������� 2 */
    TrailLevel2 DECIMAL(8,5) NULL,
    TrailTarget2 DECIMAL(8,5) NULL,
    /* �������� 3 */
    TrailLevel3 DECIMAL(8,5) NULL,
    TrailTarget3 DECIMAL(8,5) NULL,
    /* �������� 4 */
    TrailLevel4 DECIMAL(8,5) NULL,
    TrailTarget4 DECIMAL(8,5) NULL
)
GO

CREATE TABLE PENDING_ORDER_CLOSED
(
    ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	OrderID INT, 
    /* ������ = 0 - ����� ����������, �������� = 1, ������� = 2, ���������������� = 3 */
	[Status] INT NOT NULL,
	TimeClosed DATETIME NOT NULL,
	PriceClosed DECIMAL(8,5) NOT NULL,
	CloseReason VARCHAR(50) NULL,
	/* 1 - ����, 2 - ����� */
	PriceSide INT NOT NULL,
	AccountID INT NOT NULL REFERENCES ACCOUNT(ID),
    Symbol VARCHAR(12) NOT NULL REFERENCES SPOT(Title),
    Volume INT NOT NULL,
    PriceFrom DECIMAL(8,5) NOT NULL,
    PriceTo DECIMAL(8,5),
    TimeFrom DATETIME NULL,
    TimeTo DATETIME NULL,
    Side INT NOT NULL,
    Comment VARCHAR(64) NULL,
	ExpertComment VARCHAR(64) NULL,
    Magic INT NULL,
    Stoploss DECIMAL(8,5),
    Takeprofit DECIMAL(8,5),
	PairOCO INT NULL REFERENCES PENDING_ORDER(ID),
	Position INT NULL REFERENCES POSITION(ID)
)
GO

/*
������� ���. �������� ��������� ���� - ����� ������ � ���������
*/
CREATE TABLE POSITION
(
    ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    /* ������ */
    /* 0 - �����������, 1 - ������� */
    State INT NOT NULL,
    /* ���������� */
    Symbol VARCHAR(12) NOT NULL REFERENCES SPOT(Title), 
    /* ID �����*/
    AccountID INT NOT NULL REFERENCES ACCOUNT(ID),
    /* ID ������������ ����������� ������ (���� �� ������) */
    PendingOrderID INT NULL REFERENCES PENDING_ORDER_CLOSED(ID),
    /* ����� � ������� ������ */ 
    Volume INT NOT NULL,
    /* ����������, ��������������� ������� ���� ���������� */
    Comment VARCHAR(64) NULL,
    /* ����������, ��������������� ������ ���������� */
    ExpertComment VARCHAR(64) NULL,
    /* ������������ ����� */
    Magic INT NULL,
    /* ���� ����� */
    PriceEnter DECIMAL(8,5) NOT NULL,
    /* ����� ����� */
    TimeEnter DATETIME NOT NULL,
    /* 1 = BUY, -1 = SELL */
    Side INT NOT NULL,
    /* ����-�����, ���� */
    Stoploss DECIMAL(8,5) NULL,
    /* �����-�����, ���� */
    Takeprofit DECIMAL(8,5) NULL,
    /* ������ ����, ����������� ���������� */
    PriceBest DECIMAL(8,5) NULL,
    /* ������ ����, ����������� ���������� */
    PriceWorst DECIMAL(8,5) NULL,       
	
    /* �������� 1 */
    TrailLevel1 DECIMAL(8,5) NULL,
    TrailTarget1 DECIMAL(8,5) NULL,
    /* �������� 2 */
    TrailLevel2 DECIMAL(8,5) NULL,
    TrailTarget2 DECIMAL(8,5) NULL,
    /* �������� 3 */
    TrailLevel3 DECIMAL(8,5) NULL,
    TrailTarget3 DECIMAL(8,5) NULL,
    /* �������� 4 */
    TrailLevel4 DECIMAL(8,5) NULL,
    TrailTarget4 DECIMAL(8,5) NULL,
) 
GO

CREATE TABLE POSITION_CLOSED
(
    /* ID �������� POSITION */
	ID INT PRIMARY KEY NOT NULL,
    /* ������ */        
    /* ���������� */
    Symbol VARCHAR(12) NOT NULL REFERENCES SPOT(Title), 
    /* ID �����*/
    AccountID INT NOT NULL REFERENCES ACCOUNT(ID),
    /* ID ������������ ����������� ������ (���� �� ������) */
    PendingOrderID INT NULL REFERENCES PENDING_ORDER(ID),
    /* ����� � ������� ������ */ 
    Volume INT NOT NULL,
    /* ����������, ��������������� ������� ���� ���������� */
    Comment VARCHAR(64) NULL,
    /* ����������, ��������������� ������ ���������� */
    ExpertComment VARCHAR(64) NULL,
    /* ������������ ����� */
    Magic INT NULL,
    /* ���� ����� */
    PriceEnter DECIMAL(8,5) NOT NULL,
    /* ���� ������, �� �������� ���� */
    PriceExit DECIMAL(8,5) NOT NULL,
    /* ����� ����� */
    TimeEnter DATETIME NOT NULL,
    /* ����� ������ */
    TimeExit DATETIME NOT NULL,
    /* 1 = BUY, -1 = SELL */
    Side INT NOT NULL,
    /* ����-�����, ���� */
    Stoploss DECIMAL(8,5) NULL,
    /* �����-�����, ���� */
    Takeprofit DECIMAL(8,5) NULL,
    /* ������ ����, ����������� ���������� */
    PriceBest DECIMAL(8,5) NULL,
    /* ������ ����, ����������� ���������� */
    PriceWorst DECIMAL(8,5) NULL,
    /* ������� �������� - ������������ */
    ExitReason INT NOT NULL,
    /* ����������� ���� */
    Swap DECIMAL(8, 5) NOT NULL,
    /* ���������, �������, ���� ������� */
    ResultPoints DECIMAL(8, 2) NOT NULL,
    /* ���������, � ������� ������ */
    ResultBase DECIMAL(16, 2) NOT NULL,
	/* ���������, � ������ ���� */
    ResultDepo DECIMAL(16, 2) NOT NULL
) 
GO

CREATE TABLE BALANCE_CHANGE
(
	ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	AccountID INT NOT NULL REFERENCES ACCOUNT(ID),
	/* ���������� = 1, �������� = 2, ��������������� = 3, �������������� = 4 */
	ChangeType INT NOT NULL,
	Amount DECIMAL(16,2) NOT NULL,
	ValueDate DATETIME NOT NULL,
	Description NVARCHAR(60) NULL
)
GO

CREATE TABLE CHANNEL
(
	ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	Name VARCHAR(30) NOT NULL,
	Description VARCHAR(256),
	/* 1 - ������� ���������� �� �������, ����������� � �� �������� */
        Cachable BIT NOT NULL
)
GO

CREATE TABLE CHANNEL_GROUP
(
	[Group] VARCHAR(10) NOT NULL REFERENCES ACCOUNT_GROUP(Code),
	[Channel] INT NOT NULL REFERENCES CHANNEL(ID),
	CONSTRAINT PK_CHANNEL_GROUP PRIMARY KEY CLUSTERED
	(
	  [Group], [Channel]
    )
)
GO

CREATE TABLE BROKER_ORDER
(
	ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	RequestID INT NOT NULL,
	Ticker VARCHAR(12) NOT NULL REFERENCES SPOT(Title), 
	Instrument INT NOT NULL,
	/* ������������ ����� */
    Magic INT NULL,
	Volume INT NOT NULL,
    Side INT NOT NULL,
	OrderPricing INT NOT NULL,
	RequestedPrice DECIMAL(8,5) NULL,
	Slippage DECIMAL(8,5) NULL,
	Dealer VARCHAR(30) NOT NULL REFERENCES DEALER(Code),
	AccountID INT NOT NULL REFERENCES ACCOUNT(ID),
	ClosingPositionID INT NULL, -- REFERENCES POSITION(ID), -- ������ ������ ��� ����������� �����������
	TimeCreated DATETIME NOT NULL,
	/* ����������, ��������������� ������� ���� ���������� */
    Comment VARCHAR(64) NULL,
    /* ����������, ��������������� ������ ���������� */
    ExpertComment VARCHAR(64) NULL
)
GO

CREATE TABLE BROKER_RESPONSE
(
	ID INT PRIMARY KEY NOT NULL IDENTITY(1,1),
	RequestID INT NOT NULL,
	Price DECIMAL(8,5) NULL,
	Swap DECIMAL(8,2) NULL,
	[Status] INT NOT NULL,
	RejectReason INT NULL,
	RejectReasonString VARCHAR(60) NULL,
	ValueDate DATETIME NOT NULL
)
GO

CREATE TABLE DEALER
(
	Code VARCHAR(30) PRIMARY KEY NOT NULL,
	FileName VARCHAR(64) NOT NULL,
	DealerEnabled BIT NOT NULL
)
GO

CREATE TABLE DEALER_GROUP
(
	Dealer VARCHAR(30) NOT NULL REFERENCES DEALER(Code),
	AccountGroup VARCHAR(10) NOT NULL REFERENCES ACCOUNT_GROUP(Code),
	SessionName VARCHAR(128) NULL,
	MessageQueue VARCHAR(128) NULL,
	HedgingAccount VARCHAR(128) NULL,
	SenderCompId VARCHAR(128) NULL,
	CONSTRAINT PK_DEALER_GROUP PRIMARY KEY CLUSTERED
	(
	  Dealer, AccountGroup
    )
)
GO

/* ��������� ��������� �������,
   ���������������� � �� BSEngine.
   ����������� � SignalDealer � � ��������� "��������"
*/
CREATE TABLE TRADE_SIGNAL_CATEGORY
(
   Id INT PRIMARY KEY NOT NULL,
   Title VARCHAR(60) NOT NULL,
   Description VARCHAR(128) NULL
)
GO

/* ���� - �������� ������
   �����: 0x01 - ��������� �������� | 0x02 - ��������� �������� */
CREATE TABLE ACCOUNT_TRADE_SIGNAL
(
	Account INT NOT NULL REFERENCES ACCOUNT(ID),
	Signal INT NOT NULL REFERENCES TRADE_SIGNAL_CATEGORY(Id),
	RightsMask INT NOT NULL,
	ShouldReceiveEmail BIT NULL,
	CONSTRAINT PK_ACCOUNT_TRADE_SIGNAL PRIMARY KEY CLUSTERED
	(
	  [Account], [Signal]
    )
)
GO

CREATE TABLE ACCOUNT_EVENT
(
	Account int NOT NULL REFERENCES ACCOUNT(ID),
	[Time] datetime NOT NULL,
	MsgNum int IDENTITY(1,1) NOT NULL,
	Code int NOT NULL,
	Action int NOT NULL,
	Title nchar(50) NOT NULL,
	Text nvarchar(256) NULL,
	CONSTRAINT PK_ACCOUNT_EVENT PRIMARY KEY CLUSTERED 
	(
		Account ASC,
		Time ASC,
		MsgNum ASC
	)
)
GO

/* �������� �������������� �������
   ������������ ��� ����������� �������� ������� ���� "���-��������" ���� �� � ������������ �������
*/
CREATE TABLE ENGINE_METADATA
(
	ID int PRIMARY KEY NOT NULL IDENTITY(1,1),
	Category VARCHAR(20) NOT NULL,
	Name VARCHAR(60) NOT NULL,
	ParamType VARCHAR(10) NOT NULL,
	Value NVARCHAR(256) NULL
)
GO

/* ������ ��������� �������
   � ���������, ��������� �������
*/
CREATE TABLE DEALER_PARAMETER
(
	Dealer VARCHAR(30) NOT NULL REFERENCES DEALER(Code),
	Category VARCHAR(20) NOT NULL,
	Name VARCHAR(60) NOT NULL,
	ParamType VARCHAR(10) NOT NULL,
	Value NVARCHAR(256) NULL,
	CONSTRAINT PK_DEALER_PARAMETER PRIMARY KEY CLUSTERED 
	(
		Dealer ASC,
		Category ASC,
		Name ASC
	)
)
GO

CREATE TABLE POSITION_MARKUP
(
	/* ������� � POSITION ���� POSITION_CLOSED */
	ID INT PRIMARY KEY NOT NULL,
	/* ��������, ������������ � ���� ����� � ������ �������
	(������������ � ���� �������, ���������� �� ���� �������) */
	MarkupEnter DECIMAL(8,5) NOT NULL,
	/* ��������, ������������ � ���� ������ � ������ ������� */
	MarkupExit DECIMAL(8,5) NOT NULL,
	/* ������, � ������ ������� (����� ���� Markup - Enter, Exit, ����������� �� ����� � ������������
	�� ����������� � ������ �������) */
	MarkupBroker DECIMAL(8, 2) NOT NULL,
	/* ������� ������� � ������ ������� */
	ProfitBroker DECIMAL(16, 2) NOT NULL,
	/* ����� ������������ 
	   0 - book, 1 - ������ �����, 2 - �����-������� */
	HedgingRule INT NOT NULL
)
GO

CREATE TABLE MARKUP_BY_GROUP
(
	/* ���������� (��������� �����) */
	Spot VARCHAR(12) NOT NULL REFERENCES SPOT(Title),
	/* ������ */
	[Group] VARCHAR(10) NOT NULL REFERENCES ACCOUNT_GROUP(Code),
	/* �������� � ����� ����� � ������, � ������ �� */
	MarkupAbs DECIMAL(8,5) NOT NULL,
	CONSTRAINT PK_MARKUP_BY_GROUP PRIMARY KEY CLUSTERED 
	(
		Spot ASC,
		[Group] ASC
	)
)
GO

CREATE TABLE ORDER_BILL
(
	/* ID ������� (��������� ���� �� ��������, ���� �� �������� ����) */
	Position INT PRIMARY KEY NOT NULL,
	/* enum AccountGroup.MarkupType */
	MarkupType INT NOT NULL,
	MarkupEnter FLOAT NOT NULL,
	MarkupExit FLOAT NOT NULL,
	MarkupBroker FLOAT NOT NULL,
	ProfitBroker FLOAT NOT NULL
)
GO

create unique clustered index ind_Primary on QUOTENEW(ticker, date) with ignore_dup_key
GO

CREATE procedure [dbo].[QUOTENEW$Insert]
 @ticker int,
 @date datetime,
 @bid float = 0,
 @ask float = 0
AS
BEGIN 
 SET NOCOUNT ON;
 
 INSERT INTO QUOTENEW (ticker, date, bid, ask) 
  VALUES (@ticker, @date, @bid, @ask);
END
GO

/*
SELECT date, [open], HLC,
 [open] + ((HLC & 0xFF) - 127)/10000.0 as 'high',
 [open] + ((HLC & 0xFF00)/256 - 127)/10000.0 as 'low',
 [open] + ((HLC & 0xFF0000)/65536 - 127)/10000.0 as 'close'
FROM QUOTE 
WHERE ticker=1 AND date BETWEEN '20130428 00:00' AND '20130430 00:00'
*/

select ac.*, (select SUM(
  CASE 
      WHEN ChangeType = 1 THEN Amount
      WHEN ChangeType = 3 THEN Amount 
	  WHEN ChangeType = 5 THEN Amount 
      ELSE -Amount
  END) as 'RealBalance'
from BALANCE_CHANGE 
where AccountID = ac.ID)
from ACCOUNT ac

insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'USD', 'EURUSD', 10000, 10000,          4,          1)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('GBP', 'USD', 'GBPUSD', 10000, 10000,          4,          2)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'JPY', 'USDJPY', 10000, 10000,          2,          3)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'CHF', 'USDCHF', 10000, 10000,          4,          4)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'CAD', 'USDCAD', 10000, 10000,          4,          5)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'JPY', 'EURJPY', 10000, 10000,          4,          6)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('AUD', 'USD', 'AUDUSD', 10000, 10000,          4,          7)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('NZD', 'USD', 'NZDUSD', 10000, 10000,          4,          8)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'GBP', 'EURGBP', 10000, 10000,          4,          9)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('NZD', 'JPY', 'NZDJPY', 10000, 10000,          4,         10)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('GBP', 'AUD', 'GBPAUD', 10000, 10000,          4,         11)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'CHF', 'EURCHF', 10000, 10000,          4,         12)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'CAD', 'EURCAD', 10000, 10000,          4,         13)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'AUD', 'EURAUD', 10000, 10000,          4,         14)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('GBP', 'JPY', 'GBPJPY', 10000, 10000,          4,         15)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('GBP', 'CHF', 'GBPCHF', 10000, 10000,          4,         16)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('CAD', 'JPY', 'CADJPY', 10000, 10000,          4,         17)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('CHF', 'JPY', 'CHFJPY', 10000, 10000,          4,         18)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('AUD', 'CAD', 'AUDCAD', 10000, 10000,          4,         19)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('AUD', 'JPY', 'AUDJPY', 10000, 10000,          4,         20)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('AUD', 'NZD', 'AUDNZD', 10000, 10000,          4,         21)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'NZD', 'EURNZD', 10000, 10000,          4,         22)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('GBP', 'NZD', 'GBPNZD', 10000, 10000,          4,         23)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('GBP', 'CAD', 'GBPCAD', 10000, 10000,          4,         24)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('AUD', 'CHF', 'AUDCHF', 10000, 10000,          4,         25)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'DKK', 'EURDKK', 10000, 10000,          4,         26)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'NOK', 'EURNOK', 10000, 10000,          4,         27)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('EUR', 'SEK', 'EURSEK', 10000, 10000,          4,         28)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'DKK', 'USDDKK', 10000, 10000,          4,         29)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'HKD', 'USDHKD', 10000, 10000,          4,         30)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'SGD', 'USDSGD', 10000, 10000,          4,         31)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'NOK', 'USDNOK', 10000, 10000,          4,         32)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'SEK', 'USDSEK', 10000, 10000,          4,         33)
insert into SPOT (ComBase, ComCounter, Title, MinVolume, MinStepVolume, Precise, CodeFXI) values('USD', 'ZAR', 'USDZAR', 10000, 10000,          4,         34)


---------------------------------------------------------------------------------------------------------------------------------------
-- ������� ������� � ����������
---------------------------------------------------------------------------------------------------------------------------------------
declare @ticker smallint
set @ticker = 101
declare @open float
set @open = (select AVG([open]) from QUOTE where ticker = @ticker)
select @open
select COUNT(*) from QUOTE where ticker = @ticker and 100*ABS([open]-@open)/@open > 50
--select top(50) * from QUOTE where ticker = @ticker and 100*ABS([open]-@open)/@open > 50
--delete from QUOTE where ticker = @ticker and 100*ABS([open]-@open)/@open > 50

---------------------------------------------------------------------------------------------------------------------------------------
-- ��������� ������ �� �����
---------------------------------------------------------------------------------------------------------------------------------------
declare @deals float
declare @transfers float
set @deals = (select SUM(ResultDepo) from POSITION_CLOSED where AccountID = 3)
set @transfers = (select SUM(
  CASE 
      WHEN ChangeType = 1 THEN Amount
      WHEN ChangeType = 2 THEN -Amount 
	  ELSE 0
  END) from BALANCE_CHANGE where AccountID = 3)
  select @deals + @transfers
  
---------------------------------------------------------------------------------------------------------------------------------------
-- �������� ����� � ����������� � ���-��� ������
---------------------------------------------------------------------------------------------------------------------------------------
  select ID, AccountGroup, Currency, Balance, (select count(*) from POSITION_CLOSED where AccountID = ac.ID) as 'Deals',
	  STUFF(
	   (select ',' + 
	      dbo.MakeUserNameWithInitials(usr.Login, usr.Name, usr.Surname, usr.Patronym) +
	      ' [' + CAST(usr.ID AS varchar(20)) + ']'
	    from PLATFORM_USER usr join PLATFORM_USER_ACCOUNT ua
	      on usr.ID = ua.PlatformUser
	    where ac.ID = ua.Account for xml path('')), 1, 1, '') UserNames
	from ACCOUNT ac 
	where exists (select * from POSITION_CLOSED where AccountID = ac.ID)