//+------------------------------------------------------------------+
//|                                 MyPracticeScript_DateAndTime.mq4 |
//|                 Copyright 2015, Black Algo Technologies Pte Ltd. |
//|                                        blackalgotechnologies.com |
//+------------------------------------------------------------------+
#property copyright "Black Algo Technologies Pte Ltd"
#property link      "blackalgotechnologies.com"
#property version   "1.00"
#property strict

// Created by Lucas Liew | blackalgotechnologies.com

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   /* More info on Date and Time functions: 
      http://docs.mql4.com/dateandtime
      http://docs.mql4.com/basis/types/integer/datetime
      http://docs.mql4.com/convert/strtotime
      http://docs.mql4.com/convert/timetostr
   */
   
   // --- No trade Month ---
   
   // TDL 1: No trade on December (Done for you)
   
   if (Month() != 12) {
   
      // Entry Rules
   
   }
   
   // --- No trade Week ---
   
   // TDL 2: No trade on First Week of the Month (No trade on the first 7 days)
   
   if (Day() > 7) {
   
      // Entry Rules
   
   }

   // TDL 3: No trade on First Week of the Month (Only trade from the first Monday onwards, unless the month starts on Sunday or Monday, then skip the first week)
   // Difficulty: Intermediate to Advanced
   
   datetime TimeFirstDay; 
   int WeekdayFirstDayOfMonth;
   
   if (Day() > 7) { // We have past the first 7 days of the Month
      // Entry Rules  
   } else { 
   
      // We first need to find out which weekday is the first day of the month 
      
      for(int x = 1; x <= 7; x++) {      
         if(TimeMonth(TimeCurrent() - x*24*60*60) != Month()) { // This searches for the last day of the previous month
         // Note: datetime data type values is measured in seconds. I want to deduct X Days. Hence, X days * 24 Hours * 60 Minutes * 60 Seconds.
         
            TimeFirstDay = TimeCurrent() - (x-1)*24*60*60; // datetime of the first day of the month
            WeekdayFirstDayOfMonth = TimeDayOfWeek(TimeFirstDay); // Finding out which weekday is the first day of the month        
            break; // Exits the loop once I found WeekdayFirstDayOfMonth
         
         }
      }
      if (DayOfWeek() < WeekdayFirstDayOfMonth) { // If day of week today is less than WeekdayFirstDayOfMonth
         // Entry Rules
      } 
   }
   
   // TDL 4: No Trade on First Day of Month
   
   if (Day() != 1) {
   
      // Entry Rules
      
   }
   
   // TDL 5: No Trade on Mondays and Fridays
   
   if (DayOfWeek() != 1 && DayOfWeek() != 5) {
      
      // Entry Rules
   
   }
   
   // TDL 6: No Trade from 00:00 to 00:59 everyday
   
   if (Hour() != 0) {
   
      // Entry Rules
   
   }
   
   // TDL 7: Only trade between certain hours
   // Difficulty: Intermediate
   
   int isTrading = 0;
   string  TradeStartTime = "13:00";
   string  TradeStopTime = "8:00";
   
   datetime startTime = StrToTime(TradeStartTime);
   datetime endTime = StrToTime(TradeStopTime);
      
   if(startTime < endTime) {
      if(TimeCurrent() > startTime && TimeCurrent() < endTime) isTrading = 1;
   } else {
      if(TimeCurrent() > startTime || TimeCurrent() < endTime) isTrading = 1;
   }
      
   if (isTrading == 1) {
      
      // Entry Rules
      
   }
   
   
   
  }
//+------------------------------------------------------------------+
