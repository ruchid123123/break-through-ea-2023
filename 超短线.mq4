// 風險等級枚舉：專家級(10) - 激進 / 穩健級(20) - 平衡 / 安全級(30) - 保守
enum Option1      {Expert = 10,Moderate = 20,Safe = 30  };

//------------------
extern string 注释 = "专做数据行情超短线";
extern string Configuration="==== Setting ===="  ;
extern bool   StartInPauseMode = true  ;// 啟動暫停模式：true=啟動時默認暫停 false=啟動時默認運行
extern int   magicnumber=333  ;// 魔術號：用於識別本EA訂單，與熔斷機制相關
extern bool AutoLot=true  ;// 自動手數計算：true=根據帳戶餘額自動計算，false=使用固定手數
extern  Option1  AutoLotMode=20  ;// 風險等級：10=激進 20=穩健 30=保守（影響自動手數計算）
extern double FixLot=0.01  ;// 固定手數：當AutoLot=false時使用的手數大小
extern string OrderSetting="=== Leave as Default ===="  ;
extern int   stoploss=200  ;// 止損距離（點數）：已優化為黃金分割比例
extern int   takeprofit=1300  ;// 止盈距離（點數）：目標盈利點數
extern int   step=200  ;// 掛單距離（點數）：掛單距離當前價格的點數
extern string Config="==== Time Filter ===="  ;
extern int   StartHour=1  ;// 開始交易時間（小時）：0-23，建議設定在重要數據發布前
extern int   StopHour=23  ;// 停止交易時間（小時）：0-23，建議設定在重要數據發布後

// +++++++++++++++ 熔斷機制設置：虧損後自動暫停交易防止連續虧損 +++++++++++++++
extern string LossSetting = "==== Stop on Loss Setting =====";
extern bool   PauseOnLoss_Enabled = true;     // 啟用虧損後暫停功能：防止連續虧損
extern int    PauseDuration_Minutes = 30;     // 暫停時長（分鐘）：虧損後的冷靜期
extern bool   DeletePendingsOnLoss = true;    // 虧損時是否刪除所有掛單：清理未成交訂單

// +++++++++++++++ 市場資訊顯示設置：統一價格和點差的顯示參數 +++++++++++++++
extern string SpreadSetting = "==== Price & Spread Display Setting ====";
extern int    SpreadFontSize = 16;            // 市場信息字體大小：價格和點差統一字體
extern color  SpreadColor = White;            // 市場信息顏色：價格和點差統一顏色

// +++++++++++++++ 手動控制按鈕設置：界面交互控制 +++++++++++++++
extern string ManualStopSetting = "==== Manual Stop Button Setting ====";
// extern bool   ShowStopButton = true;          // 已移除：按鈕始終顯示，無需配置開關
extern int    StopButtonFontSize = 14;        // 暫停按鈕字體大小
extern color  StopButtonColor = Red;          // 暫停按鈕文字顏色
extern color  StopButtonBgColor = White;      // 暫停按鈕背景顏色
extern color  ContinueButtonColor = Green;    // 繼續按鈕文字顏色
extern color  ContinueButtonBgColor = LightGreen; // 繼續按鈕背景顏色
// +++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++

// +++++++++++++++ 交易參數配置變數：細節控制EA交易行為 +++++++++++++++
  double    zong_1_do = 0.3;        // 風險係數：用於自動手數計算的乘數因子
  double    zong_2_do = AutoLotMode * 100;  // 風險除數：根據AutoLotMode自動計算（AutoLotMode×100）
  int       zong_3_in = 250;        // 第一階段止損移動步長（點數）
  int       zong_4_in = 200;        // 基礎止損距離（點數）
  int       zong_5_in = 100;        // 第二階段止損移動距離（點數）
  int       zong_6_in = 50;         // 第二階段止損移動步長（點數）
  int       zong_7_in = 100;        // 第三階段止損移動距離（點數）
  int       zong_8_in = 50;         // 第三階段止損移動步長（點數）
  int       zong_9_in = 800;        // 高級止損闾值（點數）
  int       zong_10_in = 100;       // 最終階段止損距離（點數）
  int       zong_11_in = 50;        // 最終階段止損步長（點數）
// +++++++++++++++ 交易狀態控制變數：跟蹤和管理交易狀態 +++++++++++++++
  int       xt = 0;                 // 點值倍數：根據小數位數計算（3或5位時為10，否則為1）
  double    zong_18_do = 0.0;       // 市場特性緩衝區（MODE_FREEZELEVEL）
  int       zong_19_in = 0;         // 當前交易緩衝區距離
  int       zong_20_in = 10;        // 訂單滑點容忍值（點數）
  int       zong_21_in = 0;         // 上次Buy Stop訂單時間戳
  int       zong_22_in = 0;         // 上次Sell Stop訂單時間戳
  int       zong_23_in = 1;         // 掛單頻率控制（秒），預設為1秒
  int       zong_24_in = 30;        // 價格變動闾值（點數），超過此值才移動掛單
  double    zong_25_do = 0.0;       // 計算出的點差值
  double    zong_26_do = 0.0;       // 手數步長（MODE_LOTSTEP）
  int       LotDigits = 0;          // 手數小數位數
  double    lots = 0.0;             // 當前計算出的交易手數

// +++++++++++++++ 狀態持久化變數：解決切換周期自動啟動問題 +++++++++++++++
// 使用這些變數來在EA重新初始化時保持狀態
double PERSISTENT_PAUSE_END_TIME = 0;        // 持久化的暫停結束時間
bool PERSISTENT_CIRCUIT_BREAKER_ACTIVE = false;  // 持久化的熔斷機制狀態
bool PERSISTENT_EA_STOPPED = false;         // 持久化的EA暫停狀態
double PERSISTENT_LAST_LOSS_TIME = 0;       // 持久化的最後虧損時間
bool STATE_INITIALIZED = false;             // 狀態是否已初始化的標記

// +++++++++++++++ 熔斷機制狀態變數：虧損後自動暫停功能 +++++++++++++++
datetime pauseEndTime = 0;              // 熔斷暫停結束時間戳：記錄暫停結束的時間
datetime lastLossTime = 0;              // 最後一次虧損時間：避免重複觸發熔斷
bool isCircuitBreakerActive = false;    // 熔斷機制激活狀態：標示是否處於熔斷暫停中

// +++++++++++++++ 市場信息顯示控制：價格和點差統一顯示 +++++++++++++++
#define SPREAD_OBJ_NAME "PriceSpreadDisplayObj"  // 市場信息顯示物件名稱
#define DATETIME_OBJ_NAME "DateTimeDisplayObj"  // 日期時間顯示物件名稱

// +++++++++++++++ 手動控制按鈕狀態變數：界面交互控制 +++++++++++++++
#define STOP_BUTTON_NAME "ManualStopButton"     // 手動停止按鈕物件名稱
bool isEAStopped = false;                   // EA手動暫停狀態：標示使用者是否手動暫停EA
// ++++++++++++++++++++++++++++++++++++++++++++++++

 int init()
 {
  double    Local_2_do;
  double    Local_3_do;
//----- -----
 double     tmp_do_1;
 double     tmp_do_2;

 // 檢測小數位數，設定點值倍數（3或5位時需要乘以10）
 if ( ( Digits() == 3 || Digits() == 5 ) )
 {
   xt = 10 ;
 }
 else
 {
   xt = 1 ;
 }
 
 // 獲取市場緩衝區資訊，用於訂單距離驗證
 zong_18_do = MarketInfo(Symbol(),14) ;
 
 // 調整止損參數：確保不小於緩衝區要求
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
 
 // 調整止盈參數：確保不小於緩衝區要求
 if ( takeprofit <= zong_18_do / xt )
 {
   tmp_do_2 = zong_18_do / xt;
 }
 else
 {
   tmp_do_2 = takeprofit;
 }
 takeprofit = tmp_do_2 ;
 // 獲取交易品種的市場信息：最大和最小手數
 Local_2_do = MarketInfo(Symbol(),10) ;
 Local_3_do = MarketInfo(Symbol(),9) ;
 
 // 獲取手數步長，用於手數精度計算
 zong_26_do = MarketInfo(Symbol(),24) ;
 
 // 根據手數步長確定小數位數
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
 
 // 計算點差值（以點數為單位）
 zong_25_do = (Local_2_do - Local_3_do) / Point() / xt ;
 
 // 智能狀態恢復邏輯 - 解決切換周期自動啟動問題
 if (STATE_INITIALIZED)
 {
    // 如果狀態已經初始化過，恢復持久化的狀態
    pauseEndTime = PERSISTENT_PAUSE_END_TIME;
    isCircuitBreakerActive = PERSISTENT_CIRCUIT_BREAKER_ACTIVE;
    isEAStopped = PERSISTENT_EA_STOPPED;
    lastLossTime = PERSISTENT_LAST_LOSS_TIME;
    
    Print("狀態恢復完成 - 切換周期後保持原有狀態");
    if (isEAStopped)
    {
        if (isCircuitBreakerActive)
        {
            long remainingSeconds = pauseEndTime - TimeCurrent();
            if (remainingSeconds > 0)
            {
                Print("恢復熔斷狀態 - 剩餘時間: ", remainingSeconds, " 秒");
            }
            else
            {
                Print("恢復熔斷狀態 - 時間已到，等待用戶操作");
            }
        }
        else
        {
            Print("恢復手動暫停狀態");
        }
    }
    else
    {
        Print("恢復正常運行狀態");
    }
 }
 else
 {
    // 首次初始化，根據StartInPauseMode參數決定啟動狀態
    pauseEndTime = 0;
    lastLossTime = TimeCurrent();
    isCircuitBreakerActive = false;
    
    // 根據參數設定初始狀態
    if (StartInPauseMode)
    {
        isEAStopped = true;  // 啟動時處於暫停狀態
        Print("深度突破EA啟動 - 默認暫停狀態（需手動點擊繼續運行按鈕）");
    }
    else
    {
        isEAStopped = false; // 啟動時處於運行狀態
        Print("深度突破EA啟動 - 默認運行狀態");
    }
    
    // 保存到持久化變量
    PERSISTENT_PAUSE_END_TIME = pauseEndTime;
    PERSISTENT_CIRCUIT_BREAKER_ACTIVE = isCircuitBreakerActive;
    PERSISTENT_EA_STOPPED = isEAStopped;
    PERSISTENT_LAST_LOSS_TIME = lastLossTime;
    STATE_INITIALIZED = true;
 }
 
 // 初始化市場信息顯示（價格+點差，預設開啟）
 ShowSpreadOnChart();
 
 // 初始化日期時間顯示
 ShowDateTimeOnChart();
 
 // 初始化手動停止按鈕
 CreateStopButton();
 
 return(0);
 }
//init <<==--------   --------

int start()
{
    // ================== 即時顯示更新（始終執行） ==================
    // 無論EA是否暫停，都要保持價格和點差的即時顯示
    
    // 更新市場信息顯示（價格+點差，預設開啟，保持持續顯示）
    ShowSpreadOnChart();
    
    // 更新日期時間顯示
    ShowDateTimeOnChart();
    
    // 更新停止按鈕顯示狀態（保持持續顯示）
    CreateStopButton();
    // ================== 即時顯示更新結束 ==================
    
    // ================== 手動暫停檢查 ==================
    // 檢查是否按下了暫停按鈕
    CheckStopButtonClick();
    
    // 如果EA已被手動暫停，停止所有交易邏輯
    if (isEAStopped)
    {
        // 預設不顯示狀態提示信息，保持界面簡潔
        return(0);
    }
    // ================== 手動暫停檢查結束 ==================
    
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

    // =================== 智能熔斷機制：虧損後自動暫停交易防止連續虧損 ===================
    // 功能說明：
    // 1. 目標：防止連續虧損，通過自動暫停交易冷靜期控制風險
    // 2. 觸發條件：檢測到本魔術號的交易中有新的虧損訂單關閉
    // 3. 執行時機：每次start()函數調用時檢查，確保即時監控
    // 4. 暫停時長：由PauseDuration_Minutes參數控制（預設1分鐘）
    // 5. 狀態同步：與手動暫停按鈕狀態保持一致，統一管理
    // 6. 可選操作：根據DeletePendingsOnLoss參數決定是否刪除所有掛單
    // 7. 恢復機制：時間到達後自動恢復，或用戶手動點擊繼續按鈕
    if (PauseOnLoss_Enabled)
    {
        // --- 1. 检查当前是否已处于暂停状态 ---
        if (TimeCurrent() < pauseEndTime)
        {
            if (DeletePendingsOnLoss)
            {
                DeleteAllPendingOrders();
            }
            
            // 設置熔斷機制激活狀態，與手動停止同步
            if (!isCircuitBreakerActive)
            {
                isCircuitBreakerActive = true;
                isEAStopped = true; // 與手動停止按鈕同步
                SyncPersistentState(); // 同步持久化狀態
            }
            
            remainingSeconds = pauseEndTime - TimeCurrent();
            // 默认不显示熔断状态提示信息，保持界面简洁
            return(0); // 处于暂停期，直接退出（但显示功能已更新）
        }
        else if (isCircuitBreakerActive)
        {
            // 熔斷時間到了，自動恢復運行
            isCircuitBreakerActive = false;
            isEAStopped = false; // 與手動停止按鈕同步
            SyncPersistentState(); // 同步持久化狀態
            
            // 立即更新按鈕顯示狀態，確保用戶能看到EA已自動恢復
            CreateStopButton();
            
            Print("熔斷機制暫停時間結束，EA已自動恢復交易");
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

                    // 記錄這次虧損的時間，避免重複觸發
                    lastLossTime = OrderCloseTime();
                    
                    // 設置一個從“現在”開始的暫停結束時間
                    pauseEndTime = TimeCurrent() + PauseDuration_Minutes * 60;
                    
                    // 激活熔斷機制，與手動停止按鈕同步
                    isCircuitBreakerActive = true;
                    isEAStopped = true;
                    
                    // 同步持久化狀態，確保切換周期後保持暫停
                    SyncPersistentState();

                    if (DeletePendingsOnLoss)
                    {
                        DeleteAllPendingOrders();
                    }

                    // 显示暂停信息并立即退出，开始倒数计时
                    remainingSeconds = pauseEndTime - TimeCurrent();
                    // 默认不显示熔断状态提示信息，保持界面简洁
                    return(0); // 触发熔断机制，直接退出（但显示功能已更新）
                }
                break; // 找到最近的亏损订单后就停止搜索
            }
        }
    }
    // ================== 智能熔断机制结束 ==================

    // 如果EA未被暂停，则执行以下正常的交易逻辑
    Display_Info();
    
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

// +++++++++++++++ 狀態持久化同步函數：確保狀態變化時的一致性 +++++++++++++++
void SyncPersistentState()
{
    // 將當前狀態同步到持久化變量，確保在EA重新初始化時能够恢復
    PERSISTENT_PAUSE_END_TIME = pauseEndTime;
    PERSISTENT_CIRCUIT_BREAKER_ACTIVE = isCircuitBreakerActive;
    PERSISTENT_EA_STOPPED = isEAStopped;
    PERSISTENT_LAST_LOSS_TIME = lastLossTime;
    STATE_INITIALIZED = true;
}

// +++++++++++++++ 熔斷機制輔助函數：刪除所有掛單避免意外成交 +++++++++++++++
void DeleteAllPendingOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // 確保是本EA的掛單：檢查交易品種和魔術號
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicnumber)
            {
                // 只處理Buy Stop和Sell Stop掛單，不影響已成交訂單
                if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
                {
                    if (!OrderDelete(OrderTicket()))
                    {
                        Print("刪除掛單錯誤 #", OrderTicket(), ": ", GetLastError());
                    }
                    else
                    {
                        Print("掛單 #", OrderTicket(), " 已因虧損暫停而刪除。");
                    }
                }
            }
        }
    }
}
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++

int deinit()
{
 // 清理界面元素：刪除市場信息顯示物件（價格+點差）
 ObjectDelete(SPREAD_OBJ_NAME);
 
 // 清理日期時間顯示物件
 ObjectDelete(DATETIME_OBJ_NAME);
 
 // 清理界面元素：刪除手動暫停按鈕物件
 ObjectDelete(STOP_BUTTON_NAME);
 
 // 清理所有其他物件：確保無殘留
 ObjectsDeleteAll(-1,-1);
 
 // 最後同步一次狀態，確保資料一致性
 SyncPersistentState();
 
 return(0);
}
//deinit <<==--------   --------
 void Display_Info()
 {
  int       Local_1_in;  // 顏色值1：根據秒數變化的彩色顯示
  string    Local_2_st;  // 分隔線字串：界面裝飾用途
  int       Local_3_in;  // 顏色值2：根據秒數變化的另一彩色
//----- -----

 // 每10秒一個循環的時間基础顏色變化系統（用於视覺效果）

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
 // 此函數已停用：原為標籤顯示函數，現在由ShowSpreadOnChart()和CreateStopButton()取代
 // 保留空函數以保持相容性，防止編譯錯誤
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

// *** 時間過濾函數：檢查當前時間是否在交易時間範圍內 ***
bool dTime()
{
 bool      ans = false;  // 返回值：是否允許交易
//----- -----
 // 檢查當前小時是否在設定的交易時間範圍內
 if ( Hour() >= StartHour && Hour() <  StopHour )
 {
   ans = true ;  // 在交易時間內，允許交易
 }
 return(ans);  // 返回檢查結果
}
//dTime <<==--------   --------

// +++ 智能手數優化函數：自動計算最佳交易手數並精確處理 +++
double LotsOptimized()
{
  double    raw_lot; // 計算出的原始理論手數
  
  // 1. 根據 AutoLot 設置，確定原始手數
  if (AutoLot)
  {
    // 自動計算：帳戶餘額 / 風險除數 * 風險係數
    raw_lot = AccountBalance() / zong_2_do * zong_1_do;
  }
  else
  {
    // 使用固定手數
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

// +++++++++++++++ 市場信息顯示功能：統一的價格和點差即時顯示 +++++++++++++++
void ShowSpreadOnChart()
{
    static double spread;  // 靜態變數：緩存點差值減少重複計算
    
    // 獲取當前點差值（以點數為單位）
    spread = MarketInfo(Symbol(), MODE_SPREAD);
    
    // 調用繪製函數進行顯示
    DrawSpreadOnChart(spread);
}

void DrawSpreadOnChart(double spread)
{
    // 使用Bid獲取當前價格，顯示為繁體中文格式："價格元 及 點差 點"
    // 價格和點差都使用相同的SpreadFontSize和SpreadColor參數配置
    string s = IntegerToString((int)Bid) + "元 及 " + DoubleToStr(spread, 0) + " 點";
    
    if(ObjectFind(SPREAD_OBJ_NAME) < 0)
    {
        // 初次創建市場信息顯示物件
        ObjectCreate(SPREAD_OBJ_NAME, OBJ_LABEL, 0, 0, 0);
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_CORNER, 1);        // 右上角位置
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_YDISTANCE, 75);    // Y距離（在按鈕下面）
        ObjectSet(SPREAD_OBJ_NAME, OBJPROP_XDISTANCE, 50);    // X距離（向右移動）
        ObjectSetText(SPREAD_OBJ_NAME, s, SpreadFontSize, "Times New Roman", SpreadColor);
    }
    else
    {
        // 更新文本內容和格式（價格和點差統一使用SpreadFontSize和SpreadColor）
        ObjectSetText(SPREAD_OBJ_NAME, s, SpreadFontSize, "Times New Roman", SpreadColor);
    }
    
    // 刷新圖表顯示
    WindowRedraw();
}

// +++++++++++++++ 手動控制按鈕功能：智能狀態顯示和交互控制 +++++++++++++++
void CreateStopButton()
{
    string buttonText;  // 按鈕顯示文字
    color textColor, bgColor;  // 按鈕文字和背景顏色
    
    // **關鍵修復**：在創建按鈕時也檢查熔斷時間是否到期
    // 確保按鈕狀態與實際EA狀態保持同步
    if (isCircuitBreakerActive && TimeCurrent() >= pauseEndTime)
    {
        // 熔斷時間已到，自動重置狀態（與start()函數邏輯保持一致）
        isCircuitBreakerActive = false;
        isEAStopped = false;
        SyncPersistentState();
        Print("按鈕更新時檢測到熔斷時間已到，自動重置狀態");
    }
    
    if (!isEAStopped)
    {
        // EA正常運行狀態：顯示暫停按鈕
        buttonText = "暫停EA";
        textColor = StopButtonColor;
        bgColor = StopButtonBgColor;
    }
    else
    {
        if (isCircuitBreakerActive)
        {
            // 熔斷機制激活狀態：顯示倒數計時或繼續按鈕
            long remainingSeconds = pauseEndTime - TimeCurrent();
            if (remainingSeconds > 0)
            {
                // 仍在熔斷期間，顯示倒數計時
                buttonText = "熔斷" + IntegerToString(remainingSeconds / 60) + ":" + IntegerToString(remainingSeconds % 60, 2, '0');
                textColor = Orange; // 熔斷狀態用橙色
                bgColor = Yellow;   // 背景用黃色
            }
            else
            {
                // 熔斷時間已到，顯示繼續按鈕（或自動恢復）
                buttonText = "繼續運行";
                textColor = ContinueButtonColor;
                bgColor = ContinueButtonBgColor;
            }
        }
        else
        {
            // 手動暫停狀態：顯示繼續按鈕
            buttonText = "繼續運行";
            textColor = ContinueButtonColor;
            bgColor = ContinueButtonBgColor;
        }
    }
    
    if(ObjectFind(STOP_BUTTON_NAME) < 0)
    {
        // 初次創建手動控制按鈕
        ObjectCreate(STOP_BUTTON_NAME, OBJ_BUTTON, 0, 0, 0);
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_CORNER, 1);        // 右上角位置
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_XDISTANCE, 150);   // X距離（向左移動）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_YDISTANCE, 30);    // Y距離
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_XSIZE, 120);       // 按鈕寬度（放大）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_YSIZE, 35);        // 按鈕高度（放大）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_STATE, false);     // 按鈕初始狀態
    }
    
    // 更新按鈕外觀：文字和背景顏色
    ObjectSet(STOP_BUTTON_NAME, OBJPROP_COLOR, textColor);     // 文字顏色
    ObjectSet(STOP_BUTTON_NAME, OBJPROP_BGCOLOR, bgColor);     // 背景顏色
    ObjectSetText(STOP_BUTTON_NAME, buttonText, StopButtonFontSize, "Times New Roman");
    
    // 刷新圖表顯示
    WindowRedraw();
}

void CheckStopButtonClick()
{
    // 檢測按鈕是否被點擊（狀態變為 true）
    if(ObjectGet(STOP_BUTTON_NAME, OBJPROP_STATE) == true)
    {
        if (!isEAStopped)
        {
            // 暫停EA：由運行轉為暫停
            Print("手動暫停EA - 正在刪除所有掛單...");
            
            // 設定暫停狀態
            isEAStopped = true;
            
            // 刪除所有本 EA 的掛單
            DeleteAllPendingOrders();
            
            // 同步持久化狀態，確保切換周期後保持暫停
            SyncPersistentState();
            
            Print("手動暫停EA - 所有掛單已刪除，交易已暫停。");
        }
        else
        {
            // 繼續運行EA：由暫停轉為運行
            if (isCircuitBreakerActive)
            {
                // 手動終止熔斷機制
                Print("手動終止熔斷機制 - 正在繼續運行...");
                isCircuitBreakerActive = false;
                pauseEndTime = 0; // 清除熔斷時間
            }
            else
            {
                // 普通手動重啟
                Print("手動重啟EA - 正在繼續運行...");
            }
            
            // 重置暫停狀態
            isEAStopped = false;
            
            // 同步持久化狀態，確保切換周期後保持運行
            SyncPersistentState();
            
            Print("手動重啟EA - EA已繼續運行。");
        }
        
        // 更新按鈕外觀：反映新狀態
        CreateStopButton();
        
        // 重置按鈕狀態（避免重複觸發）
        ObjectSet(STOP_BUTTON_NAME, OBJPROP_STATE, false);
        
        // 刷新圖表顯示
        WindowRedraw();
    }
}
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++

// +++++++++++++++ 日期時間顯示功能 +++++++++++++++
void ShowDateTimeOnChart()
{
    // 實時同步顯示，每個tick都更新
    string dateTimeStr = IntegerToString(Year()) + "." + 
                         IntegerToString(Month()) + "." + 
                         IntegerToString(Day()) + "-" + 
                         TimeToStr(TimeCurrent(), TIME_SECONDS);
    
    if(ObjectFind(DATETIME_OBJ_NAME) < 0)
    {
        ObjectCreate(DATETIME_OBJ_NAME, OBJ_LABEL, 0, 0, 0);
        ObjectSet(DATETIME_OBJ_NAME, OBJPROP_CORNER, 1);        // 右上角位置
        ObjectSet(DATETIME_OBJ_NAME, OBJPROP_YDISTANCE, 100);   // Y距離（在點差下方）
        ObjectSet(DATETIME_OBJ_NAME, OBJPROP_XDISTANCE, 50);    // X距離（與點差對齊）
    }
    
    ObjectSetText(DATETIME_OBJ_NAME, dateTimeStr, SpreadFontSize, "Times New Roman", Yellow);
}