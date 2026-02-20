//+------------------------------------------------------------------+
//|                                              TradeManager.mqh    |
//|              Tuto MT5 - Fermeture Horaire Automatique            |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Fonction : FermerToutesPositions                                  |
//| Ferme TOUTES les positions sur TOUS les symboles.                |
//| Parcours inversé pour éviter le bug de l'index.                  |
//+------------------------------------------------------------------+
int FermerToutesPositions()
{
    CTrade trade;
    trade.SetDeviationInPoints(10);

    int nbFermees = 0;
    int total = PositionsTotal();

    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);

        if(ticket == 0)
            continue;

        string symbole = PositionGetString(POSITION_SYMBOL);
        double volume = PositionGetDouble(POSITION_VOLUME);
        double profit = PositionGetDouble(POSITION_PROFIT);

        ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        string typeStr = (type == POSITION_TYPE_BUY) ? "BUY" : "SELL";

        Print("   ⏰ Fermeture #", ticket, " | ", symbole,
              " | ", typeStr, " | ", volume, " lots | P/L: ", profit);

        bool resultat = trade.PositionClose(ticket, 10);

        if(resultat)
        {
            uint codeRetour = trade.ResultRetcode();

            if(codeRetour == TRADE_RETCODE_DONE)
            {
                Print("   ✅ Fermé au prix : ", trade.ResultPrice());
                nbFermees++;
            }
            else
            {
                Print("   ⚠️ Code : ", codeRetour, " — ", trade.ResultRetcodeDescription());
            }
        }
        else
        {
            Print("   ❌ Échec : ", trade.ResultRetcode(),
                  " — ", trade.ResultRetcodeDescription());
        }
    }

    return nbFermees;
}

//+------------------------------------------------------------------+
//| Fonction : FermerPositionsSymbole                                |
//| Ferme uniquement les positions du symbole courant.               |
//| Parcours inversé.                                                |
//+------------------------------------------------------------------+
int FermerPositionsSymbole()
{
    CTrade trade;
    trade.SetDeviationInPoints(10);

    int nbFermees = 0;
    int total = PositionsTotal();

    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);

        if(ticket == 0)
            continue;

        // Filtrer par symbole
        string symbole = PositionGetString(POSITION_SYMBOL);
        if(symbole != _Symbol)
            continue;   // Pas le bon symbole → skip

        double volume = PositionGetDouble(POSITION_VOLUME);
        double profit = PositionGetDouble(POSITION_PROFIT);

        ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        string typeStr = (type == POSITION_TYPE_BUY) ? "BUY" : "SELL";

        Print("   ⏰ Fermeture #", ticket, " | ", symbole,
              " | ", typeStr, " | ", volume, " lots | P/L: ", profit);

        bool resultat = trade.PositionClose(ticket, 10);

        if(resultat && trade.ResultRetcode() == TRADE_RETCODE_DONE)
        {
            Print("   ✅ Fermé au prix : ", trade.ResultPrice());
            nbFermees++;
        }
        else
        {
            Print("   ❌ Échec : ", trade.ResultRetcode(),
                  " — ", trade.ResultRetcodeDescription());
        }
    }

    return nbFermees;
}

//+------------------------------------------------------------------+
//| Fonction : AfficherInfoPosition                                  |
//+------------------------------------------------------------------+
void AfficherInfoPosition(ulong ticket)
{
    Print("═══════════════════════════════════════");
    Print("📊 Position #", ticket);
    Print("═══════════════════════════════════════");
    Print("   Symbole       : ", PositionGetString(POSITION_SYMBOL));

    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    Print("   Type           : ", (type == POSITION_TYPE_BUY) ? "BUY" : "SELL");
    Print("   Prix ouverture : ", PositionGetDouble(POSITION_PRICE_OPEN));
    Print("   Volume (lots)  : ", PositionGetDouble(POSITION_VOLUME));
    Print("   Profit actuel  : ", PositionGetDouble(POSITION_PROFIT), " ",
          AccountInfoString(ACCOUNT_CURRENCY));
    Print("═══════════════════════════════════════");
}
