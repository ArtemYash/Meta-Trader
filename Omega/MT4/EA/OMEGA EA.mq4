//+------------------------------------------------------------------+
//|                                                        OMEGA.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

enum ENUM_EntryType 
{
   Long, Short, Both
};

input ENUM_EntryType entryType = Long;
input float x_lowprice = 2.0; // X Low Price 
input float x_seg = 2.0; // X Seg
input int x_grid1 = 270; // X Grid 1
input int x_grid2 = 360; // X Grid 2

input int x1 = 0; // Grid X1
input int x2 = 1; // Grid X2
input int x3 = 2; // Grid X3
input int x4 = 3; // Grid X4

input double firstlots = 0.1 ; // First Trade Lots
input int MAGIC_NUMBER = 12345; // MAGIC NUMBER
input string indName = "OMEGA_Indicator_final"; // Indicator Name

datetime bartime = NULL;

double longTp = NULL;
double shortTp = NULL;
double longAnchorPriceTop = 0.0;
double longAnchorPriceBot = 0.0;
double shortAnchorPriceTop = 0.0;
double shortAnchorPriceBot = 0.0;

input bool option = true; // Breakeven
input int count_trade = 5; // Number of Trades



int OnInit()
  {
//---
   bartime = NULL;
   longTp = NULL;
   shortTp = NULL;
   longAnchorPriceTop = 0.0;
   longAnchorPriceBot = 0.0;
   shortAnchorPriceTop = 0.0;
   shortAnchorPriceBot = 0.0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   bool newBar = false;
   if(bartime != iTime(_Symbol, PERIOD_CURRENT, 0))
   newBar = true;
   bartime = iTime(_Symbol, PERIOD_CURRENT, 0);
   
  
   
  
   double y1u = iCustom(_Symbol, PERIOD_CURRENT, indName,x_lowprice, x_seg, x_grid1, x_grid2, x1, x2, x3, x4, 3, 0 );
   double y1l = iCustom(_Symbol, PERIOD_CURRENT, indName,x_lowprice, x_seg, x_grid1, x_grid2, x1, x2, x3, x4, 4, 0 );
   
   double y1u_1 = iCustom(_Symbol, PERIOD_CURRENT, indName,x_lowprice, x_seg, x_grid1, x_grid2, x1, x2, x3, x4, 3, 1 );
   double y1l_1 = iCustom(_Symbol, PERIOD_CURRENT, indName,x_lowprice, x_seg, x_grid1, x_grid2, x1, x2, x3, x4, 4, 1 );
   
   bool isNewHigh = y1u > y1u_1;
   bool isNewLow = y1l < y1l_1;
   
   bool takeLong = entryType == Long || entryType == Both;
   bool takeShort = entryType == Short || entryType == Both;
   
   
   // Breakeven Long
   if(option == true && getTradesCount(false) >= count_trade)
   {
      double avg_price = getAvgPrc(false);
      //Comment(avg_price);
      if(Ask < avg_price && avg_price == 0)
         CloseAll(false);
      
   }
   
   if(option == true && getTradesCount(true)>= count_trade )
   {
      double avg_price = getAvgPrc(true);
      Comment(avg_price, ": ", Bid);
      if(Bid > avg_price && avg_price != 0) CloseAll(true);
   }
   
   
   
   if(isNewHigh && longTp == y1u_1 && getTradesCount(true) > 0 )
   {
      // Close Long
      
      CloseAll(true);
      
      
   }
   
   if(isNewLow && shortTp == y1l_1 && getTradesCount(false) > 0 )
   {
      // Close Short
      
      CloseAll(false);
      
   }
   
   bool longAnchorFilter = PositionSize(true) > 0 ? longAnchorPriceTop != y1u && longAnchorPriceBot != y1l : true;
   bool shortAnchorFilter = PositionSize(false) < 0 ? shortAnchorPriceTop != y1u && shortAnchorPriceBot != y1l : true;

   if(isNewLow)
   {
      double lots = getSize(true) * firstlots;
      if (takeLong && longAnchorFilter)
      {
         longAnchorPriceBot = y1l;
         longAnchorPriceTop = y1u;
         longTp = y1u; // + MarketInfo(_Symbol, MODE_SPREAD) * Point();
         
         //CloseAll(false);
         int check = OrderSend(_Symbol, OP_BUY, lots, Ask, 3, NULL, NULL, "Long", MAGIC_NUMBER);
//          for(int i = OrdersTotal() - 1; i >= 0 ;i--)
//         {
//            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
//            {
//               if(OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
//               {
//                  if(OrderType() == OP_BUY)
//                  {
//                     OrderModify(OrderTicket(), OrderOpenPrice(), NULL, longTp, 0);
//                  }
//               }
//            }
//         }
//   
      
      }
      lots = getSize(false)  * firstlots;
      if(takeShort && shortAnchorFilter)
      {
         shortAnchorPriceBot = y1l;
         shortAnchorPriceTop = y1u;
         shortTp = y1l; // - MarketInfo(_Symbol, MODE_SPREAD) * Point();
         //CloseAll(true);
         int check = OrderSend(_Symbol, OP_SELL, lots, Bid, 3, NULL, NULL, "Short", MAGIC_NUMBER);
//          for(int i = OrdersTotal() - 1; i >= 0 ;i--)
//         {
//            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
//            {
//               if(OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
//               {
//
//                  if(OrderType() == OP_SELL)
//                  {
//                     OrderModify(OrderTicket(), OrderOpenPrice(), NULL, shortTp, 0);
//                  }
//      
//               }
//            }
//         }
//   
         
      }
      
   }
   if(isNewHigh)
   {
      double lots = getSize(true)  * firstlots;
      if (takeLong && longAnchorFilter)
      {
         longAnchorPriceBot = y1l;
         longAnchorPriceTop = y1u;
         longTp = y1u;
         //CloseAll(false);
         int check = OrderSend(_Symbol, OP_BUY, lots, Ask, 3, NULL, NULL, "Long", MAGIC_NUMBER);
      }
      lots = getSize(false)  * firstlots;
      if(takeShort && shortAnchorFilter)
      {
         shortAnchorPriceBot = y1l;
         shortAnchorPriceTop = y1u;
         shortTp = y1l;
         //CloseAll(true);
         int check = OrderSend(_Symbol, OP_SELL, lots, Bid, 3, NULL, NULL, "Short", MAGIC_NUMBER);
      }
      
   }
   
  }

double getAvgPrc(bool buyorsell)
{
   
   double lots_size = 0;
   double lots_avg = 0;
   for(int i = OrdersTotal() - 1; i >= 0 ;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_BUY && buyorsell == true)
            {
               lots_size += OrderLots();
               lots_avg += OrderLots() * OrderOpenPrice();
            }
            
               
            if(OrderType() == OP_SELL &&  buyorsell == false)
            {
               lots_size += OrderLots();
               lots_avg += OrderLots() * OrderOpenPrice();
            }

         }
      }
   }
   
  if(lots_size == 0)
  {
      return 0;
  }
  else return lots_avg / lots_size;
   
   
}


int getTradesCount(bool buyorsell)
{
   int Buy_Trades = 0;
   int Sell_Trades = 0;
   for(int i = OrdersTotal() - 1; i >= 0 ;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_BUY)
               Buy_Trades ++;
            if(OrderType() == OP_SELL)
               Sell_Trades ++;
         }
      }
   }
   return buyorsell ? Buy_Trades : Sell_Trades;
}

double getSize(bool buyorsell)
{
   
   int Buy_Trades = getTradesCount(true);
   int Sell_Trades = getTradesCount(false);
   double size = 0;
   if(buyorsell == false)
   size = Sell_Trades == 0 || Sell_Trades == 1 ? 1 : pow(2, Sell_Trades - 1);
   
   else if(buyorsell == true)
   size = Buy_Trades == 0  || Buy_Trades == 1? 1 : pow(2, Buy_Trades - 1);
   
   
  return size;
}

double PositionSize(bool buyorsell)
{
   double totalBuyLots = 0;
   double totalSellLots = 0;
   for(int i = OrdersTotal() - 1; i >= 0 ;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_BUY)
               totalBuyLots += OrderLots();
            if(OrderType() == OP_SELL)
               totalSellLots += OrderLots();
         }
      }
   }
   if ( buyorsell == true)
   return totalBuyLots;
   
   else return - totalSellLots;
   
  
}
//+------------------------------------------------------------------+

void CloseAll(bool buyorsell)
{
    for(int i = OrdersTotal() - 1; i >= 0 ;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_BUY && buyorsell == true)
            {
               int check = OrderClose(OrderTicket(), OrderLots(), Bid, 3);
               
            }
            if(OrderType() == OP_SELL && buyorsell == false)
            {
               int check = OrderClose(OrderTicket(), OrderLots(), Ask, 3);
               
            }
         }
      }
   }
}