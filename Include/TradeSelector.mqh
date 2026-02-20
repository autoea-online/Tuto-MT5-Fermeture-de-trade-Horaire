//+------------------------------------------------------------------+
//|                                              TradeSelector.mqh   |
//|              Tuto MT5 - Fermeture Horaire Automatique            |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : CompterPositionsOuvertes                              |
//| Compte TOUTES les positions ouvertes (tous symboles).            |
//+------------------------------------------------------------------+
int CompterPositionsOuvertes()
{
    return PositionsTotal();
}

//+------------------------------------------------------------------+
//| Fonction : CompterPositionsSymbole                               |
//| Compte les positions ouvertes sur le symbole courant.            |
//+------------------------------------------------------------------+
int CompterPositionsSymbole()
{
    int count = 0;
    int totalPositions = PositionsTotal();

    for(int i = 0; i < totalPositions; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
                count++;
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Fonctions d'accès                                                |
//+------------------------------------------------------------------+

ENUM_POSITION_TYPE ObtenirTypePosition()
{
    return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
}

double ObtenirPrixOuverture()
{
    return PositionGetDouble(POSITION_PRICE_OPEN);
}

double ObtenirSLActuel()
{
    return PositionGetDouble(POSITION_SL);
}

double ObtenirTPActuel()
{
    return PositionGetDouble(POSITION_TP);
}

double ObtenirVolume()
{
    return PositionGetDouble(POSITION_VOLUME);
}
