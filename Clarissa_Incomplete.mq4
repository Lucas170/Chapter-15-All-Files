//+------------------------------------------------------------------+
//|                                                                  |
//|  In no event will author be liable for any damages whatsoever.   |
//|                      Use at your own risk.                       |
//|                                                                  |
//|   By Lucas Liew | lucas@blackalgotechnologies.com                |                                                                 
//|                                                                  |
//+------------------- DO NOT REMOVE THIS HEADER --------------------+

   /* 
      CLARISSA ENTRY RULES:
      Enter a long trade when Monday is a up day and it's price change is greater than ATR(14) on Daily Timeframe
      Enter a short trade when Monday is a down day and it's price change is greater than ATR(14) on Daily Timeframe
   
      CLARISSA EXIT RULES:
      1*ATR(14) (on Daily Timeframe) Stop Loss
      2*ATR(14) (on Daily Timeframe) Take Profit 
         
      CLARISSA POSITION SIZING RULE:
      Sizing based on account size
   */

#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "Expert Advisor Builder"
#property link      "http://sufx.core.t3-ism.net/ExpertAdvisorBuilder/"

// TDL 4: Declare required Extern Variables and Variables

extern int MagicNumber = 12345;
extern bool SignalMail = False;
extern int Slippage = 3;
extern bool UseStopLoss = True;
extern int StopLoss = 0;
extern bool UseTakeProfit = True;
extern int TakeProfit = 0;
extern bool UseTrailingStop = False;
extern int TrailingStop = 0;

extern double Lots = 1.0;
extern bool isSizingOn = true;
extern double Risk = 3;




int P = 1;
int Order = SIGNAL_NONE;
int Total, Ticket, Ticket2;
double StopLossLevel, TakeProfitLevel, StopLevel;
double YenPairAdjustFactor = 1;

int current_direction, last_direction;
bool first_time = True;





//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init() {
   
   if(Digits == 5 || Digits == 3 || Digits == 1)P = 10;else P = 1; // To account for 5 digit brokers
   if(Digits == 3 || Digits == 2) YenPairAdjustFactor = 100; // Adjust for YenPair

   return(0);
}
//+------------------------------------------------------------------+
//| Expert initialization function - END                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
   return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function - END                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
int start() {

   Total = OrdersTotal();
   Order = SIGNAL_NONE;

   //+------------------------------------------------------------------+
   //| Variable Setup                                                   |
   //+------------------------------------------------------------------+
   
   // TDL 1: Create a 2 functions to calculate volatilty Stop Loss and Take Profit (in pips) respectively
   // Then assign them to StopLoss and TakeProfit
   
   StopLossFinal = ;
   TakeProfitFinal = ;
   
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD); // Defining minimum StopLevel

   if (StopLossFinal < StopLevel) StopLossFinal = StopLevel;
   if (TakeProfitFinal < StopLevel) TakeProfitFinal = StopLevel;
   
   LotsFinal = ; // TDL 2: Create a function to calculate position size

   //+------------------------------------------------------------------+
   //| Variable Setup - END                                             |
   //+------------------------------------------------------------------+

   //Check position
   bool IsTrade = False;

   for (int i = 0; i < Total; i ++) {
      Ticket2 = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() <= OP_SELL &&  OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         IsTrade = True;
         if(OrderType() == OP_BUY) {
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Buy)                                           |
            //+------------------------------------------------------------------+

            /*  
               CLARISSA EXIT RULES:
               1*ATR(14) (on Daily Timeframe) Stop Loss
               2*ATR(14) (on Daily Timeframe) Take Profit 
               
               We don't have to input the exit rules here. The exit rules are incorporated in our Hard Stop Loss
            */
            
            
            //if() Order = SIGNAL_CLOSEBUY; // Rule to EXIT a Long trade

            //+------------------------------------------------------------------+
            //| Signal End(Exit Buy)                                             |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSEBUY) {
               Ticket2 = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               IsTrade = False;
               continue;
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if(Bid - OrderOpenPrice() > P * Point * TrailingStop) {
                  if(OrderStopLoss() < Bid - P * Point * TrailingStop) {
                     Ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - P * Point * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                     continue;
                  }
               }
            }
         } else {
            //Close

            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+

           //if () Order = SIGNAL_CLOSESELL; // Rule to EXIT a Short trade

            //+------------------------------------------------------------------+
            //| Signal End(Exit Sell)                                            |
            //+------------------------------------------------------------------+

            if (Order == SIGNAL_CLOSESELL) {
               Ticket2 = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange);
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               continue;
            }
            //Trailing stop
            if(UseTrailingStop && TrailingStop > 0) {                 
               if((OrderOpenPrice() - Ask) > (P * Point * TrailingStop)) {
                  if((OrderStopLoss() > (Ask + P * Point * TrailingStop)) || (OrderStopLoss() == 0)) {
                     Ticket2 = OrderModify(OrderTicket(), OrderOpenPrice(), Ask + P * Point * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                     continue;
                  }
               }
            }
         }
      }
   }

   //+------------------------------------------------------------------+
   //| Signal Begin(Entries)                                            |
   //+------------------------------------------------------------------+

   /* 
      CLARISSA ENTRY RULES:
      Enter a long trade when Monday is a up day and it's price change is greater than ATR(14) on Daily Timeframe
      Enter a short trade when Monday is a down day and it's price change is greater than ATR(14) on Daily Timeframe
  
   */
   
   // TDL 3: Create Entry rules using a function
   
      if () Order = SIGNAL_BUY; // Rule to ENTER a Long trade
   
      if () Order = SIGNAL_SELL; // Rule to ENTER a Short trade

   
   //+------------------------------------------------------------------+
   //| Signal End                                                       |
   //+------------------------------------------------------------------+

   //Buy
   if (Order == SIGNAL_BUY) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return(0);
         }

         if (UseStopLoss) StopLossLevel = Ask - StopLossFinal * Point * P; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Ask + TakeProfitFinal * Point * P; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_BUY, LotsFinal, Ask, Slippage, StopLossLevel, TakeProfitLevel, "Buy(#" + MagicNumber + ")", MagicNumber, 0, DodgerBlue);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("BUY order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
			} else {
				Print("Error opening BUY order : ", GetLastError());
			}
         }
         return(0);
      }
   }

   //Sell
   if (Order == SIGNAL_SELL) {
      if(!IsTrade) {
         //Check free margin
         if (AccountFreeMargin() < (1000 * Lots)) {
            noMoneyPrint();
            return(0);
         }

         if (UseStopLoss) StopLossLevel = Bid + StopLossFinal * Point * P; else StopLossLevel = 0.0;
         if (UseTakeProfit) TakeProfitLevel = Bid - TakeProfitFinal * Point * P; else TakeProfitLevel = 0.0;

         Ticket = OrderSend(Symbol(), OP_SELL, LotsFinal, Bid, Slippage, StopLossLevel, TakeProfitLevel, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if(Ticket > 0) {
            if (OrderSelect(Ticket, SELECT_BY_TICKET, MODE_TRADES)) {
				Print("SELL order opened : ", OrderOpenPrice());
                if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
			} else {
				Print("Error opening SELL order : ", GetLastError());
			}
         }
         return(0);
      }
   }

   return(0);
}


//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------------------------------------------+
// FUNCTIONS LIBRARY                                                                                                                   
//+------------------------------------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
// Customized Print                                                  
//+------------------------------------------------------------------+
void noMoneyPrint(){

   Print("We have no money. Free Margin = ", AccountFreeMargin());

}
//+------------------------------------------------------------------+
// End of Customized Print                                           
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// Cross                                                             
//+------------------------------------------------------------------+

// We didn't use the Cross function for CLARISSA but it is a good habit to keep the functions here for potential future use

/* 

Function Notes:

Declare these before the init() of the EA 

int current_direction, last_direction;
bool first_time = True;

----  

If Output is 0: No cross happened
If Output is 1: Line 1 crossed Line 2 from Bottom
If Output is 2: Line 1 crossed Line 2 from top 

*/

int Crossed(double line1 , double line2) 
  {

//----
    if(line1 > line2)
        current_direction = 1;  // line1 above line2
    if(line1 < line2)
        current_direction = 2;  // line1 below line2
//----
    if(first_time == true) // Need to check if this is the first time the function is run
      {
        first_time = false; // Change variable to false
        last_direction = current_direction; // Set new direction
        return (0);
      }

    if(current_direction != last_direction && first_time == false)  // If not the first time and there is a direction change
      {
        last_direction = current_direction; // Set new direction
        return(current_direction); // 1 for up, 2 for down
      }
    else
      {
        return (0);  // No direction change
      }
  }


//+------------------------------------------------------------------+
// End of Cross                                                      
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Volatility Stop Loss                                             
//+------------------------------------------------------------------+

// TDL 1: 











//+------------------------------------------------------------------+
//| End of Volatility Stop Loss // CURRENT SYMBOL                    
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Volatility-Based Take Profit                                     
//+------------------------------------------------------------------+

// TDL 1: 













//+------------------------------------------------------------------+
//| End of Volatility-Based Take Profit                 
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Position Sizing Algo               
//+------------------------------------------------------------------+
   
// TDL 2: 
   











   
//+------------------------------------------------------------------+
//| End of Position Sizing Algo               
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Entry Rule                                                        
//+------------------------------------------------------------------+

// TDL 3: 













//+------------------------------------------------------------------+
// End of Entry Rule                                                 
//+------------------------------------------------------------------+