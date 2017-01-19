//+------------------------------------------------------------------+
//|                                                      HiLo_01.mq5 |
//|                                  Copyright 2016, Rodrigo Pandini |
//|                                         rodrigopandini@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Rodrigo Pandini"
#property link "rodrigopandini@gmail.com"
#property version "1.00"

//#property icon "../Images/hilo.ico"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 1

#property indicator_label1 "HiLo_01"
#property indicator_type1 DRAW_COLOR_LINE

input int InpPeriodHiLo = 10; // Period
input int InpShiftHiLo = 0; // Shift
input ENUM_MA_METHOD InpSmoothingMethodHiLo = MODE_SMA; // Smoothing method
input int InpLineWidthHiLo = 2; // Line width
input ENUM_LINE_STYLE InpLineStyleHiLo = STYLE_DASH; // Line style
input color InpColorHiLo = clrYellow; // Default color
input color InpColorUpHiLo = clrGreen; // Up color
input color InpColorDownHiLo = clrRed; // Down color

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
  PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 3);
  // set color for each index
  //PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, GetChartBackgroundColor());
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpColorHiLo);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, InpColorUpHiLo);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, InpColorDownHiLo);

  // set the line width
  PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpLineWidthHiLo);

  // set the line style
  PlotIndexSetInteger(0, PLOT_LINE_STYLE, InpLineStyleHiLo);

  // set indicator digits
  IndicatorSetInteger(INDICATOR_DIGITS, Digits());

  // get indicator handles
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
        ColorBuffer[i] = 2;
      }
      else {
        HiLoBuffer[i] = LMABuffer[i - 1];
        ColorBuffer[i] = 1;
      }

      if((HiLoBuffer[i] > open[i] && HiLoBuffer[i-1] < open[i]) ||
         (HiLoBuffer[i] < open[i] && HiLoBuffer[i-1] > open[i]))
        ColorBuffer[i] = 0;

    }
  }

  return(rates_total);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Gets the background color of chart                               |
//+------------------------------------------------------------------+
color GetChartBackgroundColor(const long chart_ID = 0) {
  //--- prepare the variable to receive the color
  long result = clrNONE;
  //--- reset the error value
  ResetLastError();
  //--- receive chart background color
  if(!ChartGetInteger(chart_ID, CHART_COLOR_BACKGROUND, 0, result)) {
    //--- display the error message in Experts journal
    Print(__FUNCTION__ + ", Error Code = ", GetLastError());
  }
  //--- return the value of the chart property
  return((color)result);
}
