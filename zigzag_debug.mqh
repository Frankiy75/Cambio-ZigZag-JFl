//+------------------------------------------------------------------+
//| Función de debug para diagnosticar problemas del ZigZag          |
//+------------------------------------------------------------------+
void DebugZigZagStatus()
{
   static datetime lastDebugTime = 0;
   datetime now = TimeCurrent();
   
   // Debug cada 10 segundos máximo
   if(now - lastDebugTime < 10) return;
   lastDebugTime = now;
   
   Print("=== ZIGZAG DEBUG STATUS ===");
   Print("Current Extreme: ", DoubleToString(currentExtreme, _Digits));
   Print("Current Direction: ", currentDirection);
   Print("Current Time: ", TimeToString(currentExtremeTime));
   Print("Pivot Count: ", pivotCount);
   Print("Last 3 pivots:");
   
   for(int i = MathMax(0, pivotCount - 3); i < pivotCount; i++)
   {
      Print("  Pivot ", i, ": ", 
            pivots[i].isHigh ? "HIGH" : "LOW", " = ",
            DoubleToString(pivots[i].point.price, _Digits), " at ",
            TimeToString(pivots[i].point.time));
   }
   Print("========================");
}

//+------------------------------------------------------------------+
//| Función mejorada para validar coherencia del ZigZag             |
//+------------------------------------------------------------------+
bool ValidateZigZagCoherence()
{
   if(pivotCount < 2) return true;
   
   // Verificar que los pivotes alternen entre HIGH y LOW
   for(int i = 1; i < pivotCount; i++)
   {
      if(pivots[i].isHigh == pivots[i-1].isHigh)
      {
         Print("⚠️ ZIGZAG COHERENCE ERROR: Consecutive ", 
               pivots[i].isHigh ? "HIGH" : "LOW", " pivots at index ", i);
         return false;
      }
   }
   
   // Verificar que los HIGHs sean mayores que LOWs adyacentes
   for(int i = 0; i < pivotCount; i++)
   {
      if(pivots[i].isHigh)
      {
         // Verificar vs LOW anterior
         if(i > 0 && !pivots[i-1].isHigh)
         {
            if(pivots[i].point.price <= pivots[i-1].point.price)
            {
               Print("⚠️ ZIGZAG COHERENCE ERROR: HIGH ", i, " (", 
                     DoubleToString(pivots[i].point.price, _Digits), 
                     ") not higher than previous LOW (", 
                     DoubleToString(pivots[i-1].point.price, _Digits), ")");
               return false;
            }
         }
         
         // Verificar vs LOW siguiente
         if(i < pivotCount - 1 && !pivots[i+1].isHigh)
         {
            if(pivots[i].point.price <= pivots[i+1].point.price)
            {
               Print("⚠️ ZIGZAG COHERENCE ERROR: HIGH ", i, " (", 
                     DoubleToString(pivots[i].point.price, _Digits), 
                     ") not higher than next LOW (", 
                     DoubleToString(pivots[i+1].point.price, _Digits), ")");
               return false;
            }
         }
      }
   }
   
   return true;
}