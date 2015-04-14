//+------------------------------------------------------------------+
//|                                        UniFeeder Syntetic Quotes |
//|                 Copyright � 2001-2005, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#pragma once

#define MAX_TICKS 128
//---- Tick structure
struct TickInfo
  {
   time_t            time;                // tick time
   char              security[16];        // symbol name
   double            bid,ask;             // prices
  };
//---- ���� ���������
enum { OPERAND_SYMBOL, OPERAND_VALUE };
//---- �������� ��������
struct SynteticOperand
  {
   int               type;                // ��� ��������
   char              symbol[16];          // ������ ��������
   double            value;               // �������� ��������
   double            bid,ask;             // ������� �������� �� �������
  };
//---- �������� �������������� �����������
struct SynteticSymbol
  {
   char              name[16];            // ��� �������������� �����������
   //---- ������ � ��������� ����������
   SynteticOperand   left;                // ����� �������
   SynteticOperand   right;               // ������ �������
   char              operation;           // �������� (+,-,*,/)
  };
//+------------------------------------------------------------------+
//| ���� �������� � ������� ������������� ������������               |
//+------------------------------------------------------------------+
class CSynteticBase
  {
private:
   SynteticSymbol   *m_syntetics;         // ������ ������������� ������������
   int               m_syntetics_total;   // ���-�� ����. ������������
   int               m_syntetics_max;     // �������� ������
   TickInfo          m_ticks[MAX_TICKS];  // ����� ���������
   int               m_ticks_total;       // ����� ���������
   int               m_ticks_current;     // ������� ������� � ����������

public:
                     CSynteticBase();
                    ~CSynteticBase();

   void              Load(void);
   void              AddQuotes(const FeedData *data);
   int               GetTicks(FeedData *data);

private:
   void              AddSynteticSymbol(const SynteticSymbol *sym);
   void              RecalculateSymbol(const SynteticSymbol *cs);
   inline double     CalculateOpeation(char op,double left,double right) const;
  };
//+------------------------------------------------------------------+
