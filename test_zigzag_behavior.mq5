//+------------------------------------------------------------------+
//| Test script para diagnosticar comportamiento del ZigZag         |
//+------------------------------------------------------------------+
#property script_show_inputs

// Test parameters
input int TestPeriodBars = 100;  // Número de barras para analizar
input bool EnableDebugOutput = true;  // Habilitar salida de debug

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== DIAGNÓSTICO ZIGZAG BEHAVIOR ===");
   Print("Símbolo: ", _Symbol);
   Print("Timeframe: ", Period());
   Print("Barras a analizar: ", TestPeriodBars);
   
   // Test 1: Verificar lógica de prioridad de fuentes
   TestSourcePriorityLogic();
   
   // Test 2: Verificar patrones de 5 velas para timeframes
   TestTFPatternDetection();
   
   // Test 3: Verificar comportamiento de extremos
   TestExtremeValidation();
   
   Print("=== FIN DIAGNÓSTICO ===");
}

//+------------------------------------------------------------------+
//| Test 1: Verificar lógica de prioridad                            |
//+------------------------------------------------------------------+
void TestSourcePriorityLogic()
{
   Print("\n--- TEST 1: SOURCE PRIORITY LOGIC ---");
   
   int countBullishHighPriority = 0;
   int countBearishLowPriority = 0;
   int countDoji = 0;
   
   for(int i = 1; i <= TestPeriodBars; i++)
   {
      double open = iOpen(_Symbol, _Period, i);
      double high = iHigh(_Symbol, _Period, i);
      double low = iLow(_Symbol, _Period, i);
      double close = iClose(_Symbol, _Period, i);
      
      string priority = "";
      
      // Reproducir lógica de DetermineSourcePriority
      if(close > open)
      {
         priority = "high";
         countBullishHighPriority++;
      }
      else if(close < open)
      {
         priority = "low";
         countBearishLowPriority++;
      }
      else
      {
         double distToHigh = high - open;
         double distToLow = open - low;
         priority = (distToHigh > distToLow) ? "high" : "low";
         countDoji++;
      }
      
      if(EnableDebugOutput && i <= 10)
      {
         Print("Bar ", i, ": O=", DoubleToString(open, _Digits), 
               " H=", DoubleToString(high, _Digits),
               " L=", DoubleToString(low, _Digits),
               " C=", DoubleToString(close, _Digits),
               " Priority=", priority);
      }
   }
   
   Print("Resumen Source Priority:");
   Print("  Velas bullish (high priority): ", countBullishHighPriority);
   Print("  Velas bearish (low priority): ", countBearishLowPriority);
   Print("  Velas doji: ", countDoji);
}

//+------------------------------------------------------------------+
//| Test 2: Verificar detección de patrones TF                       |
//+------------------------------------------------------------------+
void TestTFPatternDetection()
{
   Print("\n--- TEST 2: TF PATTERN DETECTION ---");
   
   string currentTF = "";
   switch(_Period)
   {
      case PERIOD_M1:   currentTF = "1m"; break;
      case PERIOD_M5:   currentTF = "5m"; break;
      case PERIOD_M15:  currentTF = "15m"; break;
      case PERIOD_M30:  currentTF = "30m"; break;
      case PERIOD_H1:   currentTF = "1H"; break;
      case PERIOD_H4:   currentTF = "4H"; break;
      case PERIOD_H12:  currentTF = "12H"; break;
      case PERIOD_D1:   currentTF = "D"; break;
      case PERIOD_W1:   currentTF = "W"; break;
      case PERIOD_MN1:  currentTF = "M"; break;
      default:          currentTF = IntegerToString(_Period);
   }
   
   Print("Timeframe actual detectado: ", currentTF);
   
   int highPatterns = 0;
   int lowPatterns = 0;
   
   // Buscar patrones como en DetectAndMarkTFPatterns
   for(int i = 2; i < TestPeriodBars - 2; i++)
   {
      double h_i2 = iHigh(_Symbol, _Period, i+2);
      double h_i1 = iHigh(_Symbol, _Period, i+1);
      double h_i0 = iHigh(_Symbol, _Period, i);
      double h_m1 = iHigh(_Symbol, _Period, i-1);
      double h_m2 = iHigh(_Symbol, _Period, i-2);

      double l_i2 = iLow(_Symbol, _Period, i+2);
      double l_i1 = iLow(_Symbol, _Period, i+1);
      double l_i0 = iLow(_Symbol, _Period, i);
      double l_m1 = iLow(_Symbol, _Period, i-1);
      double l_m2 = iLow(_Symbol, _Period, i-2);

      // Pico HIGH: h_i2 < h_i1 < h_i0 > h_m1 > h_m2
      if(h_i2 < h_i1 && h_i1 < h_i0 && h_i0 > h_m1 && h_m1 > h_m2)
      {
         highPatterns++;
         if(EnableDebugOutput && highPatterns <= 5)
         {
            datetime timeBar = iTime(_Symbol, _Period, i);
            Print("HIGH Pattern ", highPatterns, " en bar ", i, " (", TimeToString(timeBar), "): ", 
                  DoubleToString(h_i0, _Digits));
         }
      }

      // Valle LOW: l_i2 > l_i1 > l_i0 < l_m1 < l_m2
      if(l_i2 > l_i1 && l_i1 > l_i0 && l_i0 < l_m1 && l_m1 < l_m2)
      {
         lowPatterns++;
         if(EnableDebugOutput && lowPatterns <= 5)
         {
            datetime timeBar = iTime(_Symbol, _Period, i);
            Print("LOW Pattern ", lowPatterns, " en bar ", i, " (", TimeToString(timeBar), "): ", 
                  DoubleToString(l_i0, _Digits));
         }
      }
   }
   
   Print("Patrones detectados para timeframe ", currentTF, ":");
   Print("  HIGH patterns: ", highPatterns);
   Print("  LOW patterns: ", lowPatterns);
   Print("NOTA: Las etiquetas mostrarán '", currentTF, "', no necesariamente '1m'");
}

//+------------------------------------------------------------------+
//| Test 3: Verificar comportamiento de extremos                     |
//+------------------------------------------------------------------+
void TestExtremeValidation()
{
   Print("\n--- TEST 3: EXTREME VALIDATION ---");
   
   // Simular validación de extremos como en ValidateCurrentExtreme
   double maxHigh = 0;
   double minLow = DBL_MAX;
   datetime maxHighTime = 0;
   datetime minLowTime = 0;
   
   for(int i = 0; i < TestPeriodBars; i++)
   {
      double high = iHigh(_Symbol, _Period, i);
      double low = iLow(_Symbol, _Period, i);
      datetime time = iTime(_Symbol, _Period, i);
      
      if(high > maxHigh)
      {
         maxHigh = high;
         maxHighTime = time;
      }
      
      if(low < minLow)
      {
         minLow = low;
         minLowTime = time;
      }
   }
   
   Print("Extremos en ", TestPeriodBars, " barras:");
   Print("  Máximo HIGH: ", DoubleToString(maxHigh, _Digits), " en ", TimeToString(maxHighTime));
   Print("  Mínimo LOW: ", DoubleToString(minLow, _Digits), " en ", TimeToString(minLowTime));
   
   // Verificar validez de extremos con tolerancia del 5%
   double currentPrice = iClose(_Symbol, _Period, 0);
   bool maxValidForUp = (currentPrice > maxHigh * 0.95);
   bool minValidForDown = (currentPrice < minLow * 1.05);
   
   Print("Precio actual: ", DoubleToString(currentPrice, _Digits));
   Print("Máximo válido para dirección UP (5% tolerancia): ", maxValidForUp ? "SÍ" : "NO");
   Print("Mínimo válido para dirección DOWN (5% tolerancia): ", minValidForDown ? "SÍ" : "NO");
   
   if(!maxValidForUp && !minValidForDown)
   {
      Print("⚠️ PROBLEMA: Ningún extremo es válido con tolerancia del 5%");
   }
}