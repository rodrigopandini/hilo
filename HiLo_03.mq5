//+------------------------------------------------------------------+
//|                                                      HiLo_03.mq5 |
//|                                  Copyright 2016, Rodrigo Pandini |
//|                                         rodrigopandini@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Rodrigo Pandini"
#property link "rodrigopandini@gmail.com"
#property version "1.00"

//#property icon "../Images/hilo.ico"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 3

#property indicator_label1 "HiLo_03"
#property indicator_type1 DRAW_COLOR_ARROW
#property indicator_style1  STYLE_SOLID

input int InpPeriodHiLo = 10; // Period
input int InpShiftHiLo = 0; // Shift
input ENUM_MA_METHOD InpSmoothingMethodHiLo = MODE_SMA; // Smoothing method
input color InpColorUpHiLo = clrGreen; // Up color
input color InpColorDownHiLo = clrRed; // Down color
input int InpWidthHiLo = 2; // Width
/*input*/ int InpWingdingsCodeHilo = 159; // Wingdings code

// indicators buffers
double HiLoBuffer[], HMABuffer[], LMABuffer[];
// color buffer
double ColorBuffer[];

// handles
int handleHighMA, handleLowMA;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {


  /*
    TODO: validate all inputs
  */


  // set the index for buffers
  SetIndexBuffer(0, HiLoBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ColorBuffer, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, HMABuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, LMABuffer, INDICATOR_CALCULATIONS);

  // the null values should not be plotted
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  // assign the array with color indexes with the indicator's color indexes buffer
  PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
  // set color for each index
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpColorUpHiLo);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpColorDownHiLo);

  // set the line width
  PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpWidthHiLo);

  // set arrow symbol
  if(InpWingdingsCodeHilo >= 32 && InpWingdingsCodeHilo <= 255) {
    PlotIndexSetInteger(0, PLOT_ARROW, InpWingdingsCodeHilo);
  }
  else{
    PlotIndexSetInteger(0, PLOT_ARROW, 159); // circle
  }

  // set indicator digits
  IndicatorSetInteger(INDICATOR_DIGITS, Digits());

  handleHighMA = iMA(Symbol(), Period(), InpPeriodHiLo, InpShiftHiLo, InpSmoothingMethodHiLo, PRICE_HIGH);
  handleLowMA = iMA(Symbol(), Period(), InpPeriodHiLo, InpShiftHiLo, InpSmoothingMethodHiLo, PRICE_LOW);

  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {

  int statusHMA = CopyBuffer(handleHighMA, 0, 0, rates_total, HMABuffer);
  int statusLMA = CopyBuffer(handleLowMA, 0, 0, rates_total, LMABuffer);
  int bars = BarsCalculated(handleHighMA);
  bars = MathMax(bars, BarsCalculated(handleLowMA));
  int Hld = 0;
  int Hlv = 0;

  if((statusHMA > 0) && (statusLMA > 0) && (bars >= rates_total)) {
    int start = 1;

    if(prev_calculated > 0)
      start = prev_calculated - 1;

    for(int i = start; i < rates_total; i++) {
      HiLoBuffer[i] = EMPTY_VALUE;

      if(close[i] >= HMABuffer[i - 1])
        Hld = 1;
      else
      if(close[i] <= LMABuffer[i - 1])
        Hld = -1;
      else
        Hld = 0;

      if(Hld != 0)
        Hlv = Hld;

      if(Hlv == -1) {
        HiLoBuffer[i] = HMABuffer[i - 1];
        ColorBuffer[i] = 1;
      }
      else {
        HiLoBuffer[i] = LMABuffer[i - 1];
        ColorBuffer[i] = 0;
      }
    }
  }

  return(rates_total);
}
//+------------------------------------------------------------------+
