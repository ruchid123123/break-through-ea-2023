enum Option1      {Expert = 10,Moderate = 20,Safe = 30  };

//------------------
extern string 注释 = "专做数据行情超短线";
extern string Configuration="==== Setting ===="  ;
extern int   magicnumber=333  ;//和熔断机制相关，尽量为333
extern bool AutoLot=true  ;
extern  Option1  AutoLotMode=20  ;
extern double FixLot=0.01  ;
extern string OrderSetting="=== Leave as Default ===="  ;
extern int   stoploss=162  ;  // (止损)
extern int   takeprofit=1300  ;   // (止盈)
extern int   step=162  ;  //(挂单距离)
extern string Config="==== Time Filter ===="  ;
extern int   StartHour=1  ;   // (时间过滤)
extern int   StopHour=23  ;   // (时间过滤)

// +++++++++++++++ 新增的熔斷機制設置 +++++++++++++++
extern string LossSetting = "==== Stop on Loss Setting ====";
extern bool   PauseOnLoss_Enabled = true;     // 開啟/關閉 虧損後暫停功能
extern int    PauseDuration_Minutes = 1;     // 暫停時間（分鐘）
extern bool   DeletePendingsOnLoss = true;    // 虧損時是否刪除所有掛單

// +++++++++++++++ 點差顯示設置 +++++++++++++++
extern string SpreadSetting = "==== Spread Display Setting ====";
extern bool   ShowSpread = true;              // 是否顯示點差
extern int    SpreadFontSize = 20;            // 點差顯示字體大小
extern color  SpreadColor = Red;              // 點差顯示顏色
// +++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++

  double    zong_1_do = 0.3;
  double    zong_2_do = AutoLotMode * 100;
  int       zong_3_in = 250;
  int       zong_4_in = 200;
  int       zong_5_in = 100;
  int       zong_6_in = 50;
  int       zong_7_in = 100;
  int       zong_8_in = 50;
  int       zong_9_in = 800;
  int       zong_10_in = 100;
  int       zong_11_in = 50;
  
  int       xt = 0;
  double    zong_18_do = 0.0;
  int       zong_19_in = 0;
  int       zong_20_in = 10;
  int       zong_21_in = 0;
  int       zong_22_in = 0;
  int       zong_23_in = 1;//挂单频率，默认为5
  int       zong_24_in = 30;//价格变动，默认为30
  double    zong_25_do = 0.0;
  double    zong_26_do = 0.0;
  int       LotDigits = 0;
  double    lots = 0.0;

// +++++++++++++++ 新增的狀態變量 +++++++++++++++
datetime pauseEndTime = 0; // 用於記錄暫停結束的時間戳
datetime lastLossTime = 0; // 記錄最後一次亏損的時間，避免重複觸發

// +++++++++++++++ 點差顯示變量 +++++++++++++++
#define SPREAD_OBJ_NAME "SpreadDisplayObj"
// ++++++++++++++++++++++++++++++++++++++++++++++++

 int init()
 {
  double    Local_2_do;
  double    Local_3_do;
//----- -----
 double     tmp_do_1;
 double     tmp_do_2;

 if ( ( Digits() == 3 || Digits() == 5 ) )
 {
   xt = 10 ;
 }
 else
 {
   xt = 1 ;
 }
 zong_18_do = MarketInfo(Symbol(),14) ;
 tmp_do_1 = zong_18_do / xt;
 if ( stoploss <= tmp_do_1 )
 {
   tmp_do_1 = tmp_do_1;
 }
 else
 {
   tmp_do_1 = stoploss;
 }
 stoploss = tmp_do_1 ;
 if ( takeprofit <= zong_18_do / xt )
 {
   tmp_do_2 = zong_18_do / xt;
 }
 else
 {
   tmp_do_2 = takeprofit;
 }
 takeprofit = tmp_do_2 ;
 Local_2_do = MarketInfo(Symbol(),10) ;
 Local_3_do = MarketInfo(Symbol(),9) ;
 zong_26_do = MarketInfo(Symbol(),24) ;
 if ( zong_26_do==1.0 )
 {
   LotDigits = 0 ;
 }
 if ( zong_26_do==0.1 )
 {
   LotDigits = 1 ;
 }
 if ( zong_26_do==0.01 )
 {
   LotDigits = 2 ;
 }
 if ( zong_26_do==0.001 )
 {
   LotDigits = 3 ;
 }
 if ( zong_26_do==0.0001 )
 {
   LotDigits = 4 ;
 }
 if ( zong_26_do==0.00001 )
 {
   LotDigits = 5 ;
 }
 zong_25_do = (Local_2_do - Local_3_do) / Point() / xt ;
 
 // 初始化點差顯示
 if (ShowSpread)
 {
   ShowSpreadOnChart();
 }
 
 return(0);
 }
//init <<==--------   --------

int start()
{
    int       Local_2_in;
    double    Local_3_do;
    double    Local_4_do;
    double    Local_5_do;
    double    Local_6_do;
    int       Local_7_in;
    int       Local_8_in;
    double    Local_9_do;
    int       Local_10_in;
    double    Local_11_do;
    int       Local_12_in;
    double    Local_13_do;
    double    Local_14_do;
    int       Local_15_in;
    int       Local_16_in;
    int       i;
    long      remainingSeconds = 0;

    // ================== 新版熔斷機制: 檢查最近15分鐘內的虧損 ==================
    if (PauseOnLoss_Enabled)
    {
        // --- 1. 檢查當前是否已處於暫停狀態 ---
        if (TimeCurrent() < pauseEndTime)
        {
            if (DeletePendingsOnLoss)
            {
                DeleteAllPendingOrders();
            }
            remainingSeconds = pauseEndTime - TimeCurrent();
            Comment("EA PAUSED due to a recent loss. \n",
                    "Resuming in ", remainingSeconds / 60, " min ", remainingSeconds % 60, " sec.");
            return(0); // 處於暫停期，直接退出
        }

        // --- 2. 如果未處於暫停狀態，則檢查是否有新的虧損訂單 ---
        for (int k = OrdersHistoryTotal() - 1; k >= 0; k--)
        {
            if (!OrderSelect(k, SELECT_BY_POS, MODE_HISTORY)) continue;

            // 篩選出由本EA、在本圖表、且虧損的訂單
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicnumber && OrderProfit() < 0.0)
            {
                // **關鍵修正**: 只有當這是一個新的虧損訂單才觸發暫停
                if (OrderCloseTime() > lastLossTime)
                {
                    Print("New loss detected on ticket #", OrderTicket(), " at ", TimeToString(OrderCloseTime()));
                    Print("Pausing EA for ", PauseDuration_Minutes, " minutes from now.");

                    // 記錄這次虧損的時間，避免重複觸發
                    lastLossTime = OrderCloseTime();
                    
                    // 設置一個從“現在”開始的暫停結束時間
                    pauseEndTime = TimeCurrent() + PauseDuration_Minutes * 60;

                    if (DeletePendingsOnLoss)
                    {
                        DeleteAllPendingOrders();
                    }

                    // 顯示暫停信息並立即退出，開始倒數計時
                    remainingSeconds = pauseEndTime - TimeCurrent();
                    Comment("EA PAUSED due to a recent loss. \n",
                            "Resuming in ", remainingSeconds / 60, " min ", remainingSeconds % 60, " sec.");
                    return(0);
                }
                break; // 找到最近的虧損訂單後就停止搜索
            }
        }
    }
    // ================== 新版熔斷機制結束 ==================

    // 如果EA未被暫停，則執行以下正常的交易邏輯
    Display_Info();
    
    // 更新點差顯示
    if (ShowSpread)
    {
        ShowSpreadOnChart();
    }
    
    Local_2_in = 0 ;
    Local_3_do = 0.0 ;
    Local_4_do = 0.0 ;
    Local_5_do = 0.0 ;
    Local_6_do = 0.0 ;
    Local_7_in = 0 ;
    Local_8_in = 0 ;
    Local_9_do = 0.0 ;
    Local_10_in = 0 ;
    Local_11_do = 0.0 ;
    Local_12_in = 0 ;
    Local_13_do = 0.0 ;
    Local_14_do = 0.0 ;
    Local_15_in = 0 ;
    Local_16_in = 0 ;

    lots = NormalizeDouble(LotsOptimized ( ),LotDigits) ;
    zong_19_in = MarketInfo(Symbol(),14) ;
    for (i = 0 ; i < OrdersTotal() ; i = i + 1)
    {
      if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || magicnumber != OrderMagicNumber() )   continue;
      Local_2_in = OrderType() ;
      Local_3_do = NormalizeDouble(OrderStopLoss(),Digits()) ;
      Local_4_do = NormalizeDouble(OrderOpenPrice(),Digits()) ;
      Local_5_do = Local_3_do ;
      if ( Local_2_in == 0 )
      {
        Local_7_in = Local_7_in + 1;
        if ( Local_3_do<Local_4_do )
        {
          Local_15_in = zong_4_in ;
          Local_16_in = zong_3_in ;
        }
        else
        {
          if ( Local_3_do - Local_4_do<=NormalizeDouble(zong_4_in * Point(),Digits()) )
          {
            Local_15_in = zong_6_in ;
            Local_16_in = zong_5_in ;
          }
          else
          {
            if ( Local_3_do - Local_4_do<=NormalizeDouble(zong_9_in * Point(),Digits()) )
            {
              Local_15_in = zong_8_in ;
              Local_16_in = zong_7_in ;
            }
            else
            {
              Local_15_in = zong_11_in ;
              Local_16_in = zong_10_in ;
            }
          }
        }
        Local_13_do = NormalizeDouble(Local_15_in * Point() + Local_3_do,Digits()) ;
        Local_14_do = NormalizeDouble(Bid - Local_16_in * Point(),Digits()) ;
        if ( Local_14_do>Local_3_do && Local_13_do<=NormalizeDouble(Bid - zong_19_in * Point(),Digits()) )
        {
          Local_5_do = Local_13_do ;
        }
        if ( Local_5_do>Local_3_do )
        {
          if ( !(OrderModify(OrderTicket(),Local_4_do,Local_5_do,0.0,0,White)) )
          {
            Print("Error ",GetLastError(),"   Order Modify Buy   SL ",Local_3_do,"->",Local_5_do);
          }
          else
          {
            Print("Order Buy Modify   SL ",Local_3_do,"->",Local_5_do);
          }
        }
      }
      if ( Local_2_in == 1 )
      {
        Local_8_in = Local_8_in + 1;
        if ( Local_3_do>Local_4_do )
        {
          Local_15_in = zong_4_in ;
          Local_16_in = zong_3_in ;
        }
        else
        {
          if ( Local_3_do - Local_4_do>=NormalizeDouble(zong_4_in * Point(),Digits()) )
          {
            Local_15_in = zong_6_in ;
            Local_16_in = zong_5_in ;
          }
          else
          {
            if ( Local_3_do - Local_4_do>=NormalizeDouble(zong_9_in * Point(),Digits()) )
            {
              Local_15_in = zong_8_in ;
              Local_16_in = zong_7_in ;
            }
            else
            {
              Local_15_in = zong_11_in ;
              Local_16_in = zong_10_in ;
            }
          }
        }
        Local_13_do = NormalizeDouble(Local_3_do - Local_15_in * Point(),Digits()) ;
        Local_14_do = NormalizeDouble(Local_16_in * Point() + Ask,Digits()) ;
        if ( Local_14_do<Local_3_do && Local_13_do>=NormalizeDouble(zong_19_in * Point() + Ask,Digits()) )
        {
          Local_5_do = Local_13_do ;
        }
        if ( Local_5_do<Local_3_do )
        {
          if ( !(OrderModify(OrderTicket(),Local_4_do,Local_5_do,0.0,0,White)) )
          {
            Print("Error ",GetLastError(),"   Order Modify Buy   SL ",Local_3_do,"->",Local_5_do);
          }
          else
          {
            Print("Order Buy Modify   SL ",Local_3_do,"->",Local_5_do);
          }
        }
      }
      if ( Local_2_in == 4 )
      {
        Local_9_do = Local_4_do ;
        Local_10_in = OrderTicket() ;
        if ( !(dTime ( )) )
        {
          if ( !(OrderDelete(Local_10_in,0xFFFFFFFF)) )
          {
            Print("Error ",GetLastError(),"   Order Delete ");
          }
          else
          {
            Print("Order Delete ");
          }
        }
      }
      if ( Local_2_in != 5 )   continue;
      Local_11_do = Local_4_do ;
      Local_12_in = OrderTicket() ;
      if ( dTime ( ) )   continue;

      if ( !(OrderDelete(Local_12_in,0xFFFFFFFF)) )
      {
        Print("Error ",GetLastError(),"   Order Delete ");
         continue;
      }
      Print("Order Delete ");

    }
    if ( Local_7_in + Local_10_in == 0 && dTime ( ) )
    {
      if ( stoploss - step >= zong_19_in && stoploss != 0 )
      {
        Local_5_do = NormalizeDouble(Ask - (stoploss - step) * Point(),Digits()) ;
      }
      else
      {
        Local_5_do = 0.0 ;
      }
      if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
      {
        Local_6_do = NormalizeDouble((takeprofit + step) * Point() + Ask,Digits()) ;
      }
      else
      {
        Local_6_do = 0.0 ;
      }
      if ( OrderSend(Symbol(),OP_BUYSTOP,lots,NormalizeDouble(step * Point() + Ask,Digits()),zong_20_in,Local_5_do,Local_6_do,注释,magicnumber,0,0xFFFFFFFF) != -1 )
      {
        zong_21_in = TimeCurrent() ;
      }
    }
    if ( Local_8_in + Local_12_in == 0 && dTime ( ) )
    {
      if ( stoploss - step >= zong_19_in && stoploss != 0 )
      {
        Local_5_do = NormalizeDouble((stoploss - step) * Point() + Bid,Digits()) ;
      }
      else
      {
        Local_5_do = 0.0 ;
      }
      if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
      {
        Local_6_do = NormalizeDouble(Bid - (takeprofit + step) * Point(),Digits()) ;
      }
      else
      {
        Local_6_do = 0.0 ;
      }
      if ( OrderSend(Symbol(),OP_SELLSTOP,lots,NormalizeDouble(Bid - step * Point(),Digits()),zong_20_in,Local_5_do,Local_6_do,注释,magicnumber,0,0xFFFFFFFF) != -1 )
      {
        zong_22_in = TimeCurrent() ;
      }
    }
    if ( Local_10_in != 0 && dTime ( ) && zong_21_in <  TimeCurrent() - zong_23_in && (MathAbs(NormalizeDouble(step * Point() + Ask,Digits()) - Local_9_do)) / Point()>zong_24_in )
    {
      if ( stoploss - step >= zong_19_in && stoploss != 0 )
      {
        Local_5_do = NormalizeDouble(Ask - (stoploss - step) * Point(),Digits()) ;
      }
      else
      {
        Local_5_do = 0.0 ;
      }
      if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
      {
        Local_6_do = NormalizeDouble((takeprofit + step) * Point() + Ask,Digits()) ;
      }
      else
      {
        Local_6_do = 0.0 ;
      }
      if ( OrderModify(Local_10_in,NormalizeDouble(step * Point() + Ask,Digits()),Local_5_do,Local_6_do,0,0xFFFFFFFF) )
      {
        zong_21_in = TimeCurrent() ;
      }
    }
    if ( Local_12_in != 0 && dTime ( ) && zong_22_in <  TimeCurrent() - zong_23_in && (MathAbs(NormalizeDouble(Bid - step * Point(),Digits()) - Local_11_do)) / Point()>zong_24_in )
    {
      if ( stoploss - step >= zong_19_in && stoploss != 0 )
      {
        Local_5_do = NormalizeDouble((stoploss - step) * Point() + Bid,Digits()) ;
      }
      else
      {
        Local_5_do = 0.0 ;
      }
      if ( takeprofit + step >= zong_19_in && takeprofit != 0 )
      {
        Local_6_do = NormalizeDouble(Bid - (takeprofit + step) * Point(),Digits()) ;
      }
      else
      {
        Local_6_do = 0.0 ;
      }
      if ( OrderModify(Local_12_in,NormalizeDouble(Bid - step * Point(),Digits()),Local_5_do,Local_6_do,0,0xFFFFFFFF) )
      {
        zong_22_in = TimeCurrent() ;
      }
    }
    return(0);
}
//start <<==--------   --------

// +++++++++++++++ 新增: 刪除所有掛單的輔助函數 +++++++++++++++
void DeleteAllPendingOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // 確保是本EA的掛單
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicnumber)
            {
                if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
                {
                    if (!OrderDelete(OrderTicket()))
                    {
                        Print("Error deleting pending order #", OrderTicket(), ": ", GetLastError());
                    }
                    else
                    {
                        Print("Pending order #", OrderTicket(), " deleted due to loss pause.");
                    }
                }
            }
        }
    }
}
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++

int deinit()
{
 // 删除點差顯示對象
 ObjectDelete(SPREAD_OBJ_NAME);
 
 ObjectsDeleteAll(-1,-1);
 return(0);
}
//deinit <<==--------   --------
 void Display_Info()
 {
  int       Local_1_in;
  string    Local_2_st;
  int       Local_3_in;
//----- -----

 if ( Seconds() >= 0 && Seconds() <  10 )
 {
   Local_1_in = 8388608 ;
 }
 if ( Seconds() >= 10 && Seconds() <  20 )
 {
   Local_1_in = 0 ;
 }
 if ( Seconds() >= 20 && Seconds() <  30 )
 {
   Local_1_in = 2139610 ;
 }
 if ( Seconds() >= 30 && Seconds() <  40 )
 {
   Local_1_in = 25600 ;
 }
 if ( Seconds() >= 40 && Seconds() <  50 )
 {
   Local_1_in = 2970272 ;
 }
 if ( Seconds() >= 50 && Seconds() <= 59 )
 {
   Local_1_in = 8519755 ;
 }
 Local_2_st = "-------------------------------------------" ;
 Local_3_in = 0 ;
 if ( Seconds() >= 0 && Seconds() <  10 )
 {
   Local_3_in = 8519755 ;
 }
 if ( Seconds() >= 10 && Seconds() <  20 )
 {
   Local_3_in = 16119285 ;
 }
 if ( Seconds() >= 20 && Seconds() <  30 )
 {
   Local_3_in = 25600 ;
 }
 if ( Seconds() >= 30 && Seconds() <  40 )
 {
   Local_3_in = 2970272 ;
 }
 if ( Seconds() >= 40 && Seconds() <  50 )
 {
   Local_3_in = 2139610 ;
 }
 if ( Seconds() >= 50 && Seconds() <= 59 )
 {
   Local_3_in = 8388608 ;
 }
 }
//Display_Info <<==--------   --------
 void LABEL( string Para_0_st,string Para_1_st,int Para_2_in,int Para_3_in,int Para_4_in,color Para_5_co,int Para_6_in,string Para_7_st)
 {
 //if ( ObjectFind(Para_0_st) <  0 )
 {
 //  ObjectCreate(Para_0_st,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0);
 }
// ObjectSetText(Para_0_st,Para_7_st,Para_2_in,Para_1_st,Para_5_co);
// ObjectSet(Para_0_st,OBJPROP_CORNER,Para_6_in);
// ObjectSet(Para_0_st,OBJPROP_XDISTANCE,Para_3_in);
 //ObjectSet(Para_0_st,OBJPROP_YDISTANCE,Para_4_in);
 }
//LABEL <<==--------   --------

// *** FIX: 恢復被遺漏的 dTime() 函數 ***
bool dTime()
{
 bool      ans = false;
//----- -----
 if ( Hour() >= StartHour && Hour() <  StopHour )
 {
   ans = true ;
 }
 return(ans);
}
//dTime <<==--------   --------

// +++ MODIFICATION: 直接在此函數內部完成四舍五入和所有安全檢查 +++
double LotsOptimized()
{
  double    raw_lot; // 計算出的原始理論手數
  
  // 1. 根據 AutoLot 設置，確定原始手數
  if (AutoLot)
  {
    raw_lot = AccountBalance() / zong_2_do * zong_1_do;
  }
  else
  {
    raw_lot = FixLot;
  }

  // 2. 獲取交易品種的規則
  double lot_step = MarketInfo(Symbol(), MODE_LOTSTEP);
  double min_lot  = MarketInfo(Symbol(), MODE_MINLOT);
  double max_lot  = MarketInfo(Symbol(), MODE_MAXLOT);

  // 3. 核心四舍五入邏輯
  //    (e.g., MathRound(0.129 / 0.01) * 0.01  ->  MathRound(12.9) * 0.01  ->  13 * 0.01  ->  0.13)
  double final_lot = MathRound(raw_lot / lot_step) * lot_step;

  // 4. 安全鉗制 (Clamping)
  if (final_lot < min_lot)
  {
    final_lot = min_lot;
  }
  if (final_lot > max_lot)
  {
    final_lot = max_lot;
  }

  // 5. 返回最終處理好的、安全且精確的手數
  return(final_lot);
}
//<<==LotsOptimized <<==

// +++++++++++++++ 點差顯示功能 +++++++++++++++
void ShowSpreadOnChart()
{
    static double spread;
    
    spread = MarketInfo(Symbol(), MODE_SPREAD);
    
    DrawSpreadOnChart(spread);
}

void DrawSpreadOnChart(double spread)
{
    string s = "点差: " + DoubleToStr(spread, 0) + " 点";
    
    if(ObjectFind(SPREAD_OBJ_NAME) < 0)
    {
        ObjectCreate(SPREAD_OBJ_NAME, OBJ_LABEL, 0, 0, 0);
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_CORNER, 2);        // 左下角
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_YDISTANCE, 12);    // Y距離
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_XDISTANCE, 3);     // X距離
        ObjectSetText(SPREAD_OBJ_NAME, s, SpreadFontSize, "FixedSys", SpreadColor);
    }
    else
    {
        // 更新文本內容和格式
        ObjectSetText(SPREAD_OBJ_NAME, s, SpreadFontSize, "FixedSys", SpreadColor);
    }
    
    WindowRedraw();
}
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++