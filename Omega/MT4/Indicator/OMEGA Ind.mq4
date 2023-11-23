//+------------------------------------------------------------------+
//|                                              OMEGA_Indicator.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 8


input double x_lowprice =0.0;
input double x_seg =2.0;
input int    x_grid1 =270;
input int    x_grid2 =360;
input int    x1 = 0;
input int    x2 = 1;
input int    x3 = 2;
input int    x4 = 3;

double y2u[],y1u[],y1l[],y2l[];
double y4u[], y3u[], y3l[], y4l[];
double x_seh = 10/x_seg;
double x_sei = x_seh/x_seg;
int x_grid3 = x_grid1+x_grid2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   x_seh = 10/x_seg;
   x_sei = x_seh/x_seg;
   x_grid3 = x_grid1+x_grid2;
//--- indicator buffers mapping
   IndicatorDigits(Digits);
    
   ArrayInitialize(y4u, 0.0);
   ArrayInitialize(y3u, 0.0);
   ArrayInitialize(y2u, 0.0);
   ArrayInitialize(y1u, 0.0);
   
   ArrayInitialize(y4l, 0.0);
   ArrayInitialize(y3l, 0.0);
   ArrayInitialize(y2l, 0.0);
   ArrayInitialize(y1l, 0.0);
   
   SetIndexStyle(0,DRAW_NONE,STYLE_SOLID,2, clrGreen);
   SetIndexBuffer(0,y4u);
   
   SetIndexStyle(1,DRAW_NONE,STYLE_SOLID,2, clrYellow);
   SetIndexBuffer(1,y3u);

   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2,clrBlue);
   SetIndexBuffer(2,y2u);

   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2,clrPink);
   SetIndexBuffer(3,y1u);

   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2,clrPink);
   SetIndexBuffer(4,y1l);

   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,2,clrBlue);
   SetIndexBuffer(5,y2l);
   
   SetIndexStyle(6,DRAW_NONE,STYLE_SOLID,2, clrYellow);
   SetIndexBuffer(6,y3l);
   
   SetIndexStyle(7,DRAW_NONE,STYLE_SOLID,2,clrGreen);
   SetIndexBuffer(7,y4l);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   
  int limit = 0;
   if(prev_calculated == 0)
      limit = rates_total - prev_calculated - 1;

   if(prev_calculated>0)
      limit++;

   for(int i = limit; i >= 0; i--)
     {

      Process(i,open,high,low,close);
     }


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Process(int i,const double &open[],
             const double &high[],
             const double &low[],
             const double &close[])
  {
  
   y4u[i] = get_grid0( x_lowprice+high[i] , x4 ) - x_lowprice;
   y3u[i] = get_grid0( x_lowprice+high[i] , x3 ) - x_lowprice;
   y2u[i] = get_grid0( x_lowprice+high[i] , x2 ) - x_lowprice;
   y1u[i] = get_grid0( x_lowprice+high[i] , x1 ) - x_lowprice;
   y1l[i] = get_grid0( x_lowprice+low[i] , -x1-1 ) - x_lowprice;
   y2l[i] = get_grid0( x_lowprice+low[i] , -x2-1 ) - x_lowprice;
   y3l[i] = get_grid0( x_lowprice+low[i] , -x3-1 ) - x_lowprice;
   y4l[i] = get_grid0( x_lowprice+low[i] , -x4-1 ) - x_lowprice;
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double math_floororceil(double x,bool xisceil)
  {
   return xisceil?MathCeil(x):MathFloor(x);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_grid2(double xexp)
  {
   double y = 1.0;
   if(xexp<=x_grid1)
      y = MathPow(x_seg, xexp/x_grid1);
   else
      if(xexp<x_grid3)
         y = MathPow(x_sei, (xexp- x_grid1)/x_grid2)*x_seg;
      else
         y = MathPow(x_seg, (xexp- x_grid3)/x_grid1)*x_seh;
   return y;
  }
//+------------------------------------------------------------------+
double get_grid1(double x,bool xisceil)
  {
   double y = 0;
   double z = 0.0;
   if(x<=x_seg)
     {
      z = math_floororceil(MathLog(x)*x_grid1/MathLog(x_seg), xisceil);
      y = (int)(z);
     }
   else
      if(x<=x_seh)
        {
         z = math_floororceil(MathLog(x/x_seg)*x_grid2/MathLog(x_sei), xisceil);
         y = (int)(z) + x_grid1;
        }
      else
        {
         z = math_floororceil(MathLog(x/x_seh)*x_grid1/MathLog(x_seg), xisceil);
         y = (int)(z) + x_grid3;
        }
   return  y;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  get_grid0(double x,double xexp)
  {
   double z0 = floor(log10(x));
   double z1 = get_grid1(x / pow(10, z0), xexp>=0);
   return get_grid2(z1+xexp+(xexp<0?1:0)) * pow(10, z0);
  }
