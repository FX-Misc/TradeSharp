//+------------------------------------------------------------------+
//|                                        MetaTrader Virtual Dealer |
//|                 Copyright � 2001-2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#include "..\stdafx.h"
//----
static const double ExtDecimalArray[9] ={ 1.0, 10.0, 100.0, 1000.0, 10000.0,100000.0, 1000000.0, 10000000.0, 10000000.0 };  // ������������� ������� 10
//+------------------------------------------------------------------+
//|  ������������� �� ������ ����������� ��������� ���.���������?    |
//+------------------------------------------------------------------+
int CheckTemplate(char* expr,char* tok_end,char* group,char* prev,int* deep)
  {
   char  tmp=0;
   char *lastwc,*prev_tok,*cp;
//---- �������� ������� ��������
   if((*deep)++>=10) return(FALSE);
//---- ���������� ������� *
   while(*expr=='*' && expr!=tok_end) expr++;
   if(expr==tok_end) return(TRUE);
//---- ���� ��������� ��������� ��� �����
   lastwc=expr;
   while(*lastwc!='*' && *lastwc!=0) lastwc++;
//---- �������� ������������ ������
   if((tmp=*(lastwc))!=0) // ����� �� ��������� � ������?
     {
      tmp=*(lastwc);*(lastwc)=0;
      if((prev_tok=strstr(group,expr))==NULL) { if(tmp!=0) *(lastwc)=tmp; return(FALSE); }
      *(lastwc)=tmp;
     }
   else // ����� ���������...
     {
      //---- ���������
      cp=group+strlen(group);
      for(;cp>=group;cp--)
        if(*cp==expr[0] && strcmp(cp,expr)==0)
          return(TRUE);
      return(FALSE);
     }
//---- ������� �������?
   if(prev!=NULL &&  prev_tok<=prev) return(FALSE);
   prev=prev_tok;
//----
   group=prev_tok+(lastwc-expr-1);
//---- ����� �� �����?
   if(lastwc!=tok_end) return CheckTemplate(lastwc,tok_end,group,prev,deep);
//----
   return(TRUE);
  }
//+------------------------------------------------------------------+
//|  ������������� �� ������ ������ �� ��������?                     |
//+------------------------------------------------------------------+
int CheckGroup(char* grouplist, const char *_group)
{
	if(grouplist==NULL || _group==NULL) return(FALSE);

	char *group = new char [256];
	strcpy(group, _group);
	// ��������
   
	// ���������� �� ���� �������
	char *tok_start=grouplist,end;
	int  res=TRUE,deep=0,normal_mode;
	while(*tok_start!=0)
    {
      //---- ��������� �������
      while(*tok_start!=0 && *tok_start==',') tok_start++;
      //----
      if(*tok_start=='!') { tok_start++; normal_mode=FALSE; }
      else                 normal_mode=TRUE;
      //---- ������ ������� ������
      char *tok_end=tok_start;
      while(*tok_end!=',' && *tok_end!=0) tok_end++;
      end=*tok_end; *tok_end=NULL;
      //----
      char *tp=tok_start;
      char *gp=group, *prev=NULL;
      //---- �������� �� ������
      res=TRUE;
      while(tp!=tok_end && *gp!=NULL)
        {
         //---- ����� ��������? ��������� ��� �������
         if(*tp=='*')
           {
            if((res=CheckTemplate(tp,tok_end,gp,prev,&deep))==TRUE)
              {
               *tok_end=end;
			   delete []group;
               return(normal_mode);
              }
            break;
           }
         //---- ������ ���������
         if(*tp!=*gp) { *tok_end=end; res=FALSE; break; }
         tp++; gp++;
        }
      //---- ���������������
      *tok_end=end;
      if(*gp==NULL && tp==tok_end && res==TRUE) 
	  {
		  delete []group;
		  return(normal_mode);
	  }
      //---- ������� � ���������� ������
      if(*tok_end==0) break;
      tok_start=tok_end+1;
     }
//----
   delete []group;
   return(FALSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
