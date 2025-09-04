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

// +++++++++++++++ 新增的熔断机制设置 +++++++++++++++
extern string LossSetting = "==== Stop on Loss Setting =====";
extern bool   PauseOnLoss_Enabled = true;     // 开启/关闭 亏损后暂停功能
extern int    PauseDuration_Minutes = 1;     // 暂停时间（分钟）
extern bool   DeletePendingsOnLoss = true;    // 亏损时是否删除所有挂单

// +++++++++++++++ 点差显示设置 +++++++++++++++
extern string SpreadSetting = "==== Spread Display Setting ====";
extern bool   ShowSpread = true;              // 是否显示点差
extern int    SpreadFontSize = 16;            // 点差显示字体大小
extern color  SpreadColor = Red;              // 点差显示颜色

// +++++++++++++++ 手动停止按钮设置 +++++++++++++++
extern string ManualStopSetting = "==== Manual Stop Button Setting ====";
extern bool   ShowStopButton = true;          // 是否显示停止按钮
extern int    StopButtonFontSize = 14;        // 停止按钮字体大小
extern color  StopButtonColor = Red;          // 停止按钮颜色
extern color  StopButtonBgColor = White;      // 停止按钮背景颜色
extern color  ContinueButtonColor = Green;    // 继续按钮颜色
extern color  ContinueButtonBgColor = LightGreen; // 继续按钮背景颜色
extern bool   ShowStatusMessages = false;         // 是否显示状态提示信息
// +++++++++++++++++++++++++++++++++++++++++++++++++++++
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

// +++++++++++++++ 新增的状态变量 +++++++++++++++
datetime pauseEndTime = 0; // 用于记录暂停结束的时间戳
datetime lastLossTime = 0; // 记录最后一次亏损的时间，避免重复触发
bool isCircuitBreakerActive = false; // 熔断机制激活状态

// +++++++++++++++ 点差显示变量 +++++++++++++++
#define SPREAD_OBJ_NAME "SpreadDisplayObj"

// +++++++++++++++ 手动停止按钮变量 +++++++++++++++
#define STOP_BUTTON_NAME "ManualStopButton"
bool isEAStopped = false;                     // EA手动停止状态
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
 
 // 初始化点差显示
 if (ShowSpread)
 {
   ShowSpreadOnChart();
 }
 
 // 初始化手动停止按钮
 if (ShowStopButton)
 {
   CreateStopButton();
 }
 
 return(0);
 }
//init <<==--------   --------

int start()
{
    // ================== 手动停止检查 ==================
    // 检查是否按下了停止按钮
    if (ShowStopButton)
    {
        CheckStopButtonClick();
    }
    
    // 如果EA已被手动停止，停止所有交易逻辑
    if (isEAStopped)
    {
        if (ShowStatusMessages)
        {
            Comment("⛔ EA 已手动停止\n所有挂单已被删除\n点击绿色按钮可继续运行");
        }
        return(0);
    }
    // ================== 手动停止检查结束 ==================
    
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

    // ================== 新版熔断机制: 检查最近15分钟内的亏损 ==================
    if (PauseOnLoss_Enabled)
    {
        // --- 1. 检查当前是否已处于暂停状态 ---
        if (TimeCurrent() < pauseEndTime)
        {
            if (DeletePendingsOnLoss)
            {
                DeleteAllPendingOrders();
            }
            
            // 设置熔断机制激活状态，与手动停止同步
            if (!isCircuitBreakerActive)
            {
                isCircuitBreakerActive = true;
                isEAStopped = true; // 与手动停止按钮同步
            }
            
            remainingSeconds = pauseEndTime - TimeCurrent();
            if (ShowStatusMessages)
            {
                Comment("[CIRCUIT BREAKER] 熔断机制激活 - 亏损后自动暂停\n",
                        "剩余时间: ", remainingSeconds / 60, " 分 ", remainingSeconds % 60, " 秒\n",
                        "点击绿色按钮可继续运行");
            }
            return(0); // 处于暂停期，直接退出
        }
        else if (isCircuitBreakerActive)
        {
            // 熔断时间到了，自动恢复运行
            isCircuitBreakerActive = false;
            isEAStopped = false; // 与手动停止按钮同步
            Print("熔断机制暂停时间结束，自动恢复交易");
        }

        // --- 2. 如果未处于暂停状态，则检查是否有新的亏损订单 ---
        for (int k = OrdersHistoryTotal() - 1; k >= 0; k--)
        {
            if (!OrderSelect(k, SELECT_BY_POS, MODE_HISTORY)) continue;

            // 筛选出由本EA、在本图表、且亏损的订单
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicnumber && OrderProfit() < 0.0)
            {
                // **关键修正**: 只有当这是一个新的亏损订单才触发暂停
                if (OrderCloseTime() > lastLossTime)
                {
                    Print("New loss detected on ticket #", OrderTicket(), " at ", TimeToString(OrderCloseTime()));
                    Print("Pausing EA for ", PauseDuration_Minutes, " minutes from now.");

                    // 记录这次亏损的时间，避免重复触发
                    lastLossTime = OrderCloseTime();
                    
                    // 设置一个从“现在”开始的暂停结束时间
                    pauseEndTime = TimeCurrent() + PauseDuration_Minutes * 60;
                    
                    // 激活熔断机制，与手动停止按钮同步
                    isCircuitBreakerActive = true;
                    isEAStopped = true;

                    if (DeletePendingsOnLoss)
                    {
                        DeleteAllPendingOrders();
                    }

                    // 显示暂停信息并立即退出，开始倒数计时
                    remainingSeconds = pauseEndTime - TimeCurrent();
                    if (ShowStatusMessages)
                    {
                        Comment("[CIRCUIT BREAKER] 熔断机制激活 - 亏损后自动暂停\n",
                                "剩余时间: ", remainingSeconds / 60, " 分 ", remainingSeconds % 60, " 秒\n",
                                "点击绿色按钮可继续运行");
                    }
                    return(0);
                }
                break; // 找到最近的亏损订单后就停止搜索
            }
        }
    }
    // ================== 新版熔断机制结束 ==================

    // 如果EA未被暂停，则执行以下正常的交易逻辑
    Display_Info();
    
    // 更新点差显示
    if (ShowSpread)
    {
        ShowSpreadOnChart();
    }
    
    // 更新停止按钮显示状态
    if (ShowStopButton)
    {
        CreateStopButton(); // 确保按钮显示状态正确
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

// +++++++++++++++ 新增: 删除所有挂单的辅助函数 +++++++++++++++
void DeleteAllPendingOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // 确保是本EA的挂单
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
 // 删除点差显示对象
 ObjectDelete(SPREAD_OBJ_NAME);
 
 // 删除手动停止按钮对象
 ObjectDelete(STOP_BUTTON_NAME);
 
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

// *** FIX: 恢复被遗漏的 dTime() 函数 ***
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

// +++ MODIFICATION: 直接在此函数内部完成四舍五入和所有安全检查 +++
double LotsOptimized()
{
  double    raw_lot; // 计算出的原始理论手数
  
  // 1. 根据 AutoLot 设置，确定原始手数
  if (AutoLot)
  {
    raw_lot = AccountBalance() / zong_2_do * zong_1_do;
  }
  else
  {
    raw_lot = FixLot;
  }

  // 2. 获取交易品种的规则
  double lot_step = MarketInfo(Symbol(), MODE_LOTSTEP);
  double min_lot  = MarketInfo(Symbol(), MODE_MINLOT);
  double max_lot  = MarketInfo(Symbol(), MODE_MAXLOT);

  // 3. 核心四舍五入逻辑
  //    (e.g., MathRound(0.129 / 0.01) * 0.01  ->  MathRound(12.9) * 0.01  ->  13 * 0.01  ->  0.13)
  double final_lot = MathRound(raw_lot / lot_step) * lot_step;

  // 4. 安全钳制 (Clamping)
  if (final_lot < min_lot)
  {
    final_lot = min_lot;
  }
  if (final_lot > max_lot)
  {
    final_lot = max_lot;
  }

  // 5. 返回最终处理好的、安全且精确的手数
  return(final_lot);
}
//<<==LotsOptimized <<==

// +++++++++++++++ 点差显示功能 +++++++++++++++
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
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_CORNER, 1);        // 右上角
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_YDISTANCE, 75);    // Y距离（在按钮下面）
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_XDISTANCE, 50);    // X距离（继续向右移动）
        ObjectSetText(SPREAD_OBJ_NAME, s, SpreadFontSize, "FixedSys", SpreadColor);
    }
    else
    {
        // 更新文本内容和格式
        ObjectSetText(SPREAD_OBJ_NAME, s, SpreadFontSize, "FixedSys", SpreadColor);
    }
    
    WindowRedraw();
}

// +++++++++++++++ 手动停止按钮功能 +++++++++++++++
void CreateStopButton()
{
    string buttonText;
    color textColor, bgColor;
    
    if (!isEAStopped)
    {
        buttonText = "[STOP] 停止EA";
        textColor = StopButtonColor;
        bgColor = StopButtonBgColor;
    }
    else
    {
        if (isCircuitBreakerActive)
        {
            // 熔断机制激活状态
            long remainingSeconds = pauseEndTime - TimeCurrent();
            if (remainingSeconds > 0)
            {
                buttonText = "[CB] 熔断" + IntegerToString(remainingSeconds / 60) + ":" + IntegerToString(remainingSeconds % 60, 2, '0');
                textColor = Orange; // 熔断状态用橙色
                bgColor = Yellow;   // 背景用黄色
            }
            else
            {
                buttonText = "[GO] 继续运行";
                textColor = ContinueButtonColor;
                bgColor = ContinueButtonBgColor;
            }
        }
        else
        {
            // 手动停止状态
            buttonText = "[GO] 继续运行";
            textColor = ContinueButtonColor;
            bgColor = ContinueButtonBgColor;
        }
    }
    
    if(ObjectFind(STOP_BUTTON_NAME) < 0)
    {
        ObjectCreate(STOP_BUTTON_NAME, OBJ_BUTTON, 0, 0, 0);
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_CORNER, 1);        // 右上角
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_XDISTANCE, 150);   // X距离（进一步往左移动）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_YDISTANCE, 30);    // Y距离
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_XSIZE, 120);       // 按钮宽度（放大）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_YSIZE, 35);        // 按钮高度（放大）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_STATE, false);     // 按钮状态
    }
    
    // 更新按钮外观
    ObjectSet(STOP_BUTTON_NAME, OBJPROP_COLOR, textColor);     // 文字颜色
    ObjectSet(STOP_BUTTON_NAME, OBJPROP_BGCOLOR, bgColor);     // 背景颜色
    ObjectSetText(STOP_BUTTON_NAME, buttonText, StopButtonFontSize, "Arial Bold");
    
    WindowRedraw();
}

void CheckStopButtonClick()
{
    if(ObjectGet(STOP_BUTTON_NAME, OBJPROP_STATE) == true)
    {
        if (!isEAStopped)
        {
            // 停止EA
            Print("手动停止EA - 正在删除所有挂单...");
            
            // 设置停止状态
            isEAStopped = true;
            
            // 删除所有本 EA 的挂单
            DeleteAllPendingOrders();
            
            Print("手动停止EA - 所有挂单已删除，交易已停止。");
        }
        else
        {
            // 继续运行EA
            if (isCircuitBreakerActive)
            {
                // 手动终止熔断机制
                Print("手动终止熔断机制 - 正在继续运行...");
                isCircuitBreakerActive = false;
                pauseEndTime = 0; // 清除熔断时间
            }
            else
            {
                // 普通手动重启
                Print("手动重启EA - 正在继续运行...");
            }
            
            // 重置停止状态
            isEAStopped = false;
            
            Print("手动重启EA - EA已继续运行。");
        }
        
        // 更新按钮外观
        CreateStopButton();
        
        // 重置按钮状态（避免重复触发）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_STATE, false);
        
        WindowRedraw();
    }
}
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++